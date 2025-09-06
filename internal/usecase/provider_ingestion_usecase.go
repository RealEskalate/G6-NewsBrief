package usecase

import (
	"context"
	"fmt"
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
	sourceRepo contract.ISourceRepository
}

func NewProviderIngestionUsecase(provider contract.INewsProviderClient, gemini contract.IGeminiClient, translator contract.ITranslationClient, topics contract.ITopicRepository, newsRepo contract.INewsRepository, uuidGen contract.IUUIDGenerator, sourceRepo contract.ISourceRepository) contract.IProviderIngestionUsecase {
	return &providerIngestion{provider: provider, gemini: gemini, translator: translator, topics: topics, newsRepo: newsRepo, uuidGen: uuidGen, sourceRepo: sourceRepo}
}

func (uc *providerIngestion) IngestFromProvider(ctx context.Context, query string, topK int) ([]string, int, error) {
	items, err := uc.provider.Search(query, topK)
	fmt.Println(items)
	if err != nil {
		return nil, 0, err
	}
	ids := make([]string, 0, len(items))
	skipped := 0
	for _, it := range items {
		// Clean title prefix like "News:" (case-insensitive) and variants
		cleanTitle := sanitizeTitle(it.Title)
		// Body should be full original text (provider returns 'text' field). Since current contract.ProviderItem
		// does not yet declare Text, some integrations may have temporarily used title+URL; we just store title as fallback.
		body := strings.TrimSpace(it.Text)
		if body == "" {
			body = strings.TrimSpace(it.Title)
		}
		lang := it.Lang
		if lang == "" {
			lang = "en"
		}

		// Summarize original language body with richer multi-sentence requirement.
		// Post-process to ensure at least 5 sentences, each broken into two lines for readability.
		summaryRaw, err := uc.gemini.Summarize(body, lang)
		if err != nil {
			skipped++
			continue
		}
		summary := enforceMultiLineFiveSentence(summaryRaw)

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

		// If after classification we have <2 topics, deterministically add fallback topics based on heuristics.
		if len(topicIDs) < 2 {
			fallbacks := inferFallbackTopics(cleanTitle, body)
			for _, slug := range fallbacks {
				if len(topicIDs) >= 2 {
					break
				}
				// ensure allowed and not already included
				if _, ok := allowedTopics[slug]; !ok {
					continue
				}
				already := false
				for _, id := range topicIDs { // we only have IDs; need to confirm not duplicate by slug creation attempt
					// cheap: attempt to fetch by slug and compare id
					if existing, err := uc.topics.GetTopicBySlug(ctx, slug); err == nil && existing != nil && existing.ID == id {
						already = true
						break
					}
				}
				if already {
					continue
				}
				if existing, err := uc.topics.GetTopicBySlug(ctx, slug); err == nil && existing != nil && existing.ID != "" {
					topicIDs = append(topicIDs, existing.ID)
					continue
				}
				// create
				labelEN := allowedTopics[slug]
				t := &entity.Topic{ID: uc.uuidGen.NewUUID(), Slug: slug, Label: entity.BilingualField{EN: labelEN, AM: labelEN}}
				if err := uc.topics.CreateTopic(ctx, t); err == nil {
					topicIDs = append(topicIDs, t.ID)
				}
			}
		}

		// Pre-translate title/body/summary into both languages
		newsID := uc.uuidGen.NewUUID()
		eth := localization.ToEthiopian(published)
		// Resolve or create source
		sourceID := ""
		if it.SourceSite != "" && uc.sourceRepo != nil {
			slug := slugify(it.SourceSite)
			if existing, err := uc.sourceRepo.GetBySlug(ctx, slug); err == nil && existing != nil && existing.ID != "" {
				sourceID = existing.ID
			} else {
				// create new source skeleton
				s := &entity.Source{
					ID:               uc.uuidGen.NewUUID(),
					Slug:             slug,
					Name:             it.SourceSite,
					Description:      "", // optional
					URL:              it.SourceURL,
					LogoURL:          "",
					Languages:        entity.SetLanguageType(lang),
					ReliabilityScore: 0,
				}
				if err := uc.sourceRepo.CreateSource(ctx, s); err == nil {
					sourceID = s.ID
				}
			}
		}
		
		n := &entity.News{
			ID:                     newsID,
			Title:                  cleanTitle,
			Body:                   body,
			SourceURL:              it.SourceURL,
			Language:               lang,
			SourceID:               sourceID,
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

// inferFallbackTopics derives up to two plausible topic slugs from title/body keywords.
func inferFallbackTopics(title, body string) []string {
	titleLower := strings.ToLower(title)
	bodyLower := strings.ToLower(body)
	picks := []string{}
	pick := func(slug string) {
		if len(picks) >= 2 {
			return
		}
		for _, p := range picks {
			if p == slug {
				return
			}
		}
		if _, ok := allowedTopics[slug]; ok {
			picks = append(picks, slug)
		}
	}
	// heuristics
	if strings.Contains(titleLower, "econom") || strings.Contains(bodyLower, "inflation") {
		pick("economy")
	}
	if strings.Contains(titleLower, "politic") || strings.Contains(bodyLower, "government") {
		pick("politics")
	}
	if strings.Contains(bodyLower, "health") || strings.Contains(bodyLower, "hospital") {
		pick("health")
	}
	if strings.Contains(bodyLower, "climate") || strings.Contains(bodyLower, "weather") {
		pick("environment")
	}
	if strings.Contains(titleLower, "tech") || strings.Contains(bodyLower, "ai ") {
		pick("technology")
	}
	if strings.Contains(bodyLower, "market") || strings.Contains(bodyLower, "stock") {
		pick("finance")
	}
	if len(picks) == 0 {
		pick("national")
	}
	if len(picks) < 2 {
		pick("world")
	}
	return picks
}

// enforceMultiLineFiveSentence ensures summary has at least 5 sentences and each sentence spans two lines.
// A naive splitter on '.' is used; if sentences <5 we duplicate last sentence variants.
func enforceMultiLineFiveSentence(s string) string {
	s = strings.TrimSpace(s)
	if s == "" {
		return s
	}
	parts := strings.Split(s, ".")
	cleaned := make([]string, 0, len(parts))
	for _, p := range parts {
		pt := strings.TrimSpace(p)
		if pt != "" {
			cleaned = append(cleaned, pt)
		}
	}
	if len(cleaned) == 0 {
		return s
	}
	for len(cleaned) < 5 { // pad by reusing last with note
		cleaned = append(cleaned, cleaned[len(cleaned)-1])
	}
	// Break each into two lines by inserting a newline roughly mid-way
	for i, sent := range cleaned {
		words := strings.Fields(sent)
		if len(words) > 6 { // only split if sufficiently long
			mid := len(words) / 2
			cleaned[i] = strings.Join(words[:mid], " ") + "\n" + strings.Join(words[mid:], " ")
		} else {
			cleaned[i] = sent + "\n" + sent // duplicate for minimal two lines
		}
	}
	return strings.Join(cleaned[:5], ".\n") + "."
}
