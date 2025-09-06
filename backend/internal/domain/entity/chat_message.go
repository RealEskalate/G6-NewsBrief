package entity

import "time"

type ChatMessage struct {
	ID string `bson:"_id,omitempty" json:"id"`
	ContextID string `bson:"context_id,omitempty" json:"context_id,omitempty"`
	Role string `bson:"role" json:"role"`
	Text string `bson:"text" json:"text"`
	Timestamp time.Time `bson:"timestamp" json:"timestamp"`
}