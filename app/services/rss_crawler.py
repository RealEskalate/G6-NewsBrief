import feedparser
from datetime import datetime, timezone
from bs4 import BeautifulSoup
import re
import logging
import uuid
from typing import List, Dict

logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")
logger = logging.getLogger(__name__)

async def crawl_rss_feeds(sources: List[Dict], query: str) -> List[Dict]:
    """Crawl RSS feeds from sources and return filtered articles."""
    rss_articles = []
    for source in sources:
        try:
            logger.info(f"Fetching RSS feed: {source['feed']}")
            feed = feedparser.parse(source['feed'])
            if feed.bozo:
                logger.error(f"Failed to parse RSS feed {source['feed']}: {feed.bozo_exception}")
                continue

            for entry in feed.entries:
                title = entry.get('title', 'Untitled Article')
                link = entry.get('link', '')
                pub_date = entry.get('published', 'Not available')

                # Skip non-news or invalid links
                if not link or any(keyword in link.lower() for keyword in [
                    'category', 'tag', 'afaanoromoo', 'amharic', 'privacy-policy',
                    'contact-us', 'journal.addisstandard', 'peptide', 'roasted-garlic',
                    'exodus', 'women-at-the-top', 'advertisement'
                ]):
                    logger.debug(f"Excluding RSS entry {link}: Matches exclusion criteria")
                    continue

                # Filter by year
                if pub_date != "Not available":
                    try:
                        year = int(re.search(r'\d{4}', pub_date).group(0))
                        if year < 2024:
                            logger.warning(f"Skipping RSS article {link}: Published before 2024 ({pub_date})")
                            continue
                    except (ValueError, AttributeError):
                        logger.warning(f"Skipping RSS article {link}: Invalid published date ({pub_date})")
                        continue

                # Extract content
                content = entry.get('description', '') or entry.get('content', [{}])[0].get('value', '')
                if content:
                    soup = BeautifulSoup(content, 'html.parser')
                    content = soup.get_text(strip=True)
                    content = re.sub(r'\s+', ' ', content).strip()

                # Filter by query
                if query.lower() in title.lower() or (content and query.lower() in content.lower()):
                    rss_articles.append({
                        "title": title,
                        "content": content,
                        "source_url": link,
                        "source_site": source['name'],
                        "source_type": "rss",
                        "published_date": pub_date,
                        "crawl_timestamp": datetime.now(timezone.utc).isoformat(),
                        "_id": str(uuid.uuid4())
                    })
        except Exception as e:
            logger.error(f"Failed to process RSS feed {source['feed']}: {e}")

    return rss_articles