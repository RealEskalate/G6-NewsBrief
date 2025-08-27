import spacy
from typing import List, Dict
from datetime import datetime
import numpy as np
from app.models.news import NewsArticle
from app.utils.helpers import parse_date
from app.services.vector_db import VectorDBService
import logging

logger = logging.getLogger(__name__)
nlp = spacy.load("en_core_web_sm")

def clean_news_data(raw_data: List[Dict], vector_db: VectorDBService) -> List[NewsArticle]:
    """Post-process raw data and store in ChromaDB, using embedding-based deduplication."""
    # Normalize dates
    for item in raw_data:
        if isinstance(item.get("date"), str):
            parsed_date = parse_date(item["date"])
            item["date"] = parsed_date.isoformat() if parsed_date else item["date"]
    
    # Generate embeddings for deduplication
    texts = [f"{item['title']} {item['content'] if 'content' in item else item['body']}" for item in raw_data]
    embeddings = [vector_db.generate_embedding(text) for text in texts]
    
    # Deduplication using cosine similarity on embeddings
    to_keep = [True] * len(raw_data)
    for i in range(len(raw_data)):
        if not to_keep[i]:
            continue
        for j in range(i + 1, len(raw_data)):
            if not to_keep[j]:
                continue
            # Compute cosine similarity
            emb_i = np.array(embeddings[i])
            emb_j = np.array(embeddings[j])
            similarity = np.dot(emb_i, emb_j) / (np.linalg.norm(emb_i) * np.linalg.norm(emb_j))
            if similarity > 0.9:  # Threshold for near-duplicates
                to_keep[j] = False
                logger.info(f"Deduplicated article {j} (similarity {similarity:.2f} with article {i})")
    
    uniques = [raw_data[i] for i in range(len(raw_data)) if to_keep[i]]
    
    # Clean and convert to NewsArticle
    cleaned = []
    for item in uniques:
        content_key = 'content' if 'content' in item else 'body'
        doc = nlp(item[content_key])
        clean_body = ' '.join([token.text for token in doc if not token.is_stop and token.is_alpha])
        if item["source_type"] == "telegram":
            clean_body = clean_body[:1000]  # Truncate long Telegram messages
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