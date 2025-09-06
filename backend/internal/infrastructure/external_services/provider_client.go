package external_services

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"time"

	"github.com/RealEskalate/G6-NewsBrief/internal/domain/contract"
)

type NewsProviderClient struct {
	baseURL string
	client  *http.Client
}

func NewNewsProviderClient() contract.INewsProviderClient {
	base := os.Getenv("NEWS_PROVIDER_URL")
	if base == "" {
		base = "https://news-provider-service.onrender.com"
	}
	return &NewsProviderClient{
		baseURL: base,
		client:  &http.Client{Timeout: 20 * time.Second},
	}
}

func (c *NewsProviderClient) Search(query string, topK int) ([]contract.ProviderItem, error) {
	// New endpoint ignores query; using stored news listing with limit
	if topK <= 0 {
		topK = 100 // default limit requested
	}
	url := fmt.Sprintf("%s/api/v1/news/stored?limit=%d", c.baseURL, topK)
	req, err := http.NewRequest(http.MethodGet, url, nil)
	if err != nil {
		return nil, err
	}
	resp, err := c.client.Do(req)
	if err != nil {
		return nil, err
	}
	
	defer resp.Body.Close()
	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		return nil, fmt.Errorf("provider status %d", resp.StatusCode)
	}
	// Read entire body once and try multiple shapes
	b, _ := io.ReadAll(resp.Body)
	// 1) array
	var items []contract.ProviderItem
	if err := json.Unmarshal(b, &items); err == nil {
		return items, nil
	}
	// 2) wrapped { data: [] }
	var wrap struct {
		Data []contract.ProviderItem `json:"data"`
	}
	if err := json.Unmarshal(b, &wrap); err == nil && len(wrap.Data) > 0 {
		return wrap.Data, nil
	}
	// 3) single item
	var one contract.ProviderItem
	if err := json.Unmarshal(b, &one); err == nil && one.ID != "" {
		return []contract.ProviderItem{one}, nil
	}
	return []contract.ProviderItem{}, nil
}
