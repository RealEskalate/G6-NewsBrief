import re
from datetime import datetime, timedelta, timezone
import logging

logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")
logger = logging.getLogger(__name__)

def parse_date(date_str: str) -> datetime | None:
    """Parse various date formats into a datetime object in UTC."""
    if not date_str:
        return None
    try:
        date_formats = [
            "%Y-%m-%dT%H:%M:%S%z",  # ISO 8601 with timezone (e.g., 2025-08-28T10:30:00+03:00)
            "%a, %d %b %Y %H:%M:%S %z",  # RSS common (e.g., Thu, 28 Aug 2025 10:30:00 +0300)
            "%Y-%m-%d %H:%M:%S",  # Simple datetime (e.g., 2025-08-28 10:30:00)
            "%d %b %Y",  # Short date (e.g., 28 Aug 2025)
            "%Y-%m-%d",  # ISO date (e.g., 2025-08-28)
            "%B %d, %Y %H:%M %Z",  # Full month with time (e.g., August 28, 2025 10:30 EAT)
            "%B %d, %Y",  # Full month no time (e.g., August 28, 2025)
            "%d/%m/%Y",  # Short slashed (e.g., 28/08/2025)
            "%Y/%m/%d",  # Alternative slashed (e.g., 2025/08/28)
            "%d-%m-%Y",  # Hyphenated (e.g., 28-08-2025)
            "%Y.%m.%d",  # Dotted (e.g., 2025.08.28)
            "%A, %B %d %Y"  # Full weekday (e.g., Thursday, August 28 2025)
        ]
        for fmt in date_formats:
            try:
                parsed = datetime.strptime(date_str, fmt)
                # If format includes timezone (%z), keep it; otherwise, assume UTC
                if "%z" in fmt:
                    return parsed
                return parsed.replace(tzinfo=timezone.utc)
            except ValueError:
                continue
        logger.debug(f"Could not parse date: {date_str}")
        return None
    except Exception as e:
        logger.debug(f"Failed to parse date {date_str}: {e}")
        return None

def is_within_date_range(date_str: str, days_back: int = 7) -> bool:
    """Check if the article date is within the specified range (today to days_back)."""
    parsed_date = parse_date(date_str)
    if not parsed_date:
        logger.info(f"Assuming recent for unparseable date: {date_str}")
        return True
    now = datetime.now(timezone.utc)
    cutoff_date = now - timedelta(days=days_back)
    return parsed_date >= cutoff_date

def matches_keyword(title: str, content: str, keyword: str) -> bool:
    """Check if keyword appears in title or content (case-insensitive)."""
    if not keyword:
        return True
    keyword_lower = keyword.lower()
    return (keyword_lower in title.lower() or 
            (content and keyword_lower in content.lower()))

def clean_content(content: str, unwanted_phrases: list, exclude_keywords: list) -> str | None:
    """Clean content by removing unwanted phrases and checking for excluded keywords."""
    content = re.sub(r'\s+', ' ', content).strip()
    content = re.sub(r'\[.*?\]\(.*?\)', '', content).strip()
    for phrase in unwanted_phrases:
        content = content.replace(phrase, "")
    if len(content) < 50:
        logger.warning(f"Content too short: {len(content)} characters")
        return None
    if any(kw in content.lower() for kw in exclude_keywords):
        logger.warning(f"Content contains excluded keywords: {content[:50]}...")
        return None
    return content