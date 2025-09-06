package usecase

import (
	"context"
	"regexp"
	"strings"
	"time"

	"github.com/RealEskalate/G6-NewsBrief/internal/domain/contract"
	"github.com/RealEskalate/G6-NewsBrief/internal/domain/entity"
	"github.com/RealEskalate/G6-NewsBrief/internal/infrastructure/localization"
)

type newsUsecase struct {
	repo         contract.INewsRepository
	userRepo     contract.IUserRepository
	sourceRepo   contract.ISourceRepository
	analyticRepo contract.IAnalyticRepository
	uuidGen      contract.IUUIDGenerator
	SummarizerUC contract.ISummarizerService
	translator   contract.ITranslationClient
}

func NewNewsUsecase(repo contract.INewsRepository, userRepo contract.IUserRepository, sourceRepo contract.ISourceRepository, analyticRepo contract.IAnalyticRepository, uuidGen contract.IUUIDGenerator, summarizerUC contract.ISummarizerService, translator contract.ITranslationClient) contract.INewsUsecase {
	return &newsUsecase{repo: repo, userRepo: userRepo, sourceRepo: sourceRepo, analyticRepo: analyticRepo, uuidGen: uuidGen, SummarizerUC: summarizerUC, translator: translator}
}

func (u *newsUsecase) AdminCreateNews(ctx context.Context, title, body, language, sourceID string, topicIDs []string) (*entity.News, error) {
	cleanTitle := sanitizeAdminTitle(title)
	now := time.Now()
	eth := localization.ToEthiopian(now)
	news := &entity.News{
		ID:                     u.uuidGen.NewUUID(),
		Title:                  cleanTitle,
		Body:                   body,
		Language:               language,
		SourceID:               sourceID,
		Topics:                 topicIDs,
		PublishedAt:            now,
		CreatedAt:              now,
		UpdatedAt:              now,
		PublishedDateLocalized: eth.FormatYYYYMMDD(),
	}
	// Assign originals into bilingual slots
	if language == "en" {
		news.TitleEN, news.BodyEN = cleanTitle, body
	} else if language == "am" {
		news.TitleAM, news.BodyAM = cleanTitle, body
	} else {
		news.TitleEN, news.BodyEN = cleanTitle, body
	}
	// Summarize (in original language) using summarizer usecase's gemini client indirectly; directly call summarizer
	// We temporarily persist first so the summarizer can load it; but we want summary fields in same transaction-like flow.
	if err := u.repo.AdminCreateNews(ctx, news); err != nil {
		return nil, err
	}
	if _, err := u.SummarizerUC.Summarize(news.ID); err != nil {
		return nil, err
	}
	// Reload updated record with summary field filled
	updated, err := u.repo.FindByID(news.ID)
	if err == nil && updated != nil {
		news = updated
	}
	// Translate missing counterparts via translator client
	if u.translator != nil {
		if news.TitleEN != "" && news.TitleAM == "" {
			if t, err := u.translator.Translate(news.TitleEN, "en", "am"); err == nil {
				news.TitleAM = t
			}
		}
		if news.TitleAM != "" && news.TitleEN == "" {
			if t, err := u.translator.Translate(news.TitleAM, "am", "en"); err == nil {
				news.TitleEN = t
			}
		}
		if news.BodyEN != "" && news.BodyAM == "" {
			if t, err := u.translator.Translate(news.BodyEN, "en", "am"); err == nil {
				news.BodyAM = t
			}
		}
		if news.BodyAM != "" && news.BodyEN == "" {
			if t, err := u.translator.Translate(news.BodyAM, "am", "en"); err == nil {
				news.BodyEN = t
			}
		}
		if news.SummaryEN != "" && news.SummaryAM == "" {
			if t, err := u.translator.Translate(news.SummaryEN, "en", "am"); err == nil {
				news.SummaryAM = t
			}
		}
		if news.SummaryAM != "" && news.SummaryEN == "" {
			if t, err := u.translator.Translate(news.SummaryAM, "am", "en"); err == nil {
				news.SummaryEN = t
			}
		}
	}
	// Fallback mirror if translation failed
	if news.SummaryEN == "" && news.SummaryAM != "" {
		news.SummaryEN = news.SummaryAM
	}
	if news.SummaryAM == "" && news.SummaryEN != "" {
		news.SummaryAM = news.SummaryEN
	}
	if news.TitleEN == "" && news.TitleAM != "" {
		news.TitleEN = news.TitleAM
	}
	if news.TitleAM == "" && news.TitleEN != "" {
		news.TitleAM = news.TitleEN
	}
	if news.BodyEN == "" && news.BodyAM != "" {
		news.BodyEN = news.BodyAM
	}
	if news.BodyAM == "" && news.BodyEN != "" {
		news.BodyAM = news.BodyEN
	}
	// Persist mirrored updates
	_ = u.repo.Update(news)
	if err := u.analyticRepo.IncrementTotalNews(ctx); err != nil {
		return nil, err
	}
	return news, nil
}

func (u *newsUsecase) ListNews(page, limit int) ([]*entity.News, int64, int, error) {
	if limit <= 0 {
		limit = 10
	}
	return u.repo.FindAll(page, limit)
}

// ListForYou lists news only from the user's subscribed sources
func (u *newsUsecase) ListForYou(ctx context.Context, userID string, page, limit int) ([]*entity.News, int64, int, error) {
	if limit <= 0 {
		limit = 10
	}
	// Get subscribed source slugs from user profile
	slugs, err := u.userRepo.GetSourceSubscriptions(ctx, userID)
	if err != nil {
		return nil, 0, 0, err
	}
	if len(slugs) == 0 {
		return []*entity.News{}, 0, 0, nil
	}
	// Resolve slugs to Source IDs
	ids := make([]string, 0, len(slugs))
	for _, slug := range slugs {
		if slug == "" {
			continue
		}
		src, err := u.sourceRepo.GetBySlug(ctx, slug)
		if err != nil || src == nil || src.ID == "" {
			continue
		}
		ids = append(ids, src.ID)
	}
	if len(ids) == 0 {
		return []*entity.News{}, 0, 0, nil
	}
	return u.repo.FindBySourceIDs(ids, page, limit)
}

// ListByTopicID lists news associated with a specific topic ID
func (u *newsUsecase) ListByTopicID(ctx context.Context, topicID string, page, limit int) ([]*entity.News, int64, int, error) {
	if limit <= 0 {
		limit = 10
	}
	if topicID == "" {
		return []*entity.News{}, 0, 0, nil
	}
	return u.repo.FindByTopicID(ctx, topicID, page, limit)
}

// ListTrending returns paginated news sorted by recency (as a basic trending mechanism)
func (u *newsUsecase) ListTrending(page, limit int) ([]*entity.News, int64, int, error) {
	if limit <= 0 {
		limit = 10
	}
	return u.repo.FindTrending(page, limit)
}

// ListToday returns the top-N news items from today only
func (u *newsUsecase) ListToday(limit int) ([]*entity.News, int64, int, error) {
	if limit <= 0 {
		limit = 4
	}
	return u.repo.FindToday(limit)
}

var adminNewsPrefix = regexp.MustCompile(`(?i)^news:\s*`)

func sanitizeAdminTitle(t string) string {
	t = strings.TrimSpace(t)
	return strings.TrimSpace(adminNewsPrefix.ReplaceAllString(t, ""))
}
