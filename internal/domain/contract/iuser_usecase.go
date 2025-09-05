package contract

import (
	"context"

	"github.com/RealEskalate/G6-NewsBrief/internal/domain/entity"
	"github.com/RealEskalate/G6-NewsBrief/internal/handler/http/dto"
)

// UserUseCase defines the interface for user-related operations.
type IUserUseCase interface {
	Register(ctx context.Context, email, password, fullname string) (*entity.User, error)
	Login(ctx context.Context, email, password string) (*entity.User, string, string, error)
	Authenticate(ctx context.Context, accessToken string) (*entity.User, error)
	RefreshToken(ctx context.Context, refreshToken string) (string, string, error)
	ForgotPassword(ctx context.Context, email string) error
	ResetPassword(ctx context.Context, verifier, resetToken, newPassword string) error
	Logout(ctx context.Context, refreshToken string) error
	PromoteUser(ctx context.Context, userID string) (*entity.User, error)
	DemoteUser(ctx context.Context, userID string) (*entity.User, error)
	UpdateProfile(ctx context.Context, userID string, updates map[string]interface{}) (*entity.User, error)
	LoginWithOAuth(ctx context.Context, fullname, email string) (string, string, error)
	GetUserByID(ctx context.Context, userID string) (*entity.User, error)
	UpdatePreferences(ctx context.Context, userID string, req dto.UpdatePreferencesRequest) (*entity.Preferences, error)
	SubscribeTopic(ctx context.Context, userID, topicID string) error
	// SubscribeTopics subscribes the user to multiple topics (idempotent per topic).
	SubscribeTopics(ctx context.Context, userID string, topicIDs []string) error
	// UnsubscribeTopic removes a single topic subscription for the user.
	UnsubscribeTopic(ctx context.Context, userID, topicID string) error
	GetUserSubscribedTopics(ctx context.Context, userID string) ([]*entity.Topic, error)
	UnsubscribeTopic(ctx context.Context, userID, topicSlug string) error
}
