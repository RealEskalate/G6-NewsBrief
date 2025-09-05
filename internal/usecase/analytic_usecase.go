package usecase

import (
	"context"

	"github.com/RealEskalate/G6-NewsBrief/internal/domain/contract"
	"github.com/RealEskalate/G6-NewsBrief/internal/domain/entity"
)

type AnalyticUsecase struct {
	analyticRepo contract.IAnalyticRepository
}

func NewAnalyticUsecase(analyticRepo contract.IAnalyticRepository) contract.IAnalyticUsecase {
	return &AnalyticUsecase{
		analyticRepo: analyticRepo,
	}
}

func (uc *AnalyticUsecase) InitializeAnalytics(ctx context.Context) error {
	return uc.analyticRepo.InitializeAnalytics(ctx)
}

func (uc *AnalyticUsecase) GetAnalytics(ctx context.Context) (entity.Analytic, error) {
	return uc.analyticRepo.GetAnalytics(ctx)
}
