package http

import (
	"context"
	"crypto/rand"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"net/http"
	"net/url"
	"os"
	"time"

	"github.com/RealEskalate/G6-NewsBrief/internal/domain/contract"
	"github.com/RealEskalate/G6-NewsBrief/internal/handler/http/middleware"
	"github.com/gin-gonic/gin"
	"golang.org/x/oauth2"
	"golang.org/x/oauth2/google"
	"google.golang.org/api/idtoken"
)

type AuthHandler struct {
	UserUseCase contract.IUserUseCase
	BaseURL     string
	config      contract.IConfigProvider
	jwtService  contract.IJWTService
}

func NewAuthHandler(uc contract.IUserUseCase, baseURL string, config contract.IConfigProvider, jwtSvc contract.IJWTService) *AuthHandler {
	return &AuthHandler{
		UserUseCase: uc,
		BaseURL:     baseURL,
		config:      config,
		jwtService:  jwtSvc,
	}
}

type UserInfo struct {
	Email string `json:"email"`
	Name  string `json:"name"`
}

func (h *AuthHandler) googleOauthConfig() *oauth2.Config {
	return &oauth2.Config{
		ClientID:     os.Getenv("GOOGLE_CLIENT_ID"),
		ClientSecret: os.Getenv("GOOGLE_CLIENT_SECRET"),
		RedirectURL:  h.BaseURL + "/api/v1/auth/google/callback",
		Scopes:       []string{"openid", "email", "profile"},
		Endpoint:     google.Endpoint,
	}
}

func (h *AuthHandler) HandleGoogleLogin(ctx *gin.Context) {
	// Generate OAuth state with platform information
	b := make([]byte, 16)
	if _, err := rand.Read(b); err != nil {
		ctx.String(http.StatusInternalServerError, "failed to generate state")
		return
	}
	oauthStateString := base64.URLEncoding.EncodeToString(b)
	cookieSecure := os.Getenv("OAUTH2_SET_COOKIE_SECURE") == "true"
	ctx.SetCookie("oauthState", oauthStateString, 300, "/", "", cookieSecure, true)

	url := h.googleOauthConfig().AuthCodeURL(oauthStateString)
	ctx.Redirect(http.StatusTemporaryRedirect, url)
}

