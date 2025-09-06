package http

import (
	"net/http"

	"github.com/RealEskalate/G6-NewsBrief/internal/domain/contract"
	"github.com/gin-gonic/gin"
)

type AnalyticHandler struct {
	analyticUsecase contract.IAnalyticUsecase
}

func NewAnalyticHandler(analyticUC contract.IAnalyticUsecase) *AnalyticHandler {
	return &AnalyticHandler{
		analyticUsecase: analyticUC,
	}
}

func (h *AnalyticHandler) GetAnalytics(ctx *gin.Context) {
	analytics, err := h.analyticUsecase.GetAnalytics(ctx.Request.Context())
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	ctx.JSON(http.StatusOK, analytics)
}
