package entity

import "time"

type News struct {
	ID    string `bson:"_id,omitempty" json:"id"`
	Title string `bson:"title" json:"title"`
	Body  string `bson:"body" json:"body"`
	// Bilingual stored fields for instant toggle
	TitleEN string `bson:"title_en,omitempty" json:"title_en,omitempty"`
	TitleAM string `bson:"title_am,omitempty" json:"title_am,omitempty"`
	BodyEN  string `bson:"body_en,omitempty" json:"body_en,omitempty"`
	BodyAM  string `bson:"body_am,omitempty" json:"body_am,omitempty"`
	// Localized (Ethiopian) date string precomputed
	PublishedDateLocalized string    `bson:"published_date_localized,omitempty" json:"published_date_localized,omitempty"`
	SummaryEN              string    `bson:"summary_en,omitempty" json:"summary_en,omitempty"`
	SummaryAM              string    `bson:"summary_am,omitempty" json:"summary_am,omitempty"`
	Language               string    `bson:"language" json:"language"`
	SourceID               string    `bson:"source_id" json:"source_id"`
	Topics                 []string  `bson:"topics,omitempty" json:"topics,omitempty"`
	PublishedAt            time.Time `bson:"published_at" json:"published_at"`
	CreatedAt              time.Time `bson:"created_at" json:"created_at"`
	UpdatedAt              time.Time `bson:"updated_at" json:"updated_at"`
}
