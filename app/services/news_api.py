from datetime import datetime, timezone
import uuid
import requests
from os import getenv
from typing import Dict, List
from app.models.news import NewsAPIRequest
from app.services.lang_detector import detect_language
import chromadb
from app.services.vector_db import VectorDBService
import logging

logger = logging.getLogger(__name__)

async def fetch_news_api(req: NewsAPIRequest, vector_db: chromadb.Client) -> List[Dict]:
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
        logger.error(f"NewsAPI request failed with status code {response.status_code}: {response.text}")
        return []

    data = response.json()
    articles = data.get("articles", [])

    map_article = lambda art: {
            "_id": str(uuid.uuid4()),
            "title": art["title"],
            "author": art.get("author"),
            "content": art.get("content", ""),
            "source_url": art["url"],
            "source_site": art.get("source", {}).get("name", "newsapi.org"),
            "source_type": "newsapi",
            "published_date": art.get("publishedAt"),
            "crawl_timestamp": datetime.now(timezone.utc).isoformat(),
            "lang": art.get("language", detect_language(art["description"] if art["description"] else art.get("content", ""))),
        }

    mapped_articles = [map_article(art) for art in articles]

    if vector_db:
        try:
            vector_service = VectorDBService(vector_db)
            for item in mapped_articles:
                vector_service.add_article(item)
            logger.info(f"Stored {len(mapped_articles)} articles in ChromaDB")
        except Exception as e:
            logger.error(f"Failed to store in ChromaDB: {e}")

    return mapped_articles
