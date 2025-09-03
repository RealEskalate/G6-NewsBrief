package contract

import (
	"github.com/RealEskalate/G6-NewsBrief/internal/domain/entity"
)

type ITranslatorService interface {
	Translate(text, sourceLang, targetLang string) (string, error)
	TranslateNews(news entity.News) (entity.News, error)
}