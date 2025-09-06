package http

import (
	"net/http"
	"strings"

	"github.com/RealEskalate/G6-NewsBrief/internal/domain/contract"
	"github.com/RealEskalate/G6-NewsBrief/internal/domain/entity"
	"github.com/RealEskalate/G6-NewsBrief/internal/handler/http/dto"
	"github.com/gin-gonic/gin"
)

type IngestionHandler struct {
	ingestionUC contract.INewsIngestionService
	providerUC  contract.IProviderIngestionUsecase
}

func NewIngestionHandler(ingestionUC contract.INewsIngestionService, providerUC contract.IProviderIngestionUsecase) *IngestionHandler {
	return &IngestionHandler{ingestionUC: ingestionUC, providerUC: providerUC}
}

// IngestNews expects scraped news payload, summarizes it, then persists.
func (h *IngestionHandler) IngestNews(c *gin.Context) {
	var req dto.NewsIngestRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{Error: "Invalid request payload"})
		return
	}

	news := &entity.News{
		Title:       req.Title,
		Body:        req.Body,
		Language:    req.Language,
		SourceID:    req.SourceID,
		Topics:      req.Topics,
		PublishedAt: req.PublishedAt,
	}

	saved, _, err := h.ingestionUC.SaveAfterSummarize(news)
	if err != nil {
		c.JSON(http.StatusInternalServerError, dto.ErrorResponse{Error: err.Error()})
		return
	}

	c.JSON(http.StatusCreated, dto.NewsIngestResponse{
		ID:          saved.ID,
		Title:       saved.Title,
		Language:    saved.Language,
		SourceID:    saved.SourceID,
		Topics:      saved.Topics,
		SummaryEN:   saved.SummaryEN,
		SummaryAM:   saved.SummaryAM,
		PublishedAt: saved.PublishedAt,
		CreatedAt:   saved.CreatedAt,
	})
}

// IngestFromProvider triggers fetching latest news from external provider, summarizes, classifies topics, creates missing topics, then saves
func (h *IngestionHandler) IngestFromProvider(c *gin.Context) {
	userRole, exists := c.Get("userRole")
	if !exists {
		c.JSON(http.StatusForbidden, dto.ErrorResponse{Error: "Forbidden: Admins only"})
		return
	}

	userRoleStr, ok := userRole.(string)
	if !ok || strings.TrimSpace(userRoleStr) != "admin" {
		c.JSON(http.StatusForbidden, dto.ErrorResponse{Error: "Forbidden: Admins only"})
		return
	}
	var req struct {
		Query string `json:"query"`
		TopK  int    `json:"top_k"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{Error: "Invalid request payload"})
		return
	}
	ids, skipped, err := h.providerUC.IngestFromProvider(c.Request.Context(), req.Query, req.TopK)
	if err != nil {
		c.JSON(http.StatusBadGateway, dto.ErrorResponse{Error: err.Error()})
		return
	}
	c.JSON(http.StatusCreated, gin.H{"ingested": len(ids), "ids": ids, "skipped": skipped})
}
