package main

import (
	"log"
	"os"

	handlerHttp "github.com/RealEskalate/G6-NewsBrief/internal/handler/http"
	"github.com/RealEskalate/G6-NewsBrief/internal/infrastructure/config"
	database "github.com/RealEskalate/G6-NewsBrief/internal/infrastructure/database"
	"github.com/RealEskalate/G6-NewsBrief/internal/infrastructure/external_services"
	"github.com/RealEskalate/G6-NewsBrief/internal/infrastructure/jwt"
	"github.com/RealEskalate/G6-NewsBrief/internal/infrastructure/logger"
	passwordservice "github.com/RealEskalate/G6-NewsBrief/internal/infrastructure/password_service"
	randomgenerator "github.com/RealEskalate/G6-NewsBrief/internal/infrastructure/random_generator"
	"github.com/RealEskalate/G6-NewsBrief/internal/infrastructure/repository/mongodb"
	"github.com/RealEskalate/G6-NewsBrief/internal/infrastructure/uuidgen"
	"github.com/RealEskalate/G6-NewsBrief/internal/infrastructure/validator"
	"github.com/RealEskalate/G6-NewsBrief/internal/usecase"
	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
)

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
	smtpHost := os.Getenv("EMAIL_HOST")
	smtpPort := os.Getenv("EMAIL_PORT")
	smtpUsername := os.Getenv("EMAIL_USERNAME")
	smtpPassword := os.Getenv("EMAIL_APP_PASSWORD")
	smtpFrom := os.Getenv("EMAIL_FROM")

	// Register custom validators
	validator.RegisterCustomValidators()

	// Initialize Gin router
	router := gin.Default()

	// Dependency Injection: Repositories
	userCollection := mongoClient.Client.Database(dbName).Collection("users")
	userRepo := mongodb.NewMongoUserRepository(userCollection)
	newsRepo := mongodb.NewNewsRepositoryMongo(mongoClient.Client.Database(dbName).Collection("news"))
	tokenRepo := mongodb.NewTokenRepository(mongoClient.Client.Database(dbName).Collection("tokens"))

	// Dependency Injection: Services
	hasher := passwordservice.NewHasher()
	jwtSecret := os.Getenv("JWT_SECRET")
	if jwtSecret == "" {
		log.Fatal("JWT_SECRET environment variable not set")
	}
	jwtManager := jwt.NewJWTManager(jwtSecret)
	jwtService := jwt.NewJWTService(jwtManager)
	appLogger := logger.NewStdLogger()
	mailService := external_services.NewEmailService(smtpHost, smtpPort, smtpUsername, smtpPassword, smtpFrom)
	randomGenerator := randomgenerator.NewRandomGenerator()
	appValidator := validator.NewValidator()
	uuidGenerator := uuidgen.NewGenerator()
	appConfig := config.NewConfig()
	// config
	baseURL := appConfig.GetAppBaseURL()
	// External services
	summarizerAPI := os.Getenv("GEMINI_API_URL")
	GeminiAPIKey := os.Getenv("GEMINI_API_KEY")
	if summarizerAPI == "" {
		log.Fatal("GEMINI_API_URL environment variable not set")
	}
	geminiClient := external_services.NewGeminiClient(GeminiAPIKey, summarizerAPI)

	// Dependency Injection: Usecases
	emailUsecase := usecase.NewEmailVerificationUseCase(tokenRepo, userRepo, mailService, randomGenerator, uuidGenerator, baseURL)
	userUsecase := usecase.NewUserUsecase(userRepo, tokenRepo, emailUsecase, hasher, jwtService, mailService, appLogger, appConfig, appValidator, uuidGenerator, randomGenerator)

	// Pass Prometheus metrics to handlers or usecases as needed (import from metrics package)

	// Setup API routes
	appRouter := handlerHttp.NewRouter(
		userUsecase, emailUsecase,
		userRepo, tokenRepo, hasher, jwtService, mailService,
		appLogger, appConfig, appValidator, uuidGenerator, randomGenerator,
		newsRepo, geminiClient,
	)
	appRouter.SetupRoutes(router)

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
