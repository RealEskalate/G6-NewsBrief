package usecase

import (
	"time"

	"github.com/RealEskalate/G6-NewsBrief/internal/domain/contract"
	"github.com/RealEskalate/G6-NewsBrief/internal/domain/entity"
)

type SummarizerUsecase struct {
	geminiClient contract.IGeminiClient
	newsRepo     contract.INewsRepository
}

func NewsSummarizerUsecase(geminiClient contract.IGeminiClient, repo contract.INewsRepository) contract.ISummarizerService {
	return &SummarizerUsecase{
		geminiClient: geminiClient,
		newsRepo:     repo,
	}
}

func (uc *SummarizerUsecase) Summarize(newsID string) (entity.Summary, error) {
	// Fetch news first
	news, err := uc.newsRepo.FindByID(newsID)
	if err != nil {
		return entity.Summary{}, err
	}

	// Call Gemini API to generate summaries
	summaryText, err := uc.geminiClient.Summarize(news.Body, news.Language)
	if err != nil {
		return entity.Summary{}, err
	}

	// Create Summary entity
	summary := entity.Summary{
		NewsID:    news.ID,
		Content:   summaryText,
		Language:  news.Language,
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
	}

	// Save summary to news entity
	if news.Language == "en" {
		news.SummaryEN = summaryText
	} else if news.Language == "am" {
		news.SummaryAM = summaryText
	}

	news.UpdatedAt = time.Now()

	if err := uc.newsRepo.Update(news); err != nil {
		return entity.Summary{}, err
	}

	return summary, nil
}
