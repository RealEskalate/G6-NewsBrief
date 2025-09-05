package entity

import "time"

// Bookmark represents a user's saved news item (per-user relation)
type Bookmark struct {
	ID        string    `bson:"_id,omitempty" json:"id"`
	UserID    string    `bson:"user_id" json:"user_id"`
	NewsID    string    `bson:"news_id" json:"news_id"`
	CreatedAt time.Time `bson:"created_at" json:"created_at"`
}
