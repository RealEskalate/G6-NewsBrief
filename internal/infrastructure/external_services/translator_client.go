package external_services

import (
	"github.com/Conight/go-googletrans"
)

type TranslatorClient struct {
	client *translator.Translator
}

func NewTranslatorClient() *TranslatorClient {
	return &TranslatorClient{
		client: translator.New(),
	}
}

func (tc *TranslatorClient) Translate(text, sourceLang, targetLang string) (string, error) {
	res, err := tc.client.Translate(text, sourceLang, targetLang)
	if err != nil {
		return "", err
	}	
	return res.Text, nil
}