package entity

import (
	"time"
)

// NotificationsPreferences holds user settings for notifications.
type NotificationsPreferences struct {
	DailyBrief   bool `bson:"daily_brief" json:"daily_brief"`
	BreakingNews bool `bson:"breaking_news" json:"breaking_news"`
}

// Preferences holds user-specific settings, embedded in the User document.
type Preferences struct {
	Lang              string                   `bson:"lang" json:"lang"`
	Topics            []string                 `bson:"topics" json:"topics"`
	SubscribedSources []string                 `bson:"subscribed_sources" json:"subscribed_sources"`
	BriefType         string                   `bson:"brief_type" json:"brief_type"`
	DataSaver         bool                     `bson:"data_saver" json:"data_saver"`
	Notifications     NotificationsPreferences `bson:"notifications" json:"notifications"`
}

// User represents a registered user in the system
type User struct {
	ID           string      `bson:"_id,omitempty" json:"id"`
	Username     string      `bson:"username" json:"username"`
	Email        string      `bson:"email" json:"email"`
	PasswordHash string      `bson:"password_hash" json:"-"`
	Role         UserRole    `bson:"role" json:"role"`
	IsVerified   bool        `bson:"is_verified" json:"is_verified"`
	CreatedAt    time.Time   `bson:"created_at" json:"created_at"`
	UpdatedAt    time.Time   `bson:"updated_at" json:"updated_at"`
	FirstName    *string     `bson:"firstname,omitempty" json:"firstname,omitempty"`
	LastName     *string     `bson:"lastname,omitempty" json:"lastname,omitempty"`
	AvatarURL    *string     `bson:"avatar_url,omitempty" json:"avatar_url,omitempty"`
	Preferences  Preferences `bson:"preferences" json:"preferences"`
}

// UserRole represents the role of a user in the system
type UserRole string

const (
	UserRoleAdmin UserRole = "admin"
	UserRoleUser  UserRole = "user"
)

func DefaultRole() UserRole {
	return UserRoleUser
}
