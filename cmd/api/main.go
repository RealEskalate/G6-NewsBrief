package main

import (
	"context"
	"flag"
	"log"
	"os"
	"strings"
	"time"

	"github.com/RealEskalate/G6-NewsBrief/internal/domain/contract"
	handlerHttp "github.com/RealEskalate/G6-NewsBrief/internal/handler/http"
	"github.com/RealEskalate/G6-NewsBrief/internal/infrastructure/config"
	database "github.com/RealEskalate/G6-NewsBrief/internal/infrastructure/database"
	"github.com/RealEskalate/G6-NewsBrief/internal/infrastructure/external_services"
	"github.com/RealEskalate/G6-NewsBrief/internal/infrastructure/jwt"
	"github.com/RealEskalate/G6-NewsBrief/internal/infrastructure/logger"
	passwordservice "github.com/RealEskalate/G6-NewsBrief/internal/infrastructure/password_service"
	randomgenerator "github.com/RealEskalate/G6-NewsBrief/internal/infrastructure/random_generator"
	"github.com/RealEskalate/G6-NewsBrief/internal/infrastructure/repository/mongodb"
	"github.com/RealEskalate/G6-NewsBrief/internal/infrastructure/seeder"
	"github.com/RealEskalate/G6-NewsBrief/internal/infrastructure/uuidgen"
	"github.com/RealEskalate/G6-NewsBrief/internal/infrastructure/validator"
	"github.com/RealEskalate/G6-NewsBrief/internal/usecase"
	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
)

func adminSeeder(userUsecase contract.IUserUseCase, userRepo contract.IUserRepository) {
	// Add a -seed flag to run seeder before starting the server
	seed := flag.Bool("seed", true, "run database seeder and exit")
	flag.Parse()

	// Optionally allow seeding via env (useful on Render/CI)
	seedOnStart := os.Getenv("SEED_ON_START") == "true"

	if *seed || seedOnStart {
		ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
		defer cancel()

		adminEmail := os.Getenv("SEED_ADMIN_EMAIL")
		if adminEmail == "" {
			adminEmail = "admin@newsbrief.local"
		}
		adminPassword := os.Getenv("SEED_ADMIN_PASSWORD")
		if adminPassword == "" {
			adminPassword = "ChangeMe123!"
		}

		if err := seeder.SeedAdminUsingUC(ctx, userUsecase, userRepo, adminEmail, adminPassword); err != nil {
			log.Fatalf("seeding failed: %v", err)
		}
		log.Println("seeding completed")
		// Exit if seeding-only mode
		if *seed {
			return
		}
	}
}

