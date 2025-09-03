package external_services

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
)

type ScraperClient struct {
	BaseURL string
}

func NewsScraperClient(baseURL string) *ScraperClient {
	return &ScraperClient{
		BaseURL: baseURL,
	}
}

func (sc *ScraperClient) FetchNewsByID(id string) (string, error){
	resp, err := http.Get(fmt.Sprintf("%s/news/%s", sc.BaseURL, id))
	if err != nil {
		return "", err
	}	
	defer resp.Body.Close()

	body, _ := ioutil.ReadAll(resp.Body)

	var data struct{
		Content string `json:"content"`
	}
	if err := json.Unmarshal(body, &data); err != nil {
		return "", err
	}
	return data.Content, nil
}

func (sc *ScraperClient) FetchLatest(limit int) ([] string, error){
	resp, err := http.Get(fmt.Sprintf("%s/news?limit=%d", sc.BaseURL, limit))
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()
	body, _ := ioutil.ReadAll(resp.Body)

	var data []struct{
		Content string `json:"content"`
	}
	if err := json.Unmarshal(body, &data); err != nil {
		return nil, err
	}
	var contents []string
	for _, item := range data {
		contents = append(contents, item.Content)
	}

	return contents, nil
}