func (h *AuthHandler) HandleGoogleCallback(ctx *gin.Context) {
	state := ctx.Query("state")
	cookieState, err := ctx.Cookie("oauthState")

	if err != nil || state != cookieState {
		ctx.String(http.StatusUnauthorized, "invalid CSRF state token\n")
		return
	}
	cookieSecure := os.Getenv("OAUTH2_SET_COOKIE_SECURE") == "true"
	ctx.SetCookie("oauthState", "", -1, "/", "", cookieSecure, true)

	code := ctx.Query("code")
	if code == "" {
		ctx.String(http.StatusBadRequest, "authorization code not provided")
		return
	}

	// Use a short timeout for the OAuth exchange and userinfo fetch
	requestCtx, cancel := context.WithTimeout(ctx.Request.Context(), 10*time.Second)
	defer cancel()

	token, err := h.googleOauthConfig().Exchange(requestCtx, code)
	if err != nil {
		ctx.String(http.StatusInternalServerError, fmt.Sprintf("failed to exchange authorization for token: %v\n", err))
		return
	}

	client := h.googleOauthConfig().Client(requestCtx, token)
	resp, err := client.Get("https://www.googleapis.com/oauth2/v3/userinfo")

	if err != nil {
		ctx.String(http.StatusInternalServerError, fmt.Sprintf("Failed to get user info: %v", err))
		return
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		ctx.String(resp.StatusCode, "failed to get user info")
		return
	}

	var userInfo UserInfo
	if err := json.NewDecoder(resp.Body).Decode(&userInfo); err != nil {
		ctx.String(http.StatusInternalServerError, fmt.Sprintf("Failed to decode user info: %v\n", err))
		return
	}
	fullname := userInfo.Name

	accessToken, refreshToken, err := h.UserUseCase.LoginWithOAuth(requestCtx, fullname, userInfo.Email)

	if err != nil {
		ctx.String(http.StatusInternalServerError, fmt.Sprintf("failed to login with OAuth: %v\n", err))
		return
	}

	// Device-aware behavior: mobile gets JSON, web redirects to frontend
	device := middleware.GetDeviceInfo(ctx)
	platform := ctx.Query("platform")
	isMobile := platform == "mobile"
	if device != nil {
		isMobile = isMobile || device.IsMobile || (device.Platform == "Android" || device.Platform == "iOS")
	}
	fmt.Printf("isMobile: %v, device: %+v\n", isMobile, device)

	frontend := h.config.GetFrontendBaseURL()
	mobile := h.config.GetFrontendMobileBaseURL()

	if isMobile {
		// Prefer mobile deep link if configured
		if mobile != "" {
			u, _ := url.Parse(mobile)
			u.Path = "/auth/callback"
			q := u.Query()
			q.Set("access_token", accessToken)
			q.Set("refresh_token", refreshToken)
			u.RawQuery = q.Encode()
			ctx.Redirect(http.StatusFound, u.String())
			return
		}
		ctx.JSON(http.StatusOK, gin.H{
			"message":       "login successful",
			"access_token":  accessToken,
			"refresh_token": refreshToken,
		})
		return
	}

	if frontend != "" {
		u, _ := url.Parse(frontend)
		u.Path = "/auth/success"
		q := u.Query()
		q.Set("access_token", accessToken)
		q.Set("refresh_token", refreshToken)
		// Add user ID if we can parse the token
		if claims, err := h.jwtService.ParseAccessToken(accessToken); err == nil {
			q.Set("user_id", claims.UserID)
		}
		u.RawQuery = q.Encode()
		ctx.Redirect(http.StatusFound, u.String())
		return
	}

	// Fallback JSON if no frontend configured
	ctx.JSON(http.StatusOK, gin.H{
		"message":       "login successful",
		"access_token":  accessToken,
		"refresh_token": refreshToken,
	})
}

// MobileGoogleTokenRequest represents the payload sent by mobile clients using native Google Sign-In
type MobileGoogleTokenRequest struct {
	IDToken string `json:"id_token" binding:"required"`
}

// HandleGoogleMobileToken verifies a Google ID token from a mobile client and issues app tokens
func (h *AuthHandler) HandleGoogleMobileToken(ctx *gin.Context) {
	var req MobileGoogleTokenRequest
	if err := ctx.ShouldBindJSON(&req); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "invalid request body"})
		return
	}

	webClientID := os.Getenv("GOOGLE_CLIENT_ID")
	if webClientID == "" {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": "GOOGLE_CLIENT_ID not configured"})
		return
	}

	requestCtx, cancel := context.WithTimeout(ctx.Request.Context(), 10*time.Second)
	defer cancel()

	payload, err := idtoken.Validate(requestCtx, req.IDToken, webClientID)
	if err != nil {
		ctx.JSON(http.StatusUnauthorized, gin.H{"error": "invalid id_token"})
		return
	}

	email, _ := payload.Claims["email"].(string)
	name, _ := payload.Claims["name"].(string)
	if name == "" {
		given, _ := payload.Claims["given_name"].(string)
		family, _ := payload.Claims["family_name"].(string)
		if given != "" || family != "" {
			if given != "" && family != "" {
				name = fmt.Sprintf("%s %s", given, family)
			} else if given != "" {
				name = given
			} else {
				name = family
			}
		}
	}
	if email == "" {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "email not present in id_token"})
		return
	}

	accessToken, refreshToken, err := h.UserUseCase.LoginWithOAuth(requestCtx, name, email)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": "failed to login with OAuth"})
		return
	}

	ctx.JSON(http.StatusOK, gin.H{
		"message":       "login successful",
		"access_token":  accessToken,
		"refresh_token": refreshToken,
	})
}