func main() {
	// Load environment variables from .env file
	if err := godotenv.Load(); err != nil {
		log.Println("No .env file found, using environment variables")
	}

	// Get MongoDB URI and DB name from environment
	mongoURI := os.Getenv("MONGODB_URI")
	if mongoURI == "" {
		log.Fatal("MONGODB_URI environment variable not set")
	}
	dbName := os.Getenv("MONGODB_DB_NAME")
	if dbName == "" {
		log.Fatal("MONGODB_DB_NAME environment variable not set")
	}

	// Establish MongoDB connection
	mongoClient, err := database.NewMongoDBClient(mongoURI)
	if err != nil {
		log.Fatalf("Failed to connect to MongoDB: %v", err)
	}
	defer mongoClient.Disconnect()

	// Initialize email service
	emailHost := os.Getenv("EMAIL_HOST")
	emailPort := os.Getenv("EMAIL_PORT")
	emailUsername := os.Getenv("EMAIL_USERNAME")
	emailAppPassword := os.Getenv("EMAIL_APP_PASSWORD")
	emailFrom := os.Getenv("EMAIL_FROM")

	// Register custom validators
	validator.RegisterCustomValidators()

	// Dependency Injection: Repositories
	userCollection := mongoClient.Client.Database(dbName).Collection("users")
	userRepo := mongodb.NewUserRepository(userCollection)
	newsRepo := mongodb.NewNewsRepositoryMongo(mongoClient.Client.Database(dbName).Collection("news"))
	tokenRepo := mongodb.NewTokenRepository(mongoClient.Client.Database(dbName).Collection("tokens"))
	topicRepo := mongodb.NewTopicRepository(mongoClient.Client.Database(dbName).Collection("topics"))
	sourceRepo := mongodb.NewSourceRepository(mongoClient.Client.Database(dbName).Collection("sources"))
	bookmarkRepo := mongodb.NewBookmarkRepository(mongoClient.Client.Database(dbName))
	analyticRepo := mongodb.NewAnalyticRepository(mongoClient.Client.Database(dbName).Collection("analytics"))

	// -------------- initialize analytics document if not present --------------
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	if err := analyticRepo.InitializeAnalytics(ctx); err != nil {
		log.Fatalf("Failed to initialize analytics: %v", err)
	}
	// -------------- end of analytics document initialization --------------
	// Dependency Injection: Services
	hasher := passwordservice.NewHasher()
	jwtSecret := os.Getenv("JWT_SECRET")
	if jwtSecret == "" {
		log.Fatal("JWT_SECRET environment variable not set")
	}
	jwtManager := jwt.NewJWTManager(jwtSecret)
	jwtService := jwt.NewJWTService(jwtManager)
	appLogger := logger.NewStdLogger()
	mailService := external_services.NewEmailService(emailHost, emailPort, emailUsername, emailAppPassword, emailFrom)
	randomGenerator := randomgenerator.NewRandomGenerator()
	appValidator := validator.NewValidator()
	uuidGenerator := uuidgen.NewGenerator()
	appConfig := config.NewConfig()
	// External services
	summarizerAPI := os.Getenv("GEMINI_API_URL")
	GeminiAPIKey := os.Getenv("GEMINI_API_KEY")
	if summarizerAPI == "" {
		log.Fatal("GEMINI_API_URL environment variable not set")
	}
	geminiClient := external_services.NewGeminiClient(GeminiAPIKey, summarizerAPI)
	translatorClient := external_services.NewTranslatorClient()
	providerClient := external_services.NewNewsProviderClient()

	// Dependency Injection: Usecases
	emailUsecase := usecase.NewEmailVerificationUseCase(tokenRepo, userRepo, mailService, randomGenerator, uuidGenerator, appConfig)
	userUsecase := usecase.NewUserUsecase(userRepo, tokenRepo, topicRepo, analyticRepo, emailUsecase, hasher, jwtService, mailService, appLogger, appConfig, appValidator, uuidGenerator, randomGenerator)
	topicUsecase := usecase.NewTopicUsecase(topicRepo, analyticRepo)
	sourceUsecase := usecase.NewSourceUsecase(sourceRepo, analyticRepo)
	subscriptionUsecase := usecase.NewSubscriptionUsecase(userRepo, sourceRepo)
	providerIngestionUC := usecase.NewProviderIngestionUsecase(providerClient, geminiClient, translatorClient, topicRepo, newsRepo, uuidGenerator)
	// Pass Prometheus metrics to handlers or usecases as needed (import from metrics package)

	//---------------------- Admin seeder-------------------------------------
	adminSeeder(userUsecase, userRepo)
	//---------------------- end of admin seeder-------------------------------------

	// Setup API routes
	appRouter := handlerHttp.NewRouter(
		userUsecase, emailUsecase,
		userRepo, tokenRepo, analyticRepo, topicRepo, hasher, jwtService, mailService,
		appLogger, appConfig, appValidator, uuidGenerator, randomGenerator, sourceUsecase, topicUsecase, subscriptionUsecase,
		sourceRepo, newsRepo, bookmarkRepo, geminiClient,
	)

	// Initialize Gin router
	router := gin.Default()

	appRouter.SetupRoutes(router)

	if enabled := strings.ToLower(os.Getenv("PROVIDER_INGEST_SCHEDULED")); enabled == "" || enabled == "true" {
		go runDailyIngestion(providerIngestionUC, appLogger)
	}

	// Start the server
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}
	log.Printf("Server running on port %s", port)
	if err := router.Run(":" + port); err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}

}

// runDailyIngestion schedules provider ingestion at fixed local times (07:00, 13:00, 19:00).
func runDailyIngestion(uc contract.IProviderIngestionUsecase, logger contract.IAppLogger) {
	times := []struct{ hour, min int }{{7, 0}, {13, 0}, {19, 0}}
	scheduleNext := func(target time.Time) time.Duration { return time.Until(target) }
	// Launch one goroutine per scheduled time
	for _, t := range times {
		go func(hour, minute int) {
			for {
				now := time.Now()
				next := time.Date(now.Year(), now.Month(), now.Day(), hour, minute, 0, 0, now.Location())
				if !next.After(now) { // passed -> tomorrow
					next = next.Add(24 * time.Hour)
				}
				d := scheduleNext(next)
				timer := time.NewTimer(d)
				<-timer.C
				ctx, cancel := context.WithTimeout(context.Background(), 2*time.Minute)
				start := time.Now()
				ids, skipped, err := uc.IngestFromProvider(ctx, "general", 20)
				cancel()
				if err != nil {
					logger.Errorf("scheduled provider ingestion failed: %v", err)
				} else {
					logger.Infof("scheduled provider ingestion at %02d:%02d done: ingested=%d skipped=%d duration=%s", hour, minute, len(ids), skipped, time.Since(start))
				}
			}
		}(t.hour, t.min)
	}
}
