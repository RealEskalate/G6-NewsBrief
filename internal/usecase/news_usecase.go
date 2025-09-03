package usecase

import (
	"github.com/RealEskalate/G6-NewsBrief/internal/domain/contract"
	"github.com/RealEskalate/G6-NewsBrief/internal/domain/entity"
)

type newsUsecase struct {
	repo contract.INewsRepository
}

func NewNewsUsecase(repo contract.INewsRepository) contract.INewsUsecase {
	return &newsUsecase{repo: repo}
}

func (u *newsUsecase) ListNews(page, limit int) ([]*entity.News, int64, int, error) {
	if limit <= 0 {
		limit = 10
	}
	return u.repo.FindAll(page, limit)
}
