from fastapi import APIRouter, Depends, HTTPException
from app.services.crawler import crawl_news
from app.services.news_api import fetch_news_api
from app.services.telegram import fetch_telegram
from app.services.cleaner import clean_news_data
from app.services.brief_generator import generate_brief  # Optional
from app.models.news import CrawlRequest, NewsAPIRequest, TelegramRequest, CleanedNews
from typing import List, Dict

router = APIRouter(prefix="/news", tags=["news"])

@router.post("/gather", response_model=List[Dict])
async def gather_news(
    crawl_req: Optional[CrawlRequest] = None,
    api_req: Optional[NewsAPIRequest] = None,
    tg_req: Optional[TelegramRequest] = None
):
    """
    Functionality: Gathers raw news from multiple sources (Crawl4AI, NewsAPI, Telegram).
    - Provide one or more request bodies; combines results.
    - Returns raw data from each source.
    - Error handling: Raises 400 if fetch fails.
    """
    raw_data = []
    try:
        if crawl_req:
            raw_data.extend(await crawl_news(crawl_req.urls, crawl_req.query))
        if api_req:
            raw_data.extend(await fetch_news_api(api_req))
        if tg_req:
            raw_data.extend(await fetch_telegram(tg_req.channels, tg_req.limit))
        return raw_data
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.post("/clean", response_model=CleanedNews)
async def clean_news(raw_data: List[Dict]):
    """
    Functionality: Cleans raw data from any source.
    - Normalizes to NewsArticle format, removes noise, deduplicates.
    - Handles source-specific quirks (e.g., Telegram messages as body).
    """
    try:
        cleaned = clean_news_data(raw_data)
        return {"articles": cleaned}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.get("/briefs", response_model=str)
async def get_brief(query: str):
    """
    Functionality: (Optional) Generates AI-powered news brief.
    - Can use gathered/cleaned data filtered by query.
    """
    try:
        brief = await generate_brief(query)
        return brief
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))