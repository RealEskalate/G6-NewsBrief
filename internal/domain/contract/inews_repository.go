package contract

import (
	"github.com/RealEskalate/G6-NewsBrief/internal/domain/entity"
)

type INewsRepository interface {
	Save(news *entity.News) error
	Update(news *entity.News) error
	FindByID(id string) (*entity.News, error)
	FindAll(page, limit int) ([]*entity.News,int64, int, error)
	// Delete(id string) error
}