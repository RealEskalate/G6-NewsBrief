package contract

import "github.com/RealEskalate/G6-NewsBrief/internal/domain/entity"

// INewsIngestionService enforces the policy that scraped news are summarized
// before being persisted to the database.
type INewsIngestionService interface {
	// SaveAfterSummarize summarizes the provided news based on its Language,
	// stores the summary in the corresponding field, then saves the news.
	// Returns the saved news and the generated summary.
	SaveAfterSummarize(news *entity.News) (*entity.News, entity.Summary, error)
}
