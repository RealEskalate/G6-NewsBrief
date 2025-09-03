package contract

import "github.com/RealEskalate/G6-NewsBrief/internal/domain/entity"

type INewsUsecase interface {
	// ListNews returns paginated news, total count, and total pages
	ListNews(page, limit int) ([]*entity.News, int64, int, error)
}
