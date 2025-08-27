import spacy
from typing import List, Dict
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity
from datetime import datetime
from app.models.news import NewsArticle
from app.utils.helpers import parse_date
from app.services.vector_db import VectorDBService
import logging

logger = logging.getLogger(__name__)
nlp = spacy.load("en_core_web_sm")

def clean_news_data(raw_data: List[Dict], vector_db: VectorDBService) -> List[NewsArticle]:
    """Post-process raw data and store in ChromaDB."""
    # Normalize dates
    for item in raw_data:
        if isinstance(item.get("date"), str):
            parsed_date = parse_date(item["date"])
            item["date"] = parsed_date.isoformat() if parsed_date else item["date"]
    
    # Deduplication using TF-IDF
    texts = [item['content'] if 'content' in item else item['body'] for item in raw_data]
    vectorizer = TfidfVectorizer().fit_transform(texts)
    sim_matrix = cosine_similarity(vectorizer)
    to_keep = [True] * len(raw_data)
    for i in range(len(raw_data)):
        for j in range(i + 1, len(raw_data)):
            if sim_matrix[i][j] > 0.9:
                to_keep[j] = False
    uniques = [raw_data[i] for i in range(len(raw_data)) if to_keep[i]]

    # Clean and convert to NewsArticle
    cleaned = []
    for item in uniques:
        content_key = 'content' if 'content' in item else 'body'
        doc = nlp(item[content_key])
        clean_body = ' '.join([token.text for token in doc if not token.is_stop and token.is_alpha])
        if item["source_type"] == "telegram":
            clean_body = clean_body[:1000]
        article = NewsArticle(
            title=item["title"],
            author=item.get("author", None),
            date=datetime.fromisoformat(item["date"]) if isinstance(item.get("date"), str) and item["date"] != "Not available" else None,
            body=clean_body,
            source_url=item.get("source_url", item.get("source_link")),
            source_type=item["source_type"],
            source_site=item.get("source_site", "unknown"),
            keyword=item.get("keyword", None)
        )
        cleaned.append(article)
    
    # Store in ChromaDB
    try:
        vector_db.store_articles(cleaned)
    except Exception as e:
        logger.error(f"Failed to store in vector DB: {e}")

    return cleaned