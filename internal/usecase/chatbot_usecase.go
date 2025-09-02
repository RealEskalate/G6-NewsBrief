package usecase

import (
	"fmt"
	// "time"

	"github.com/RealEskalate/G6-NewsBrief/internal/domain/contract"
	"github.com/RealEskalate/G6-NewsBrief/internal/domain/entity"
)

type ChatbotUsecase struct {
	geminiClient contract.IGeminiClient
	newsRepo contract.INewsRepository
}

func NewChatbotUsecase(gemini contract.IGeminiClient, repo contract.INewsRepository) contract.IChatbotService {
	return &ChatbotUsecase{
		geminiClient: gemini,
		newsRepo: repo,
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

	context := fmt.Sprintf("You are a chatbot restricted to this news article only. Title: %s. Summary: %s", news.Title, news.SummaryEN)
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