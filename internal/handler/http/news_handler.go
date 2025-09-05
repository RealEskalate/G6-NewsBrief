package http

import (
	"net/http"
	"strconv"

	"github.com/RealEskalate/G6-NewsBrief/internal/domain/contract"
	"github.com/RealEskalate/G6-NewsBrief/internal/handler/http/dto"
	"github.com/gin-gonic/gin"
)

type NewsHandler struct {
	uc contract.INewsUsecase
}

func NewNewsHandler(uc contract.INewsUsecase) *NewsHandler {
	return &NewsHandler{uc: uc}
}

// GetNews handles GET /api/v1/news?Page=&limit=
func (h *NewsHandler) GetNews(c *gin.Context) {
	pageStr := c.Query("page")
	limitStr := c.Query("limit")
	page := 1
	limit := 10
	if pageStr != "" {
		if p, err := strconv.Atoi(pageStr); err == nil && p > 0 {
			page = p
		}
	}
	if limitStr != "" {
		if l, err := strconv.Atoi(limitStr); err == nil && l > 0 {
			limit = l
		}
	}

	list, total, totalPages, err := h.uc.ListNews(page, limit)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	resp := dto.NewsListResponseDTO{
		News:       dto.MapNewsToDTOs(list),
		Total:      total,
		TotalPages: totalPages,
		Page:       page,
		Limit:      limit,
	}
	c.JSON(http.StatusOK, resp)
}

// GetForYou handles GET /api/v1/me/for-you
func (h *NewsHandler) GetForYou(c *gin.Context) {
	userIDVal, ok := c.Get("userID")
	if !ok {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}
	userID, _ := userIDVal.(string)

	pageStr := c.Query("page")
	limitStr := c.Query("limit")
	page := 1
	limit := 10
	if pageStr != "" {
		if p, err := strconv.Atoi(pageStr); err == nil && p > 0 {
			page = p
		}
	}
	if limitStr != "" {
		if l, err := strconv.Atoi(limitStr); err == nil && l > 0 {
			limit = l
		}
	}

	list, total, totalPages, err := h.uc.ListForYou(c.Request.Context(), userID, page, limit)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	resp := dto.NewsListResponseDTO{
		News:       dto.MapNewsToDTOs(list),
		Total:      total,
		TotalPages: totalPages,
		Page:       page,
		Limit:      limit,
	}
	c.JSON(http.StatusOK, resp)
}

// GetNewsByTopic handles GET /api/v1/topics/:topicID/news
func (h *NewsHandler) GetNewsByTopic(c *gin.Context) {
	topicID := c.Param("topicID")
	if topicID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "topicID is required"})
		return
	}

	pageStr := c.Query("page")
	limitStr := c.Query("limit")
	page := 1
	limit := 10
	if pageStr != "" {
		if p, err := strconv.Atoi(pageStr); err == nil && p > 0 {
			page = p
		}
	}
	if limitStr != "" {
		if l, err := strconv.Atoi(limitStr); err == nil && l > 0 {
			limit = l
		}
	}

	list, total, totalPages, err := h.uc.ListByTopicID(c.Request.Context(), topicID, page, limit)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	resp := dto.NewsListResponseDTO{
		News:       dto.MapNewsToDTOs(list),
		Total:      total,
		TotalPages: totalPages,
		Page:       page,
		Limit:      limit,
	}
	c.JSON(http.StatusOK, resp)
}

// GetTodayNews handles GET /api/v1/news/today (returns exactly 4 items)
func (h *NewsHandler) GetTodayNews(c *gin.Context) {
	limit := 4

	list, total, _, err := h.uc.ListToday(limit)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	resp := dto.NewsListResponseDTO{
		News:       dto.MapNewsToDTOs(list),
		Total:      total,
		TotalPages: 1,
		Page:       1,
		Limit:      limit,
	}
	c.JSON(http.StatusOK, resp)
}

// GetTrendingNews handles GET /api/v1/news/trending?page=&limit=
func (h *NewsHandler) GetTrendingNews(c *gin.Context) {
	pageStr := c.Query("page")
	limitStr := c.Query("limit")
	page := 1
	limit := 10
	if pageStr != "" {
		if p, err := strconv.Atoi(pageStr); err == nil && p > 0 {
			page = p
		}
	}
	if limitStr != "" {
		if l, err := strconv.Atoi(limitStr); err == nil && l > 0 {
			limit = l
		}
	}

	list, total, totalPages, err := h.uc.ListTrending(page, limit)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	resp := dto.NewsListResponseDTO{
		News:       dto.MapNewsToDTOs(list),
		Total:      total,
		TotalPages: totalPages,
		Page:       page,
		Limit:      limit,
	}
	c.JSON(http.StatusOK, resp)
}
