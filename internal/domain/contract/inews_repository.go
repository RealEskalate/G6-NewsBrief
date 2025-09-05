package contract

import (
	"context"

	"github.com/RealEskalate/G6-NewsBrief/internal/domain/entity"
)

type INewsRepository interface {
	Save(news *entity.News) error
	Update(news *entity.News) error
	FindByID(id string) (*entity.News, error)
	FindAll(page, limit int) ([]*entity.News, int64, int, error)
	// create news by admin
	AdminCreateNews(ctx context.Context, news *entity.News) error
	// FindBySourceIDs returns paginated news filtered by a set of source IDs.
	FindBySourceIDs(sourceIDs []string, page, limit int) ([]*entity.News, int64, int, error)
	// FindByIDs returns a list of news by IDs (no pagination, preserves order not guaranteed)
	FindByIDs(ctx context.Context, ids []string) ([]*entity.News, error)
	// Delete(id string) error
}
