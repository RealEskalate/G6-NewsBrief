import asyncio
from crawl4ai import AsyncWebCrawler
from bs4 import BeautifulSoup
from datetime import datetime, timezone, timedelta
import logging
import re
from typing import List, Dict
import uuid
from app.utils.helpers import parse_date

logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")
logger = logging.getLogger(__name__)

async def crawl_daily_scoop(crawler: AsyncWebCrawler, semaphore, query: str) -> List[Dict]:
    """Crawl Addis Standard daily-scoop page to extract news items from the last 7 days."""
    async with semaphore:
        for attempt in range(2):
            try:
                result = await crawler.arun(
                    url="https://addisstandard.com/daily-scoop",
                    css_selector=".td-block-span12, .td_module_wrap, .td-block-span6, .tdb-block-inner, .entry-title a, .td-excerpt",
                    word_count_threshold=10,
                    bypass_cache=True,
                    wait_until="domcontentloaded",
                    timeout=20000
                )
                await asyncio.sleep(2)
                soup = BeautifulSoup(result.html, 'html.parser')
                news_items = []
                cutoff_date = datetime.now(timezone.utc).date() - timedelta(days=7)

                for item in soup.select(".td-block-span12, .td_module_wrap, .td-block-span6"):
                    title_elem = item.select_one("h3 a, .entry-title a, .td-post-title a")
                    title = title_elem.get_text(strip=True) if title_elem else "Untitled Scoop Item"
                    link = title_elem['href'] if title_elem and 'href' in title_elem.attrs else None
                    if not link or not re.search(r'/(202[4-9])/', link):
                        logger.debug(f"Skipping Daily Scoop item {link}: Invalid or old URL")
                        continue
                    content_elem = item.select_one("p, .td-excerpt, .td-post-text-excerpt")
                    content = content_elem.get_text(strip=True) if content_elem else ""
                    if len(content) < 20:
                        logger.debug(f"Skipping Daily Scoop item {link}: Content too short (length={len(content)})")
                        continue

                    # Assume Daily Scoop items are recent, but attempt to extract date
                    date_elem = item.select_one(".entry-date, .td-post-date time, .post-date, .date-published")
                    pub_date = date_elem.get_text(strip=True) if date_elem else "Not available"
                    pub_datetime = parse_date(pub_date) if pub_date != "Not available" else datetime.now(timezone.utc)
                    if pub_datetime.date() < cutoff_date:
                        logger.debug(f"Skipping Daily Scoop item {link}: Published before {cutoff_date} ({pub_date})")
                        continue

                    if not query or query.lower() in title.lower() or query.lower() in content.lower():
                        news_items.append({
                            "title": title,
                            "content": content,
                            "source_url": link,
                            "source_site": "Addis Standard",
                            "source_type": "crawl",
                            "published_date": pub_datetime.isoformat(),
                            "crawl_timestamp": datetime.now(timezone.utc).isoformat(),
                            "_id": str(uuid.uuid4()),
                            "pub_datetime": pub_datetime  # For sorting
                        })
                logger.info(f"Extracted {len(news_items)} Daily Scoop items")
                news_items.sort(key=lambda x: x["pub_datetime"], reverse=True)
                for item in news_items:
                    item.pop("pub_datetime", None)  # Remove temporary sorting field
                return news_items
            except Exception as e:
                logger.error(f"Attempt {attempt + 1} failed to crawl Daily Scoop: {e}")
                if attempt < 1:
                    await asyncio.sleep(5)
                    continue
                return []