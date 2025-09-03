package usecase

import (
	"fmt"
	// "time"

	"github.com/RealEskalate/G6-NewsBrief/internal/domain/contract"
	"github.com/RealEskalate/G6-NewsBrief/internal/domain/entity"
)

type ChatbotUsecase struct {
	geminiClient     contract.IGeminiClient
	translatorClient contract.ITranslationClient
	newsRepo         contract.INewsRepository
}

func NewChatbotUsecase(gemini contract.IGeminiClient, translator contract.ITranslationClient, repo contract.INewsRepository) contract.IChatbotService {
	return &ChatbotUsecase{
		geminiClient:     gemini,
		translatorClient: translator,
		newsRepo:         repo,
	}
}

// ChatGeneral handles general news queries (knowledge restricted to news domain)
func (uc *ChatbotUsecase) ChatGeneral(sessionID, message string) (string, error) {
	context := "General news chatbot. You can only answer questions about news topics."
	reply, err := uc.geminiClient.Chat([]string{message}, context)
	if err != nil {
		return "", err
	}

	// Save chat history - in a real implementation, this would involve saving to a database
	// _ = entity.ChatMessage{
	// 	ContextID: sessionID,
	// 	Role:      "user",
	// 	Text:   message,
	// 	Timestamp: time.Now(),
	// }

	// _ = entity.ChatMessage{
	// 	ContextID: sessionID,
	// 	Role:      "assistant",
	// 	Text:   reply,
	// 	Timestamp: time.Now(),
	// }
	return reply, nil
}

// ChatForNews answers questions about a specific news item
func (uc *ChatbotUsecase) ChatForNews(newsID, sessionID, message string) (string, error) {
	news, err := uc.newsRepo.FindByID(newsID)
	if err != nil {
		return "", fmt.Errorf("news not found: %w", err)
	}

	var context string

	// Detect Amharic (basic Ethiopic Unicode block check)
	isAmharic := func(s string) bool {
		for _, r := range s {
			if r >= 0x1200 && r <= 0x137F { // Ethiopic block
				return true
			}
		}
		return false
	}

	amharic := isAmharic(message)

	if amharic {
		if news.SummaryAM != "" {
			context = fmt.Sprintf("You are a chatbot restricted to this news article only. Respond in Amharic only. Title: %s. Summary: %s", news.Title, news.SummaryAM)
		} else if news.SummaryEN != "" {
			translated, err := uc.translatorClient.Translate(news.SummaryEN, "en", "am")
			if err != nil {
				return "", fmt.Errorf("failed to translate summary to Amharic: %w", err)
			}
			context = fmt.Sprintf("You are a chatbot restricted to this news article only. Respond in Amharic only. Title: %s. Summary: %s", news.Title, translated)
		} else {
			return "", fmt.Errorf("there is no summary for the news")
		}
	} else {
		if news.SummaryEN != "" {
			context = fmt.Sprintf("You are a chatbot restricted to this news article only. Respond in English only. Title: %s. Summary: %s", news.Title, news.SummaryEN)
		} else if news.SummaryAM != "" {
			translated, err := uc.translatorClient.Translate(news.SummaryAM, "am", "en")
			if err != nil {
				return "", fmt.Errorf("failed to translate summary to English: %w", err)
			}
			context = fmt.Sprintf("You are a chatbot restricted to this news article only. Respond in English only. Title: %s. Summary: %s", news.Title, translated)
		} else {
			return "", fmt.Errorf("there is no summary for the news")
		}
	}

	reply, err := uc.geminiClient.Chat([]string{message}, context)
	if err != nil {
		return "", err
	}

	return reply, nil
}

// (Optional) Return chat history if stored
func (uc *ChatbotUsecase) GetHistory(sessionID string) ([]entity.ChatMessage, error) {
	return []entity.ChatMessage{}, nil
}
