package dto

type SummarizeRequest struct {
	NewsID string `json:"news_id" binding:"required"`
}

type SummarizeResponse struct {
	NewsID  string `json:"news_id"`
	Summary string `json:"summary"`
	Language string `json:"language"`
}