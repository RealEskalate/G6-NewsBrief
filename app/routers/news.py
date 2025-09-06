from fastapi import APIRouter, HTTPException, Depends
import chromadb
from app.services.crawler import crawl_news
from app.services.news_api import fetch_news_api
from app.services.telegram import fetch_telegram
from app.services.cleaner import clean_news_data
from app.services.brief_generator import generate_brief
from app.services.vector_db import VectorDBService
from app.models.news import CrawlRequest, NewsAPIRequest, TelegramRequest, CleanedNews, VectorSearchQuery
from app.dependencies import get_vector_db
from typing import List, Dict, Optional

router = APIRouter(prefix="/news", tags=["news"])

@router.post("/gather", response_model=List[Dict])
async def gather_news(
    crawl_req: Optional[CrawlRequest] = None,
    api_req: Optional[NewsAPIRequest] = None,
    tg_req: Optional[TelegramRequest] = None,
    vector_db: chromadb.Client = Depends(get_vector_db)
):
    """Gather raw news from Crawl4AI, NewsAPI, or Telegram and store in ChromaDB."""
    raw_data = []
    try:
        if crawl_req:
            raw_data.extend(await crawl_news(crawl_req.urls, crawl_req.query, vector_db))
        if api_req:
            raw_data.extend(await fetch_news_api(api_req, vector_db))
        if tg_req:
            raw_data.extend(await fetch_telegram(tg_req.channels, tg_req.limit))
        if raw_data:
            clean_news_data(raw_data, VectorDBService(vector_db))  # Clean and store
        return raw_data
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.post("/clean", response_model=CleanedNews)
async def clean_news(raw_data: List[Dict], vector_db: chromadb.Client = Depends(get_vector_db)):
    """Clean raw data and store in ChromaDB."""
    try:
        cleaned = clean_news_data(raw_data, VectorDBService(vector_db))
        return {"articles": cleaned}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.post("/search", response_model=List[Dict])
async def search_news(query: VectorSearchQuery, vector_db: chromadb.Client = Depends(get_vector_db)):
    """Search articles semantically using ChromaDB."""
    try:
        results = VectorDBService(vector_db).search_articles(query.query, query.top_k)
        return results
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/briefs", response_model=str)
async def get_brief(query: str, top_k: int = 5, vector_db: chromadb.Client = Depends(get_vector_db)):
    """Generate AI-powered news brief using vector search."""
    try:
        articles = VectorDBService(vector_db).search_articles(query, top_k)
        texts = [f"{art['title']}: {art['text']}" for art in articles]
        brief = await generate_brief("\n".join(texts))
        return brief
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/stored", response_model=List[Dict])
async def get_stored_articles(limit: int = 10, vector_db: chromadb.Client = Depends(get_vector_db)):
    """Retrieve stored articles from ChromaDB."""
    try:
        articles = VectorDBService(vector_db).get_articles(limit)
        return articles
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))