import requests
from os import getenv
from typing import Dict, List
from app.models.news import NewsAPIRequest

async def fetch_news_api(req: NewsAPIRequest) -> List[Dict]:
    """
    Functionality: Fetches news from NewsAPI.org.
    - Uses GET request with query params.
    - Maps to dict format compatible with cleaner (title, description as body, etc.).
    - Handles pagination if needed (free tier limited).
    """
    api_key = getenv("NEWSAPI_KEY")
    if not api_key:
        raise ValueError("NEWSAPI_KEY not set in .env")
    
    url = "https://newsapi.org/v2/everything"
    params = {
        "q": req.query,
        "sources": ",".join(req.sources) if req.sources else None,
        "from": req.from_date,
        "to": req.to_date,
        "apiKey": api_key
    }
    response = requests.get(url, params=params)
    if response.status_code != 200:
        raise ValueError(f"NewsAPI error: {response.text}")
    
    articles = response.json().get("articles", [])
    return [
        {
            "title": art["title"],
            "author": art.get("author"),
            "date": art.get("publishedAt"),
            "body": art["description"] if art["description"] else "" + art.get("content", ""),
            "source_url": art["url"],
            "source_type": "newsapi"
        } for art in articles
    ]