package contract

import "context"

// IProviderIngestionUsecase coordinates fetching news from external provider,
// summarizing, topic classification/creation, and persistence.
type IProviderIngestionUsecase interface {
	IngestFromProvider(ctx context.Context, query string, topK int) (ingestedIDs []string, skipped int, err error)
}
