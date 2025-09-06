package contract

import (
	"github.com/RealEskalate/G6-NewsBrief/internal/domain/entity"
)

// JWTService defines the interface for JWT operations.
type IJWTService interface {
	GenerateAccessToken(userID string, role entity.UserRole) (string, error)
	GenerateRefreshToken(userID string, role entity.UserRole) (string, error)
	ParseAccessToken(token string) (*entity.Claims, error)
	ParseRefreshToken(token string) (*entity.Claims, error)
	GeneratePasswordResetToken(userID string) (string, error)
	ParsePasswordResetToken(token string) (*entity.Claims, error)
	GenerateEmailVerificationToken(userID string) (string, error)
	ParseEmailVerificationToken(token string) (*entity.Claims, error)
}
