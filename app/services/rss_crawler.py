from app.config import GENRES
from app.services.lang_detector import detect_language
import feedparser
from datetime import datetime, timezone, timedelta
from bs4 import BeautifulSoup
import re
import logging
import uuid
from typing import List, Dict
from app.utils.helpers import parse_date, matches_genre

logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")
logger = logging.getLogger(__name__)

async def crawl_rss_feeds(sources: List[Dict], query: str, genre: str | None = None) -> List[Dict]:
    """Crawl RSS feeds from sources and return filtered articles from the last 7 days."""
    rss_articles = []
    cutoff_date = datetime.now(timezone.utc).date() - timedelta(days=7)
    for source in sources:
        # Use genre-specific category feed if available, else general feeds
        feed_urls = []
        if genre and source["name"] in GENRES.get(genre.lower(), {}).get("category_feeds", {}):
            feed_urls.append(GENRES[genre.lower()]["category_feeds"][source["name"]])
        else:
            feed_urls.extend([source["feed"], source.get("category_feed")])

        for feed_url in feed_urls:
            if not feed_url:
                continue
            try:
                logger.info(f"Fetching RSS feed: {feed_url}")
                feed = feedparser.parse(feed_url)
                if feed.bozo:
                    logger.error(f"Failed to parse RSS feed {feed_url}: {feed.bozo_exception}")
                    continue

                for entry in feed.entries:
                    title = entry.get('title', 'Untitled Article')
                    link = entry.get('link', '')
                    pub_date = entry.get('published', 'Not available')

                    # Skip non-news or invalid links
                    if not link or any(keyword in link.lower() for keyword in [
                        'category', 'tag', 'privacy-policy', 'contact-us',
                        'journal.addisstandard', 'peptide', 'roasted-garlic',
                        'exodus', 'women-at-the-top', 'advertisement'
                    ]):
                        logger.debug(f"Excluding RSS entry {link}: Matches exclusion criteria")
                        continue

                    # Filter by date (last 7 days)
                    pub_datetime = parse_date(pub_date) if pub_date != "Not available" else None
                    if not pub_datetime or pub_datetime.date() < cutoff_date:
                        logger.debug(f"Skipping RSS article {link}: Published before {cutoff_date} ({pub_date})")
                        continue

                    # Extract content
                    content = entry.get('description', '') or entry.get('content', [{}])[0].get('value', '')
                    if content:
                        soup = BeautifulSoup(content, 'html.parser')
                        content = soup.get_text(strip=True)
                        content = re.sub(r'\s+', ' ', content).strip()

                    # Filter by query and genre
                    if (not query or query.lower() in title.lower() or (content and query.lower() in content.lower())) and \
                       (not genre or matches_genre(title, content, genre)):
                        rss_articles.append({
                            "title": title,
                            "content": content,
                            "source_url": link,
                            "source_site": source['name'],
                            "source_type": "rss",
                            "published_date": pub_datetime.isoformat() if pub_datetime else "Not available",
                            "crawl_timestamp": datetime.now(timezone.utc).isoformat(),
                            "_id": str(uuid.uuid4()),
                            "pub_datetime": pub_datetime,  # For sorting
                            "lang": detect_language(content) if content else None
                        })
                logger.info(f"Extracted {len(rss_articles)} articles from {feed_url}")
            except Exception as e:
                logger.error(f"Failed to process RSS feed {feed_url}: {e}")

    # Sort by publication date (newest first)
    rss_articles.sort(key=lambda x: x["pub_datetime"] if x["pub_datetime"] else datetime.min, reverse=True)
    for article in rss_articles:
        article.pop("pub_datetime", None)  # Remove temporary sorting field
    return rss_articles