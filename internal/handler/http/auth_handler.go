package http

import (
	"context"
	"crypto/rand"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"github.com/RealEskalate/G6-NewsBrief/internal/domain/contract"
	"github.com/gin-gonic/gin"
	"golang.org/x/oauth2"
	"golang.org/x/oauth2/google"
	"net/http"
	"os"
	"time"
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

	// Fallback: return JSON if no frontend URL is configured
	ctx.JSON(http.StatusOK, gin.H{
		"message":       "login successful",
		"access_token":  accessToken,
		"refresh_token": refreshToken,
	})
}
