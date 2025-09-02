package contract

import (
	"github.com/RealEskalate/G6-NewsBrief/internal/domain/entity"
)

type ISummarizerService interface {
	// Summarize generates a summary for a news item identified by its ID,
	// updates the stored record, and returns the created summary metadata.
	Summarize(newsID string) (entity.Summary, error)
}
