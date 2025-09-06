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

type providerIngestion struct {
	provider   contract.INewsProviderClient
	gemini     contract.IGeminiClient
	translator contract.ITranslationClient
	topics     contract.ITopicRepository
	newsRepo   contract.INewsRepository
	uuidGen    contract.IUUIDGenerator
}

func NewProviderIngestionUsecase(provider contract.INewsProviderClient, gemini contract.IGeminiClient, translator contract.ITranslationClient, topics contract.ITopicRepository, newsRepo contract.INewsRepository, uuidGen contract.IUUIDGenerator) contract.IProviderIngestionUsecase {
	return &providerIngestion{provider: provider, gemini: gemini, translator: translator, topics: topics, newsRepo: newsRepo, uuidGen: uuidGen}
}

func (uc *providerIngestion) IngestFromProvider(ctx context.Context, query string, topK int) ([]string, int, error) {
	items, err := uc.provider.Search(query, topK)
	if err != nil {
		return nil, 0, err
	}
	ids := make([]string, 0, len(items))
	skipped := 0
	for _, it := range items {
		// Clean title prefix like "News:" (case-insensitive) and variants
		cleanTitle := sanitizeTitle(it.Title)
		body := strings.TrimSpace(cleanTitle + "\n" + it.SourceURL)
		lang := it.Lang
		if lang == "" {
			lang = "en"
		}

		// Summarize original language body
		summary, err := uc.gemini.Summarize(body, lang)
		if err != nil {
			skipped++
			continue
		}

		// Classify to topics (raw labels) then map strictly to allowed domain topics
		rawLabels, _ := uc.gemini.ClassifyTopics(body, lang, 4)
		allowedSlugsSet := map[string]struct{}{}
		for _, lbl := range rawLabels {
			if lbl == "" {
				continue
			}
			if mapped := mapLabelToAllowed(lbl); mapped != "" {
				allowedSlugsSet[mapped] = struct{}{}
			}
		}
		// Ensure we have topic IDs only for allowed topics; lazily create missing allowed topics (once)
		// (Creation limited to the predefined whitelist only)
		topicIDs := make([]string, 0, len(allowedSlugsSet))
		for slug := range allowedSlugsSet {
			if existing, err := uc.topics.GetTopicBySlug(ctx, slug); err == nil && existing != nil && existing.ID != "" {
				topicIDs = append(topicIDs, existing.ID)
				continue
			}
			// Create with bilingual label (Amharic left same placeholder until separate localization strategy)
			labelEN := allowedTopics[slug]
			if labelEN == "" {
				continue
			}
			t := &entity.Topic{ID: uc.uuidGen.NewUUID(), Slug: slug, Label: entity.BilingualField{EN: labelEN, AM: labelEN}}
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

		// Pre-translate title/body/summary into both languages
		newsID := uc.uuidGen.NewUUID()
		eth := localization.ToEthiopian(published)
		n := &entity.News{
			ID:                     newsID,
			Title:                  cleanTitle,
			Body:                   body,
			Language:               lang,
			SourceID:               "",
			Topics:                 topicIDs,
			PublishedAt:            published,
			PublishedDateLocalized: eth.FormatYYYYMMDD(),
			CreatedAt:              time.Now(),
			UpdatedAt:              time.Now(),
		}
		// Store originals in their language-specific fields
		if lang == "en" {
			n.TitleEN, n.BodyEN, n.SummaryEN = cleanTitle, body, summary
		} else if lang == "am" {
			n.TitleAM, n.BodyAM, n.SummaryAM = cleanTitle, body, summary
		} else {
			n.TitleEN, n.BodyEN, n.SummaryEN = cleanTitle, body, summary
		}

		// Translate into counterpart language
		if uc.translator != nil {
			if n.TitleEN != "" && n.TitleAM == "" {
				if t, err := uc.translator.Translate(n.TitleEN, "en", "am"); err == nil {
					n.TitleAM = t
				}
			}
			if n.TitleAM != "" && n.TitleEN == "" {
				if t, err := uc.translator.Translate(n.TitleAM, "am", "en"); err == nil {
					n.TitleEN = t
				}
			}
			if n.BodyEN != "" && n.BodyAM == "" {
				if t, err := uc.translator.Translate(n.BodyEN, "en", "am"); err == nil {
					n.BodyAM = t
				}
			}
			if n.BodyAM != "" && n.BodyEN == "" {
				if t, err := uc.translator.Translate(n.BodyAM, "am", "en"); err == nil {
					n.BodyEN = t
				}
			}
			if n.SummaryEN != "" && n.SummaryAM == "" {
				if t, err := uc.translator.Translate(n.SummaryEN, "en", "am"); err == nil {
					n.SummaryAM = t
				}
			}
			if n.SummaryAM != "" && n.SummaryEN == "" {
				if t, err := uc.translator.Translate(n.SummaryAM, "am", "en"); err == nil {
					n.SummaryEN = t
				}
			}
		}
		// Fallback mirroring if translation missing
		if n.SummaryEN == "" && n.SummaryAM != "" {
			n.SummaryEN = n.SummaryAM
		}
		if n.SummaryAM == "" && n.SummaryEN != "" {
			n.SummaryAM = n.SummaryEN
		}
		if n.TitleEN == "" && n.TitleAM != "" {
			n.TitleEN = n.TitleAM
		}
		if n.TitleAM == "" && n.TitleEN != "" {
			n.TitleAM = n.TitleEN
		}
		if n.BodyEN == "" && n.BodyAM != "" {
			n.BodyEN = n.BodyAM
		}
		if n.BodyAM == "" && n.BodyEN != "" {
			n.BodyAM = n.BodyEN
		}

		// (Ethiopian localized date already set earlier)

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

var newsPrefixRegex = regexp.MustCompile(`(?i)^news:\s*`)

func sanitizeTitle(t string) string {
	t = strings.TrimSpace(t)
	t = newsPrefixRegex.ReplaceAllString(t, "")
	return strings.TrimSpace(t)
}

// Whitelisted allowed topics (slug -> canonical English label)
var allowedTopics = map[string]string{
	"world":         "world",
	"national":      "national",
	"politics":      "politics",
	"business":      "business",
	"economy":       "economy",
	"finance":       "finance",
	"technology":    "technology",
	"science":       "science",
	"health":        "health",
	"environment":   "environment",
	"education":     "education",
	"law":           "law",
	"crime":         "crime",
	"weather":       "weather",
	"opinion":       "opinion",
	"sports":        "sports",
	"entertainment": "entertainment",
	"culture":       "culture",
}

// Normalizes a raw model-provided label to one of the allowed slugs
func mapLabelToAllowed(raw string) string {
	s := strings.ToLower(strings.TrimSpace(raw))
	// Remove surrounding punctuation like brackets quotes etc.
	s = strings.Trim(s, "[](){}\"'")
	// Split on spaces and take first token if multi-word and maybe contains comma
	s = strings.Split(s, ",")[0]
	s = strings.TrimSpace(s)
	if _, ok := allowedTopics[s]; ok {
		return s
	}
	// Attempt simple singular/plural normalization
	if strings.HasSuffix(s, "s") {
		base := strings.TrimSuffix(s, "s")
		if _, ok := allowedTopics[base]; ok {
			return base
		}
	}
	return ""
}
