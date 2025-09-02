package external_services

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
)

type GeminiClient struct {
	APIKey string
	APIURL string
}

func NewGeminiClient(apiKey, apiURL string) *GeminiClient {
	return &GeminiClient{
		APIKey: apiKey,
		APIURL: apiURL,
	}
}


func (c *GeminiClient) Summarize(text, lang string) (string, error) {
	payload := map[string]string{
		"text": text, 
		"lang": lang,
	}

	data, _ := json.Marshal(payload)
	req, _ := http.NewRequest("POST",fmt.Sprintf("%s/summarize", c.APIURL), bytes.NewBuffer(data))
	req.Header.Set("Content-Type", "application/json")
	// req.Header.Set("Authorization", fmt.Sprintf("Bearer %s", c.APIKey))

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()

	var result struct {
		Summary string `json:"summary"`
	}
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return "", err
	}

	return result.Summary, nil
}

func (c *GeminiClient) Chat(messages []string, context string) (string, error) {
	payload := map[string]interface{}{
		"messages": messages,
		"context":  context,
	}
	data, _ := json.Marshal(payload)
	req, _ := http.NewRequest("POST", fmt.Sprintf("%s/chat", c.APIURL), bytes.NewBuffer(data))
	req.Header.Set("Content-Type", "application/json")
	// req.Header.Set("Authorization", fmt.Sprintf("Bearer %s", c.APIKey))

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()
	var result struct {
		Reply string `json:"reply"`
	}
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return "", err
	}
	return result.Reply, nil
}