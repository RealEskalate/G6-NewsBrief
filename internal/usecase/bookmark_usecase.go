package usecase

import (
	"context"
	"time"

	"github.com/RealEskalate/G6-NewsBrief/internal/domain/contract"
	"github.com/RealEskalate/G6-NewsBrief/internal/domain/entity"
)

type bookmarkUsecase struct {
	repo     contract.IBookmarkRepository
	newsRepo contract.INewsRepository
	uuidGen  contract.IUUIDGenerator
}

func NewBookmarkUsecase(repo contract.IBookmarkRepository, newsRepo contract.INewsRepository, uuidGen contract.IUUIDGenerator) contract.IBookmarkUsecase {
	return &bookmarkUsecase{repo: repo, newsRepo: newsRepo, uuidGen: uuidGen}
}

func (u *bookmarkUsecase) Save(ctx context.Context, userID, newsID string) error {
	exists, err := u.repo.Exists(ctx, userID, newsID)
	if err != nil {
		return err
	}
	if exists {
		return contract.ErrAlreadyBookmarked
	}
	b := entity.Bookmark{ID: u.uuidGen.NewUUID(), UserID: userID, NewsID: newsID, CreatedAt: time.Now().UTC()}
	return u.repo.Save(ctx, b)
}

func (u *bookmarkUsecase) Unsave(ctx context.Context, userID, newsID string) error {
	return u.repo.Delete(ctx, userID, newsID)
}

func (u *bookmarkUsecase) List(ctx context.Context, userID string, page, limit int) ([]*entity.News, int64, int, error) {
	rows, total, totalPages, err := u.repo.ListByUser(ctx, userID, page, limit)
	if err != nil {
		return nil, 0, 0, err
	}
	ids := make([]string, 0, len(rows))
	for _, r := range rows {
		ids = append(ids, r.NewsID)
	}
	news, err := u.newsRepo.FindByIDs(ctx, ids)
	if err != nil {
		return nil, 0, 0, err
	}
	return news, total, totalPages, nil
}

func (u *bookmarkUsecase) Flags(ctx context.Context, userID string, newsIDs []string) (map[string]bool, error) {
	return u.repo.GetBookmarkedFlags(ctx, userID, newsIDs)
}
