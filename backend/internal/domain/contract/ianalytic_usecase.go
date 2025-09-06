package contract

import (
	"context"

	"github.com/RealEskalate/G6-NewsBrief/internal/domain/entity"
)

type IAnalyticUsecase interface {
	InitializeAnalytics(ctx context.Context) error
	GetAnalytics(ctx context.Context) (entity.Analytic, error)
}
