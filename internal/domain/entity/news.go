package entity

import "time"

type News struct {
	ID string `bson:"_id,omitempty" json:"id"`
	Title string `bson:"title" json:"title"`
	Body string `bson:"body" json:"body"`
	// Topic string `bson:"topic" json:"topic"`
	SummaryEN string `bson:"summary_en,omitempty" json:"summary_en,omitempty"`
	SummaryAM string `bson:"summary_am,omitempty" json:"summary_am,omitempty"`
	Language string `bson:"language" json:"language"`
	Source string `bson:"source" json:"source"`
	PublishedAt time.Time `bson:"published_at" json:"published_at"`
	CreatedAt time.Time `bson:"created_at" json:"created_at"`
	UpdatedAt time.Time `bson:"updated_at" json:"updated_at"`
}