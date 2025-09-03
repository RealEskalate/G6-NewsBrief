package http

import (
	"net/http"

	"github.com/RealEskalate/G6-NewsBrief/internal/domain/contract"
	"github.com/RealEskalate/G6-NewsBrief/internal/handler/http/dto"
	"github.com/gin-gonic/gin"
)

type ChatHandler struct {
	chatbotUC contract.IChatbotService
}

func NewChatHandler(chatbotUC contract.IChatbotService) *ChatHandler {
	return &ChatHandler{chatbotUC: chatbotUC}
}

// ChatGeneral handles general chat about news.
func (h *ChatHandler) ChatGeneral(c *gin.Context) {
	var req dto.ChatRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{Error: "Invalid request payload"})
		return
	}
	sessionID := c.GetHeader("X-Session-ID")
	reply, err := h.chatbotUC.ChatGeneral(sessionID, req.Message)
	if err != nil {
		c.JSON(http.StatusInternalServerError, dto.ErrorResponse{Error: err.Error()})
		return
	}
	c.JSON(http.StatusOK, dto.ChatResponse{Reply: reply})
}

// ChatForNews handles chat restricted to a specific news item.
func (h *ChatHandler) ChatForNews(c *gin.Context) {
	var req dto.ChatRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{Error: "Invalid request payload"})
		return
	}
	newsID := c.Param("id")
	sessionID := c.GetHeader("X-Session-ID")
	reply, err := h.chatbotUC.ChatForNews(newsID, sessionID, req.Message)
	if err != nil {
		c.JSON(http.StatusInternalServerError, dto.ErrorResponse{Error: err.Error()})
		return
	}
	c.JSON(http.StatusOK, dto.ChatResponse{Reply: reply})
}
