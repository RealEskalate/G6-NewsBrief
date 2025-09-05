package http

import (
	"net/http"
	"strings"

	"github.com/RealEskalate/G6-NewsBrief/internal/domain/contract"
	"github.com/RealEskalate/G6-NewsBrief/internal/domain/entity"
	"github.com/RealEskalate/G6-NewsBrief/internal/handler/http/dto"
	"github.com/gin-gonic/gin"
)

type TopicHandler struct {
	topicUsecase contract.ITopicUsecase
	userUsecase  contract.IUserUseCase
	uuidGen      contract.IUUIDGenerator
}

func NewTopicHandler(topicUC contract.ITopicUsecase, userUC contract.IUserUseCase, uuidGen contract.IUUIDGenerator) *TopicHandler {
	return &TopicHandler{
		topicUsecase: topicUC,
		userUsecase:  userUC,
		uuidGen:      uuidGen,
	}
}
func (h *TopicHandler) CreateTopic(c *gin.Context) {
	var topicDTO dto.TopicDTO
	if err := c.ShouldBindJSON(&topicDTO); err != nil {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{Error: "Invalid request payload"})
		return
	}

	topic := entity.Topic{
		ID:   h.uuidGen.NewUUID(),
		Slug: topicDTO.Slug,
		Label: entity.BilingualField{
			EN: topicDTO.Label.EN,
			AM: topicDTO.Label.AM,
		},
		StoryCount: 0,
	}

	userRole, exists := c.Get("userRole")
	if !exists || userRole != "admin" {
		c.JSON(http.StatusForbidden, dto.ErrorResponse{Error: "Forbidden: Admins only"})
		return
	}

	if err := h.topicUsecase.CreateTopic(c.Request.Context(), &topic); err != nil {
		c.JSON(http.StatusInternalServerError, dto.ErrorResponse{Error: "Failed to create topic"})
		return
	}

	c.JSON(http.StatusCreated, dto.MessageResponse{Message: "Topic created successfully"})
}

// GetTopics handles the GET /v1/topics request.
func (h *TopicHandler) GetTopics(c *gin.Context) {
	topics, err := h.topicUsecase.ListAll(c.Request.Context())
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve topics"})
		return
	}

	response := dto.TopicsResponseDTO{
		Topics:      dto.MapTopicsToDTOs(topics),
		TotalTopics: len(topics),
	}

	c.JSON(http.StatusOK, response)
}

// add topic for the user
func (h *TopicHandler) SubscribeTopic(c *gin.Context) {
	userID := c.GetString("userID")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, dto.ErrorResponse{Error: "Unauthorized"})
		return
	}
	var req dto.SubscribeTopicsRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{Error: "Invalid request payload"})
		return
	}
	// if len == 0, just return 200 with empty message as per requirement
	if len(req.Topics) == 0 {
		c.JSON(http.StatusOK, dto.MessageResponse{Message: ""})
		return
	}
	if err := h.userUsecase.SubscribeTopics(c.Request.Context(), userID, req.Topics); err != nil {
		// Map known validation/errors to appropriate status codes for clarity
		msg := err.Error()
		switch {
		case strings.Contains(msg, "topics not found"):
			c.JSON(http.StatusBadRequest, dto.ErrorResponse{Error: msg})
			return
		case strings.Contains(msg, "invalid topic id"):
			c.JSON(http.StatusBadRequest, dto.ErrorResponse{Error: msg})
			return
		case strings.Contains(msg, "user not found"):
			c.JSON(http.StatusNotFound, dto.ErrorResponse{Error: msg})
			return
		default:
			c.JSON(http.StatusInternalServerError, dto.ErrorResponse{Error: "Failed to subscribe to topics"})
			return
		}
	}
	c.JSON(http.StatusOK, dto.MessageResponse{Message: "Subscribed to topic successfully"})
}

// UnsubscribeTopic removes a single topic for the user
func (h *TopicHandler) UnsubscribeTopic(c *gin.Context) {
	userID := c.GetString("userID")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, dto.ErrorResponse{Error: "Unauthorized"})
		return
	}
	topicID := c.Param("topicID")
	if topicID == "" {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{Error: "Topic ID is required"})
		return
	}
	if err := h.userUsecase.UnsubscribeTopic(c.Request.Context(), userID, topicID); err != nil {
		msg := err.Error()
		switch {
		case strings.Contains(msg, "topic not found"):
			c.JSON(http.StatusNotFound, dto.ErrorResponse{Error: msg})
			return
		case strings.Contains(msg, "user not found"):
			c.JSON(http.StatusNotFound, dto.ErrorResponse{Error: msg})
			return
		default:
			c.JSON(http.StatusInternalServerError, dto.ErrorResponse{Error: "Failed to unsubscribe from topic"})
			return
		}
	}
	c.JSON(http.StatusOK, dto.MessageResponse{Message: "Unsubscribed from topic successfully"})
}

func (h *TopicHandler) GetUserSubscribedTopics(c *gin.Context) {
	userID := c.GetString("userID")

	if userID == "" {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{Error: "User ID is required"})
		return
	}

	topics, err := h.userUsecase.GetUserSubscribedTopics(c.Request.Context(), userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, dto.ErrorResponse{Error: "Failed to retrieve subscribed topics"})
		return
	}

	c.JSON(http.StatusOK, topics)
}
