package contract

import (
	"context"

	"github.com/RealEskalate/G6-NewsBrief/internal/domain/entity"
)

type INewsUsecase interface {
	// ListNews returns paginated news, total count, and total pages
	ListNews(page, limit int) ([]*entity.News, int64, int, error)
	// ListForYou returns paginated news for a user based on their subscriptions
	ListForYou(ctx context.Context, userID string, page, limit int) ([]*entity.News, int64, int, error)
	// allow admin to create news
	AdminCreateNews(ctx context.Context, title, body, language, sourceID string, topicIDs []string) (*entity.News, error)
}
