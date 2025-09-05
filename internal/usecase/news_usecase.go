package usecase

import (
	"context"

	"github.com/RealEskalate/G6-NewsBrief/internal/domain/contract"
	"github.com/RealEskalate/G6-NewsBrief/internal/domain/entity"
)

type newsUsecase struct {
	repo       contract.INewsRepository
	userRepo   contract.IUserRepository
	sourceRepo contract.ISourceRepository
}

func NewNewsUsecase(repo contract.INewsRepository, userRepo contract.IUserRepository, sourceRepo contract.ISourceRepository) contract.INewsUsecase {
	return &newsUsecase{repo: repo, userRepo: userRepo, sourceRepo: sourceRepo}
}

func (u *newsUsecase) ListNews(page, limit int) ([]*entity.News, int64, int, error) {
	if limit <= 0 {
		limit = 10
	}
	return u.repo.FindAll(page, limit)
}

// ListForYou lists news only from the user's subscribed sources
func (u *newsUsecase) ListForYou(ctx context.Context, userID string, page, limit int) ([]*entity.News, int64, int, error) {
	if limit <= 0 {
		limit = 10
	}
	// Get subscribed source slugs from user profile
	slugs, err := u.userRepo.GetSourceSubscriptions(ctx, userID)
	if err != nil {
		return nil, 0, 0, err
	}
	if len(slugs) == 0 {
		return []*entity.News{}, 0, 0, nil
	}
	// Resolve slugs to Source IDs
	ids := make([]string, 0, len(slugs))
	for _, slug := range slugs {
		if slug == "" {
			continue
		}
		src, err := u.sourceRepo.GetBySlug(ctx, slug)
		if err != nil || src == nil || src.ID == "" {
			continue
		}
		ids = append(ids, src.ID)
	}
	if len(ids) == 0 {
		return []*entity.News{}, 0, 0, nil
	}
	return u.repo.FindBySourceIDs(ids, page, limit)
}
