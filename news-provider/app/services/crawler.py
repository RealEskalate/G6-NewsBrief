import asyncio
from app.config import NEWS_SOURCES
import chromadb
from typing import List, Dict
from app.services.rss_crawler import crawl_rss_feeds
from app.services.homepage_crawler import crawl_homepages
from app.services.daily_scoop_crawler import crawl_daily_scoop
from app.services.article_extractor import extract_article_content
from app.services.vector_db import VectorDBService
from crawl4ai import AsyncWebCrawler
import logging
from datetime import datetime

logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")
logger = logging.getLogger(__name__)

async def crawl_news(urls: List[str], query: str, vector_db: chromadb.Client = None) -> List[Dict]:
    """Crawl news articles from URLs, RSS feeds, and daily-scoop, fetching full content and sorting by date."""
    async with AsyncWebCrawler(verbose=True, playwright_stealth=False) as crawler:
        semaphore = asyncio.Semaphore(3)
        news_data = []

        # Step 1: Crawl RSS feeds
        logger.info(f"Starting RSS crawl for {len(NEWS_SOURCES)} sources")
        rss_articles = await crawl_rss_feeds(NEWS_SOURCES, query)
        logger.info(f"Extracted {len(rss_articles)} articles from RSS feeds")

        # Step 2: Crawl homepages
        logger.info(f"Starting homepage crawl for {len(urls)} URLs")
        scrape_articles = await crawl_homepages(crawler, NEWS_SOURCES, urls, query, semaphore)
        logger.info(f"Extracted {len(scrape_articles)} articles from homepages")

        # Step 3: Crawl Addis Standard daily-scoop
        daily_scoop_items = []
        if any("addisstandard.com" in url for url in urls):
            logger.info("Starting Daily Scoop crawl")
            daily_scoop_items = await crawl_daily_scoop(crawler, semaphore, query)
            logger.info(f"Extracted {len(daily_scoop_items)} Daily Scoop items")
            scrape_articles.extend(daily_scoop_items)

        # Step 4: Combine and deduplicate articles
        all_articles = []
        seen_links = set()
        for article in rss_articles + scrape_articles:
            if article["source_url"] not in seen_links:
                all_articles.append(article)
                seen_links.add(article["source_url"])
        logger.info(f"Total unique articles after deduplication: {len(all_articles)}")

        # Step 5: Fetch full content for all articles
        tasks = []
        for article in all_articles[:50]:
            tasks.append(extract_article_content(crawler, article["source_url"], article["title"], article["source_site"], semaphore, query))
        
        results = await asyncio.gather(*tasks, return_exceptions=True)
        
        # Step 6: Process results
        for article, result in zip(all_articles, results):
            if isinstance(result, Exception):
                logger.error(f"Error crawling {article['source_url']}: {result}")
                continue
            if not result:
                logger.warning(f"No data extracted for {article['source_url']}")
                continue
            if not query or query.lower() in result["title"].lower() or query.lower() in result["content"].lower():
                news_data.append(result)
            if len(news_data) >= 20:
                break
        logger.info(f"Filtered {len(news_data)} articles matching query '{query}'")

        # Step 7: Sort by publication date (newest first)
        news_data.sort(key=lambda x: x["pub_datetime"] if x["pub_datetime"] else datetime.min, reverse=True)
        for article in news_data:
            article.pop("pub_datetime", None)  # Remove temporary sorting field

        # Step 8: Store in ChromaDB if vector_db is provided
        if vector_db:
            try:
                vector_service = VectorDBService(vector_db)
                for item in news_data:
                    vector_service.add_article(item)
                logger.info(f"Stored {len(news_data)} articles in ChromaDB")
            except Exception as e:
                logger.error(f"Failed to store in ChromaDB: {e}")

        return news_data