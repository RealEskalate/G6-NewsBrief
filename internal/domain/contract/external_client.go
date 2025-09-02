package contract

type IGeminiClient interface {
	Summarize(text, lang string) (string, error)
	Chat(messages []string, context string) (string, error)
}

type ITranslationClient interface {
	Translate(text, sourceLang, targetLang string) (string, error)
}

type IScraperClient interface {
	FetchNewsByID(id string) (string, error)
	FetchLatest(limit int) ([]string, error)
}