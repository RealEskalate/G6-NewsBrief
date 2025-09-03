package contract

import (
	"github.com/RealEskalate/G6-NewsBrief/internal/domain/entity"
)

type IChatbotService interface {
	ChatGeneral(sessionID, message string) (string, error)
	ChatForNews(newsID, sessionID, message string) (string, error)
	GetHistory(sessionID string) ([]entity.ChatMessage, error)
}

