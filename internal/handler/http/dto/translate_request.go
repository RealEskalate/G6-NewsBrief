package dto

type TranslateRequest struct {
	Text       string `json:"text" binding:"required"`
	SourceLang string `json:"source_lang" binding:"required"`
	TargetLang string `json:"target_lang" binding:"required"`
}

type TranslateResponse struct {
	TranslatedText string `json:"translated_text"`
}
