package contract

import (
	"context"

	"github.com/RealEskalate/G6-NewsBrief/internal/domain/entity"
)

type IEmailVerificationUC interface {
	RequestVerificationEmail(ctx context.Context, user *entity.User) error
	VerifyEmailToken(ctx context.Context, verifier, plainToken string) (*entity.User, error)
}
