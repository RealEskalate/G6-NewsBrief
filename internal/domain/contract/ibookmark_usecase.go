package contract

import (
	"context"

	"github.com/RealEskalate/G6-NewsBrief/internal/domain/entity"
)

type IBookmarkUsecase interface {
	Save(ctx context.Context, userID, newsID string) error
	Unsave(ctx context.Context, userID, newsID string) error
	List(ctx context.Context, userID string, page, limit int) ([]*entity.News, int64, int, error)
	Flags(ctx context.Context, userID string, newsIDs []string) (map[string]bool, error)
}
