package contract

import (
	"context"

	"github.com/RealEskalate/G6-NewsBrief/internal/domain/entity"
)

type IBookmarkRepository interface {
	Save(ctx context.Context, b entity.Bookmark) error
	Delete(ctx context.Context, userID, newsID string) error
	Exists(ctx context.Context, userID, newsID string) (bool, error)
	GetBookmarkedFlags(ctx context.Context, userID string, newsIDs []string) (map[string]bool, error)
	ListByUser(ctx context.Context, userID string, page, limit int) ([]entity.Bookmark, int64, int, error)
}
