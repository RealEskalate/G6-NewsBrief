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
	// ListByTopicID returns paginated news for a given topic ID
	ListByTopicID(ctx context.Context, topicID string, page, limit int) ([]*entity.News, int64, int, error)
	// ListTrending returns paginated trending news sorted by recency
	ListTrending(page, limit int) ([]*entity.News, int64, int, error)
	// ListToday returns top-N news for today only (fixed 4 by default)
	ListToday(limit int) ([]*entity.News, int64, int, error)
	// allow admin to create news
	AdminCreateNews(ctx context.Context, title, body, language, sourceID string, topicIDs []string) (*entity.News, error)
}
