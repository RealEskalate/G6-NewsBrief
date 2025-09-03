package entity

import "time"

type Summary struct {
	ID string `bson:"_id,omitempty" json:"id"`
	NewsID string `bson:"news_id" json:"news_id"`
	Content string `bson:"content" json:"content"`
	Language string `bson:"language" json:"language"`
	CreatedAt time.Time `bson:"created_at" json:"created_at"`
	UpdatedAt time.Time `bson:"updated_at" json:"updated_at"`
}

