package usecase

import (
	"context"
	"errors"

	"github.com/RealEskalate/G6-NewsBrief/internal/domain/contract"
	"github.com/RealEskalate/G6-NewsBrief/internal/domain/entity"
)

type sourceUsecase struct {
	sourceRepo contract.ISourceRepository
	uuidGen    contract.IUUIDGenerator
}

// NewSourceUsecase creates a new instance of sourceUsecase.
func NewSourceUsecase(sourceRepo contract.ISourceRepository, uuidGen contract.IUUIDGenerator) contract.ISourceUsecase {
	return &sourceUsecase{
		sourceRepo: sourceRepo,
		uuidGen:    uuidGen,
	}
}
func (uc *sourceUsecase) CreateSource(ctx context.Context, source *entity.Source) error {
	if source == nil {
		return errors.New("source cannot be nil")
	}

	if source.Slug == "" {
		return errors.New("source slug cannot be empty")
	}

	exists, err := uc.sourceRepo.CheckSlugExists(ctx, source.Slug)
	if err != nil {
		return errors.New("could not validate source slug")
	}
	if exists {
		return errors.New("source with slug already exists")
	}

	urlExists, err := uc.sourceRepo.CheckURLExists(ctx, source.URL)
	if err != nil {
		return errors.New("could not validate source")
	}
	if urlExists {
		return errors.New("source with URL already exists")
	}
	// Ensure ID exists and is a UUID
	if source.ID == "" {
		source.ID = uc.uuidGen.NewUUID()
	}
	return uc.sourceRepo.CreateSource(ctx, source)
}

// GetAll fetches all source definitions from the repository.
func (uc *sourceUsecase) GetAll(ctx context.Context) ([]entity.Source, error) {
	// For now, the use case is a simple pass-through.
	// Business logic like filtering out inactive sources could be added here later.
	return uc.sourceRepo.GetAll(ctx)
}
