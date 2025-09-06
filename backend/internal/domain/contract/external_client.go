package contract

type IGeminiClient interface {
	Summarize(text, lang string) (string, error)
	Chat(messages []string, context string) (string, error)
	// ClassifyTopics analyzes text and returns up to topK topic labels in the given language
	ClassifyTopics(text, lang string, topK int) ([]string, error)
}

type ITranslationClient interface {
	Translate(text, sourceLang, targetLang string) (string, error)
}

type IScraperClient interface {
	FetchNewsByID(id string) (string, error)
	FetchLatest(limit int) ([]string, error)
}

// INewsProviderClient queries the external news provider service for latest items
type INewsProviderClient interface {
	Search(query string, topK int) ([]ProviderItem, error)
}

// ProviderItem is a minimal shape returned by the provider search API
type ProviderItem struct {
	ID            string `json:"id"`
	Title         string `json:"title"`
	Text          string `json:"text"`
	SourceURL     string `json:"source_url"`
	SourceSite    string `json:"source_site"`
	SourceType    string `json:"source_type"`
	PublishedDate string `json:"published_date"`
	Lang          string `json:"lang"`
}
