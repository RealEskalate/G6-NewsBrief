package http

import (
	"net/http"

	"github.com/RealEskalate/G6-NewsBrief/internal/domain/contract"
	"github.com/RealEskalate/G6-NewsBrief/internal/domain/entity"
	"github.com/RealEskalate/G6-NewsBrief/internal/handler/http/dto"
	"github.com/gin-gonic/gin"
)

type TranslatorHandler struct {
	translatorUC contract.ITranslatorService
	newsRepo     contract.INewsRepository
}

func NewTranslatorHandler(translatorUC contract.ITranslatorService, newsRepo contract.INewsRepository) *TranslatorHandler {
	return &TranslatorHandler{translatorUC: translatorUC, newsRepo: newsRepo}
}

// Translate text endpoint
func (h *TranslatorHandler) Translate(c *gin.Context) {
	var req dto.TranslateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{Error: "Invalid request payload"})
		return
	}
	translated, err := h.translatorUC.Translate(req.Text, req.SourceLang, req.TargetLang)
	if err != nil {
		c.JSON(http.StatusInternalServerError, dto.ErrorResponse{Error: err.Error()})
		return
	}
	c.JSON(http.StatusOK, dto.TranslateResponse{TranslatedText: translated})
}

// TranslateNews translates the summary field of a news record and persists it.
func (h *TranslatorHandler) TranslateNews(c *gin.Context) {
	id := c.Param("id")
	news, err := h.newsRepo.FindByID(id)
	if err != nil {
		c.JSON(http.StatusNotFound, dto.ErrorResponse{Error: "news not found"})
		return
	}
	updated, err := h.translatorUC.TranslateNews(*news)
	if err != nil {
		c.JSON(http.StatusInternalServerError, dto.ErrorResponse{Error: err.Error()})
		return
	}
	c.JSON(http.StatusOK, entity.News{
		ID:          updated.ID,
		Title:       updated.Title,
		Body:        updated.Body,
		SummaryEN:   updated.SummaryEN,
		SummaryAM:   updated.SummaryAM,
		Language:    updated.Language,
		Source:      updated.Source,
		PublishedAt: updated.PublishedAt,
		CreatedAt:   updated.CreatedAt,
		UpdatedAt:   updated.UpdatedAt,
	})
}
