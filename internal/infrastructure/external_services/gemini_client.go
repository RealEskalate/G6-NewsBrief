package external_services

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"strings"
	"time"
)

type GeminiClient struct {
	APIKey string
	APIURL string // Expected to be the full generateContent endpoint for the chosen model
}

func NewGeminiClient(apiKey, apiURL string) *GeminiClient {
	return &GeminiClient{
		APIKey: apiKey,
		APIURL: apiURL,
	}
}

// genReq and genResp are minimal structs for Google Generative Language API
type genReq struct {
	Contents          []content      `json:"contents"`
	SystemInstruction *systemMessage `json:"systemInstruction,omitempty"`
}

type content struct {
	Role  string `json:"role,omitempty"`
	Parts []part `json:"parts"`
}

type part struct {
	Text string `json:"text"`
}

type systemMessage struct {
	Role  string `json:"role,omitempty"`
	Parts []part `json:"parts"`
}

type genResp struct {
	Candidates []struct {
		Content struct {
			Parts []part `json:"parts"`
		} `json:"content"`
	} `json:"candidates"`
	Error *struct {
		Code    int    `json:"code"`
		Message string `json:"message"`
		Status  string `json:"status"`
	} `json:"error,omitempty"`
}

func (c *GeminiClient) buildURLWithKey() string {
	// Append ?key= or &key= depending on presence of query string
	sep := "?"
	if strings.Contains(c.APIURL, "?") {
		sep = "&"
	}
	// fmt.Println("API URL:", c.APIURL) // Debug print
	return fmt.Sprintf("%s%vkey=%s", c.APIURL, sep, c.APIKey)
}

func (c *GeminiClient) httpClient() *http.Client {
	return &http.Client{Timeout: 15 * time.Second}
}

func extractText(r genResp) (string, error) {
	if len(r.Candidates) == 0 || len(r.Candidates[0].Content.Parts) == 0 {
		return "", fmt.Errorf("no candidates returned from model")
	}
	return r.Candidates[0].Content.Parts[0].Text, nil
}

func (c *GeminiClient) Summarize(text, lang string) (string, error) {
	// Prompt the model to summarize in the requested language
	prompt := fmt.Sprintf("Summarize the following text in %s. Keep it concise and clear.\n\n%s", lang, text)
	reqBody := genReq{
		Contents: []content{
			{Parts: []part{{Text: prompt}}},
		},
	}
	data, _ := json.Marshal(reqBody)

	req, _ := http.NewRequest("POST", c.buildURLWithKey(), bytes.NewBuffer(data))
	req.Header.Set("Content-Type", "application/json")

	resp, err := c.httpClient().Do(req)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()

	bodyBytes, _ := io.ReadAll(resp.Body)
	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		return "", fmt.Errorf("gemini error %d: %s", resp.StatusCode, string(bodyBytes))
	}

	var result genResp
	if err := json.Unmarshal(bodyBytes, &result); err != nil {
		return "", err
	}
	if result.Error != nil {
		return "", fmt.Errorf("gemini api error: %s", result.Error.Message)
	}
	return extractText(result)
}

// ClassifyTopics asks the model to output a JSON array of concise topic labels
func (c *GeminiClient) ClassifyTopics(text, lang string, topK int) ([]string, error) {
	if topK <= 0 {
		topK = 2
	}
	prompt := fmt.Sprintf("Return a JSON array (no prose) of up to %d high-level topic labels in %s for the following text. Keep labels concise, 1-3 words. If uncertain, still return best guesses. Text:\n\n%s", topK, lang, text)
	reqBody := genReq{Contents: []content{{Parts: []part{{Text: prompt}}}}}
	data, _ := json.Marshal(reqBody)
	req, _ := http.NewRequest("POST", c.buildURLWithKey(), bytes.NewBuffer(data))
	req.Header.Set("Content-Type", "application/json")
	resp, err := c.httpClient().Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()
	bodyBytes, _ := io.ReadAll(resp.Body)
	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		return nil, fmt.Errorf("gemini error %d: %s", resp.StatusCode, string(bodyBytes))
	}
	var result genResp
	if err := json.Unmarshal(bodyBytes, &result); err == nil {
		// try structured extraction then parse as JSON
		textOut, err := extractText(result)
		if err != nil {
			return nil, err
		}
		// parse textOut as JSON array
		var arr []string
		if err := json.Unmarshal([]byte(textOut), &arr); err == nil {
			return arr, nil
		}
		// fallback: split by commas/newlines
		raw := strings.ReplaceAll(textOut, "\n", ",")
		parts := strings.Split(raw, ",")
		out := make([]string, 0, len(parts))
		for _, p := range parts {
			s := strings.TrimSpace(p)
			if s != "" {
				out = append(out, s)
			}
		}
		if len(out) > topK {
			out = out[:topK]
		}
		return out, nil
	}
	return nil, fmt.Errorf("failed to parse gemini response for topics")
}

func (c *GeminiClient) Chat(messages []string, context string) (string, error) {
	// Build conversation with the latest user message only for now
	userMsg := ""
	if len(messages) > 0 {
		userMsg = messages[len(messages)-1]
	}
	reqBody := genReq{
		Contents: []content{
			{Role: "user", Parts: []part{{Text: userMsg}}},
		},
	}
	if strings.TrimSpace(context) != "" {
		reqBody.SystemInstruction = &systemMessage{Role: "system", Parts: []part{{Text: context}}}
	}

	data, _ := json.Marshal(reqBody)
	req, _ := http.NewRequest("POST", c.buildURLWithKey(), bytes.NewBuffer(data))
	req.Header.Set("Content-Type", "application/json")

	resp, err := c.httpClient().Do(req)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()

	bodyBytes, _ := io.ReadAll(resp.Body)
	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		return "", fmt.Errorf("gemini error %d: %s", resp.StatusCode, string(bodyBytes))
	}

	var result genResp
	if err := json.Unmarshal(bodyBytes, &result); err != nil {
		return "", err
	}
	if result.Error != nil {
		return "", fmt.Errorf("gemini api error: %s", result.Error.Message)
	}
	return extractText(result)
}
