from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import datetime

class CrawlRequest(BaseModel):
    urls: List[str] = Field(..., description="List of news source URLs to crawl")
    query: Optional[str] = None  # Optional semantic query for adaptive crawling

class NewsAPIRequest(BaseModel):
    query: str = Field(..., description="Search query for NewsAPI")
    sources: Optional[List[str]] = None  # e.g., ['bbc-news', 'reuters']
    from_date: Optional[str] = None  # YYYY-MM-DD
    to_date: Optional[str] = None

class TelegramRequest(BaseModel):
    channels: List[str] = Field(..., description="List of public Telegram channel usernames (e.g., '@bbcnews')")
    limit: int = Field(10, description="Number of recent messages to fetch per channel")

class NewsArticle(BaseModel):
    title: str
    author: Optional[str]
    date: Optional[datetime]
    body: str
    source_url: str
    source_type: str = "general"  # e.g., 'crawl', 'newsapi', 'telegram'

class CleanedNews(BaseModel):
    articles: List[NewsArticle]