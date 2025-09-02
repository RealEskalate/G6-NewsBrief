package http

import (
	"time"

	"github.com/RealEskalate/G6-NewsBrief/internal/domain/contract"
	"github.com/RealEskalate/G6-NewsBrief/internal/handler/http/middleware"
	"github.com/RealEskalate/G6-NewsBrief/internal/infrastructure/external_services"
	"github.com/RealEskalate/G6-NewsBrief/internal/usecase"
	"github.com/didip/tollbooth/v7"
	"github.com/didip/tollbooth/v7/limiter"
	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
)

type Router struct {
	userHandler       *UserHandler
	emailHandler      *EmailHandler
	userUsecase       *usecase.UserUsecase
	jwtService        contract.IJWTService
	authHandler       *AuthHandler
	summarizerHandler *SummarizeHandler
	ingestionHandler  *IngestionHandler
	chatHandler       *ChatHandler
	translatorHandler *TranslatorHandler
}

func NewRouter(userUsecase contract.IUserUseCase, emailVerUC contract.IEmailVerificationUC, userRepo contract.IUserRepository, tokenRepo contract.ITokenRepository, hasher contract.IHasher, jwtService contract.IJWTService, mailService contract.IEmailService, logger contract.IAppLogger, config contract.IConfigProvider, validator contract.IValidator, uuidGen contract.IUUIDGenerator, randomGen contract.IRandomGenerator, newsRepo contract.INewsRepository, geminiClient contract.IGeminiClient) *Router {
	baseURL := config.GetAppBaseURL()
	summarizerUC := usecase.NewsSummarizerUsecase(geminiClient, newsRepo)
	ingestionUC := usecase.NewNewsIngestionUsecase(geminiClient, newsRepo)
	chatbotUC := usecase.NewChatbotUsecase(geminiClient, newsRepo)
	translatorClient := external_services.NewTranslatorClient()
	translatorUC := usecase.NewsTranslatorUsecase(translatorClient, newsRepo)
	return &Router{
		userHandler: NewUserHandler(userUsecase),

		emailHandler:      NewEmailHandler(emailVerUC, userRepo),
		userUsecase:       usecase.NewUserUsecase(userRepo, tokenRepo, emailVerUC, hasher, jwtService, mailService, logger, config, validator, uuidGen, randomGen),
		jwtService:        jwtService,
		authHandler:       NewAuthHandler(userUsecase, baseURL),
		summarizerHandler: NewsSummarizeHandler(summarizerUC),
		ingestionHandler:  NewIngestionHandler(ingestionUC),
		chatHandler:       NewChatHandler(chatbotUC),
		translatorHandler: NewTranslatorHandler(translatorUC, newsRepo),
	}
}

func (r *Router) SetupRoutes(router *gin.Engine) {
	router.Use(cors.New(cors.Config{
		AllowOrigins:     []string{"*"},
		AllowMethods:     []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
		AllowHeaders:     []string{"Origin", "Content-Type", "Authorization", "Accept"},
		ExposeHeaders:    []string{"Content-Length"},
		AllowCredentials: true,
		MaxAge:           12 * time.Hour,
	}))
	// rate limiter configuration
	lmt := tollbooth.NewLimiter(10, &limiter.ExpirableOptions{DefaultExpirationTTL: time.Hour})
	lmt.SetIPLookups([]string{"RemoteAddr", "X-Forwarded-For", "X-Real-IP"})
	lmt.SetMessage("Too many requests, please try again later.")
	router.Use(middleware.RateLimiter(lmt))

	// router.GET("/metrics", gin.WrapH(promhttp.Handler()))
	// router.GET("/api/v1/metrics", gin.WrapH(promhttp.Handler()))
	// API v1 routes
	v1 := router.Group("/api/v1")

	// Public routes (no authentication required)
	auth := v1.Group("/auth")
	{
		auth.POST("/register", r.userHandler.CreateUser)
		auth.POST("/login", r.userHandler.Login)
		auth.GET("/verify-email", r.emailHandler.HandleVerifyEmailToken)
		auth.POST("/forgot-password", r.userHandler.ForgotPassword)
		auth.POST("/reset-password", r.userHandler.ResetPassword)
		auth.POST("/refresh-token", r.userHandler.RefreshToken)

		auth.POST("/request-verification-email", r.emailHandler.HandleRequestEmailVerification)

		// Google OAuth endpoints
		auth.GET("/google/login", r.authHandler.HandleGoogleLogin)
		auth.GET("/google/callback", r.authHandler.HandleGoogleCallback)
	}

	// Public user routes
	users := v1.Group("/users")
	{
		users.GET("/profile/:id", r.userHandler.GetUser)
	}

	// Protected routes (authentication required)
	protected := v1.Group("/")
	protected.Use(middleware.AuthMiddleWare(r.jwtService, r.userUsecase))
	{
		// Current user routes
		protected.GET("/me", r.userHandler.GetCurrentUser)
		protected.PUT("/me", r.userHandler.UpdateUser)

	}

	// Logout route (no authentication required just accept the refresh token from the request body and invalidate the user session)
	v1.POST("/logout", r.userHandler.Logout)

	// Utilities
	v1.POST("/summarize", r.summarizerHandler.Summarize)
	v1.POST("/news/ingest", r.ingestionHandler.IngestNews)
	// Chat endpoints
	v1.POST("/chat/general", r.chatHandler.ChatGeneral)
	v1.POST("/chat/news/:id", r.chatHandler.ChatForNews)
	// Translation endpoints
	v1.POST("/translate", r.translatorHandler.Translate)
	v1.POST("/news/:id/translate", r.translatorHandler.TranslateNews)
}
