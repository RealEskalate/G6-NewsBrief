package usecase

import (
	"errors"
	"time"

	"github.com/RealEskalate/G6-NewsBrief/internal/domain/contract"
	"github.com/RealEskalate/G6-NewsBrief/internal/domain/entity"
)

type TranslatorUsecase struct {
	translatorClient contract.ITranslationClient
	newsRepo         contract.INewsRepository
}

func NewsTranslatorUsecase(client contract.ITranslationClient, repo contract.INewsRepository) contract.ITranslatorService {
	return &TranslatorUsecase{
		translatorClient: client,
		newsRepo:         repo,
	}
}

func (uc *TranslatorUsecase) Translate(text, sourceLang, targetLang string) (string, error) {
	return uc.translatorClient.Translate(text, sourceLang, targetLang)
}

func (uc *TranslatorUsecase) TranslateNews(news entity.News) (entity.News, error) {
	// Translate whichever summary exists to the other language.
	var (
		srcText string
		srcLang string
		tgtLang string
	)

	switch {
	case news.SummaryEN != "" && news.SummaryAM == "":
		srcText, srcLang, tgtLang = news.SummaryEN, "en", "am"
	case news.SummaryAM != "" && news.SummaryEN == "":
		srcText, srcLang, tgtLang = news.SummaryAM, "am", "en"
	case news.SummaryEN != "" && news.SummaryAM != "":
		// Both summaries exist; nothing to do.
		news.UpdatedAt = time.Now()
		return news, nil
	default:
		return news, errors.New("no summary available to translate")
	}

	translated, err := uc.translatorClient.Translate(srcText, srcLang, tgtLang)
	if err != nil {
		return news, err
	}

	if tgtLang == "en" {
		news.SummaryEN = translated
	} else {
		news.SummaryAM = translated
	}
	news.UpdatedAt = time.Now()
	if err := uc.newsRepo.Update(&news); err != nil {
		return news, err
	}

	return news, nil
}
