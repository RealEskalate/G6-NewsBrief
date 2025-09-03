package http

import (
	"net/http"

	"github.com/RealEskalate/G6-NewsBrief/internal/domain/contract"
	"github.com/RealEskalate/G6-NewsBrief/internal/handler/http/dto"
	"github.com/gin-gonic/gin"
)

type SummarizeHandler struct {
	summarizerUC contract.ISummarizerService
}

func NewsSummarizeHandler(summarizerUC contract.ISummarizerService) *SummarizeHandler {
	return &SummarizeHandler{
		summarizerUC: summarizerUC,
	}
}

func (sh *SummarizeHandler) Summarize(c *gin.Context) {
	var req dto.SummarizeRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, dto.ErrorResponse{Error: "Invalid request payload"})
		return
	}

	summary, err := sh.summarizerUC.Summarize(req.NewsID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, dto.ErrorResponse{Error: err.Error()})
		return
	}

	c.JSON(http.StatusOK, dto.SummarizeResponse{
		NewsID:   summary.NewsID,
		Summary:  summary.Content,
		Language: summary.Language,
	})

}
