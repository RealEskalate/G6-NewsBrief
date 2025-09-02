package usecase

import (
	"time"

	"github.com/RealEskalate/G6-NewsBrief/internal/domain/contract"
	"github.com/RealEskalate/G6-NewsBrief/internal/domain/entity"
)

// NewsIngestionUsecase ensures news are summarized before persistence.
type NewsIngestionUsecase struct {
	geminiClient contract.IGeminiClient
	newsRepo     contract.INewsRepository
}

func NewNewsIngestionUsecase(geminiClient contract.IGeminiClient, repo contract.INewsRepository) contract.INewsIngestionService {
	return &NewsIngestionUsecase{
		geminiClient: geminiClient,
		newsRepo:     repo,
	}
}

// SaveAfterSummarize summarizes the news then saves it.
func (uc *NewsIngestionUsecase) SaveAfterSummarize(news *entity.News) (*entity.News, entity.Summary, error) {
	// Generate summary based on language
	summaryText, err := uc.geminiClient.Summarize(news.Body, news.Language)
	if err != nil {
		return nil, entity.Summary{}, err
	}

	if news.Language == "en" {
		news.SummaryEN = summaryText
	} else if news.Language == "am" {
		news.SummaryAM = summaryText
	}

	now := time.Now()
	news.CreatedAt = now
	news.UpdatedAt = now

	if err := uc.newsRepo.Save(news); err != nil {
		return nil, entity.Summary{}, err
	}

	summary := entity.Summary{
		NewsID:    news.ID,
		Content:   summaryText,
		Language:  news.Language,
		CreatedAt: now,
		UpdatedAt: now,
	}

	return news, summary, nil
}
