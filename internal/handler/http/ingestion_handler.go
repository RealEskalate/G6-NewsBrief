package http

import (
	"net/http"

	"github.com/RealEskalate/G6-NewsBrief/internal/domain/contract"
	"github.com/RealEskalate/G6-NewsBrief/internal/domain/entity"
	"github.com/RealEskalate/G6-NewsBrief/internal/handler/http/dto"
	"github.com/gin-gonic/gin"
)

type IngestionHandler struct {
	ingestionUC contract.INewsIngestionService
}

func NewIngestionHandler(ingestionUC contract.INewsIngestionService) *IngestionHandler {
	return &IngestionHandler{ingestionUC: ingestionUC}
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
