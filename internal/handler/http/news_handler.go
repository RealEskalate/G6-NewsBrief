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
