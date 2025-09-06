from app.services.lang_detector import detect_language
from crawl4ai import AsyncWebCrawler
from app.config import SITE_CONFIGS
from bs4 import BeautifulSoup
from datetime import datetime, timezone, timedelta
import logging
import re
import uuid
from typing import Dict
import asyncio
from app.utils.helpers import parse_date

logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")
logger = logging.getLogger(__name__)

async def extract_article_content(crawler: AsyncWebCrawler, url: str, title: str, source_site: str, semaphore, query: str) -> Dict:
    """Crawl a single article URL to extract full content, title, and metadata."""
    async with semaphore:
        for attempt in range(2):
            try:
                result = await crawler.arun(
                    url=url,
                    css_selector=".entry-content, .td-post-content, .post-content, .content, .tdb-block-inner, .td-block-span12, .td-block-span6, .td-excerpt, article",
                    word_count_threshold=20,
                    bypass_cache=True,
                    wait_until="domcontentloaded",
                    timeout=20000
                )
                await asyncio.sleep(2)
                soup = BeautifulSoup(result.html, 'html.parser')

                # Use SITE_CONFIGS selectors
                config = next((cfg for site, cfg in SITE_CONFIGS.items() if site in source_site.lower()), {})
                selectors = config.get("selectors", {})

                # Extract title
                if not title or len(title) < 20:
                    title_selector = selectors.get("title", "h1.entry-title, h1.td-post-title, h1.post-title, h1, .tdb-title-text")
                    title_element = soup.select_one(title_selector)
                    title = title_element.get_text(strip=True) if title_element else title or "Untitled Article"

                # Extract full content
                content_selector = selectors.get("content", ".entry-content, .td-post-content, .post-content, .content, .tdb-block-inner, .td-block-span12, .td-block-span6, article")
                content_elements = soup.select(content_selector)
                content = " ".join(elem.get_text(strip=True) for elem in content_elements if elem.get_text(strip=True))

                # Clean content
                unwanted_phrases = [
                    "Trending", "Show More", "Back to top button", "Editor’s Note",
                    "Random Article", "Sidebar", "Donate Here", "Facebook", "Twitter",
                    "Telegram", "TikTok", "Subscribe", "Follow Us", "Courtesy of",
                    "BY JOANNE BRUNO", "BY ZELA GAYLE", "BY ASHENAFI ZEDEBUB"
                ]
                for phrase in unwanted_phrases:
                    content = content.replace(phrase, "")
                content = re.sub(r'\s+', ' ', content).strip()
                content = re.sub(r'\[.*?\]\(.*?\)', '', content).strip()

                # Extract published date
                date_selector = selectors.get("date", ".entry-date, .td-post-date time, .post-date, .date-published, meta[property='article:published_time']")
                published_date = result.metadata.get('date', '')
                if not published_date:
                    meta_date = soup.select_one('meta[property="article:published_time"], meta[name="dc.date"]')
                    published_date = meta_date['content'] if meta_date and 'content' in meta_date.attrs else None
                    if not published_date:
                        date_element = soup.select_one(date_selector)
                        published_date = date_element.get_text(strip=True) if date_element else "Not available"

                # Filter by date (last 7 days)
                cutoff_date = datetime.now(timezone.utc).date() - timedelta(days=7)
                pub_datetime = parse_date(published_date) if published_date != "Not available" else None
                if not pub_datetime or pub_datetime.date() < cutoff_date:
                    logger.debug(f"Skipping article {url}: Published before {cutoff_date} ({published_date})")
                    return None

                # Skip invalid articles
                if len(content) < 50 or any(keyword in content.lower() for keyword in ["soup", "recipe", "privacy policy", "rastafarian", "advertisement"]):
                    logger.warning(f"Skipping article {url}: Content too short or non-news (length={len(content)})")
                    return None

                return {
                    "title": title,
                    "content": content,
                    "source_url": url,
                    "source_site": source_site,
                    "source_type": "crawl",
                    "published_date": pub_datetime.isoformat(),
                    "crawl_timestamp": datetime.now(timezone.utc).isoformat(),
                    "_id": str(uuid.uuid4()),
                    "pub_datetime": pub_datetime,  # For sorting
                    "lang": detect_language(content),
                }
            except Exception as e:
                logger.error(f"Attempt {attempt + 1} failed to crawl article {url}: {e}")
                if attempt < 1:
                    await asyncio.sleep(5)
                    continue
                return None