package entity

// Analytic represents aggregated statistics about the application.

type Analytic struct {
	ID           string `bson:"_id,omitempty" json:"id"`
	TotalUsers   int64  `bson:"total_users" json:"total_users"`
	TotalNews    int64  `bson:"total_news" json:"total_news"`
	TotalSources int64  `bson:"total_sources" json:"total_sources"`
	TotalTopics  int64  `bson:"total_topics" json:"total_topics"`
}
