import re
from datetime import datetime, timedelta, timezone
import logging

logger = logging.getLogger(__name__)

async def parse_date(date_str):
    """Parse date string into datetime object."""
    if not date_str:
        return None
    try:
        date_formats = [
            "%Y-%m-%d", "%d/%m/%Y", "%B %d, %Y", "%Y/%m/%d",
            "%A, %B %d %Y", "%d %B %Y", "%Y-%m-%dT%H:%M:%S%z",
            "%d-%m-%Y", "%Y.%m.%d"
        ]
        for fmt in date_formats:
            try:
                return datetime.strptime(date_str, fmt).replace(tzinfo=timezone.utc)
            except ValueError:
                continue
        logger.debug(f"Could not parse date: {date_str}")
        return None
    except Exception as e:
        logger.debug(f"Failed to parse date {date_str}: {e}")
        return None

async def is_within_date_range(date_str, days_back=7):
    """Check if the article date is within the specified range (today to days_back)."""
    parsed_date = await parse_date(date_str)
    if not parsed_date:
        logger.info(f"Assuming recent for unparseable date: {date_str}")
        return True
    now = datetime.now(timezone.utc)
    cutoff_date = now - timedelta(days=days_back)
    return parsed_date >= cutoff_date

def matches_keyword(title, content, keyword):
    """Check if keyword appears in title or content (case-insensitive)."""
    if not keyword:
        return True
    keyword_lower = keyword.lower()
    return (keyword_lower in title.lower() or 
            (content and keyword_lower in content.lower()))

def clean_content(content, unwanted_phrases, exclude_keywords):
    """Clean content by removing unwanted phrases and checking for excluded keywords."""
    content = re.sub(r'\s+', ' ', content).strip()
    content = re.sub(r'\[.*?\]\(.*?\)', '', content).strip()
    for phrase in unwanted_phrases:
        content = content.replace(phrase, "")
    if len(content) < 100:
        return None
    if any(kw in content.lower() for kw in exclude_keywords):
        return None
    return content