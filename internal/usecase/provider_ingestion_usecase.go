package usecase

import (
	"context"
	"strings"
	"time"

	"github.com/RealEskalate/G6-NewsBrief/internal/domain/contract"
	"github.com/RealEskalate/G6-NewsBrief/internal/domain/entity"
)

type providerIngestion struct {
	provider contract.INewsProviderClient
	gemini   contract.IGeminiClient
	topics   contract.ITopicRepository
	newsRepo contract.INewsRepository
	uuidGen  contract.IUUIDGenerator
}

func NewProviderIngestionUsecase(provider contract.INewsProviderClient, gemini contract.IGeminiClient, topics contract.ITopicRepository, newsRepo contract.INewsRepository, uuidGen contract.IUUIDGenerator) contract.IProviderIngestionUsecase {
	return &providerIngestion{provider: provider, gemini: gemini, topics: topics, newsRepo: newsRepo, uuidGen: uuidGen}
}

func (uc *providerIngestion) IngestFromProvider(ctx context.Context, query string, topK int) ([]string, int, error) {
	items, err := uc.provider.Search(query, topK)
	if err != nil {
		return nil, 0, err
	}
	ids := make([]string, 0, len(items))
	skipped := 0
	for _, it := range items {
		// Build a news body from the provider minimal fields (we only have title/source_url)
		body := strings.TrimSpace(it.Title + "\n" + it.SourceURL)
		// choose language
		lang := it.Lang
		if lang == "" {
			lang = "en"
		}

		// Summarize with Gemini
		summary, err := uc.gemini.Summarize(body, lang)
		if err != nil {
			skipped++
			continue
		}

		// Classify to topics
		topicLabels, _ := uc.gemini.ClassifyTopics(body, lang, 3)
		topicIDs := make([]string, 0, len(topicLabels))
		for _, lbl := range topicLabels {
			if lbl == "" {
				continue
			}
			slug := slugify(lbl)
			// find by slug
			if existing, err := uc.topics.GetTopicBySlug(ctx, slug); err == nil && existing != nil && existing.ID != "" {
				topicIDs = append(topicIDs, existing.ID)
				continue
			}
			// create topic if not exists
			t := &entity.Topic{
				ID:    uc.uuidGen.NewUUID(),
				Slug:  slug,
				Label: entity.BilingualField{EN: lbl, AM: lbl},
			}
			if err := uc.topics.CreateTopic(ctx, t); err == nil {
				topicIDs = append(topicIDs, t.ID)
			}
		}

		// parse published time
		var published time.Time
		if it.PublishedDate != "" {
			if tm, err := time.Parse(time.RFC3339, it.PublishedDate); err == nil {
				published = tm
			}
		}
		if published.IsZero() {
			published = time.Now().UTC()
		}

		n := &entity.News{
			ID:          uc.uuidGen.NewUUID(),
			Title:       it.Title,
			Body:        body,
			Language:    lang,
			SourceID:    "", // unknown mapping from provider; can extend later
			Topics:      topicIDs,
			PublishedAt: published,
			CreatedAt:   time.Now(),
			UpdatedAt:   time.Now(),
		}
		switch lang {
		case "en":
			n.SummaryEN = summary
		case "am":
			n.SummaryAM = summary
		default:
			n.SummaryEN = summary
		}

		if err := uc.newsRepo.Save(n); err != nil {
			skipped++
			continue
		}
		ids = append(ids, n.ID)
	}
	return ids, skipped, nil
}

func slugify(s string) string {
	s = strings.ToLower(strings.TrimSpace(s))
	s = strings.ReplaceAll(s, " ", "-")
	s = strings.ReplaceAll(s, "/", "-")
	s = strings.ReplaceAll(s, "_", "-")
	return s
}
