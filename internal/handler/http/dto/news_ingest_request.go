package dto

import "time"

type NewsIngestRequest struct {
	Title       string    `json:"title" binding:"required"`
	Body        string    `json:"body" binding:"required"`
	Language    string    `json:"language" binding:"required,oneof=en am"`
	SourceID    string    `json:"source_id" binding:"required"`
	Topics      []string  `json:"topics"`
	PublishedAt time.Time `json:"published_at" binding:"required"`
}

type NewsIngestResponse struct {
	ID          string    `json:"id"`
	Title       string    `json:"title"`
	Language    string    `json:"language"`
	SourceID    string    `json:"source_id"`
	Topics      []string  `json:"topics,omitempty"`
	SummaryEN   string    `json:"summary_en,omitempty"`
	SummaryAM   string    `json:"summary_am,omitempty"`
	PublishedAt time.Time `json:"published_at"`
	CreatedAt   time.Time `json:"created_at"`
}
