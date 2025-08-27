from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import datetime

class CrawlRequest(BaseModel):
    urls: List[str] = Field(..., description="List of news source URLs to crawl")
    query: Optional[str] = None

class NewsAPIRequest(BaseModel):
    query: str = Field(..., description="Search query for NewsAPI")
    sources: Optional[List[str]] = None
    from_date: Optional[str] = None
    to_date: Optional[str] = None

class TelegramRequest(BaseModel):
    channels: List[str] = Field(..., description="List of public Telegram channel usernames")
    limit: int = Field(10, description="Number of recent messages to fetch")

class NewsArticle(BaseModel):
    title: str
    author: Optional[str]
    date: Optional[datetime]
    body: str
    source_url: str
    source_type: str = "general"
    source_site: Optional[str] = None
    keyword: Optional[str] = None

class CleanedNews(BaseModel):
    articles: List[NewsArticle]

class VectorSearchQuery(BaseModel):
    query: str = Field(..., description="Text query for semantic search")
    top_k: int = Field(5, description="Number of results to return")