import re
from bs4 import BeautifulSoup
from typing import List

def clean_content(content: str) -> str:
    """Clean content by removing unwanted phrases and normalizing whitespace."""
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
    return content

def is_valid_article(content: str, published_date: str) -> bool:
    """Check if article is valid (not too short, not non-news, post-2024)."""
    if len(content) < 50 or any(keyword in content.lower() for keyword in ["soup", "recipe", "privacy policy", "rastafarian", "advertisement"]):
        return False
    if published_date != "Not available":
        try:
            year = int(re.search(r'\d{4}', published_date).group(0))
            if year < 2024:
                return False
        except (ValueError, AttributeError):
            return False
    return True