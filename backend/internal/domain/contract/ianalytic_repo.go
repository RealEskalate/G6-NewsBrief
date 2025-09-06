package contract

import (
	"context"

	"github.com/RealEskalate/G6-NewsBrief/internal/domain/entity"
)

// IAnalyticRepository defines methods for accessing and manipulating analytic data.
type IAnalyticRepository interface {
	InitializeAnalytics(ctx context.Context) error
	IncrementTotalTopic(ctx context.Context) error
	IncrementTotalNews(ctx context.Context) error
	IncrementTotalSource(ctx context.Context) error
	IncrementTotalUser(ctx context.Context) error
	GetAnalytics(ctx context.Context) (entity.Analytic, error)
}
