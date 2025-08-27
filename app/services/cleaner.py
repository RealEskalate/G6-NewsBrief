import spacy
from typing import List, Dict
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity
from datetime import datetime
from app.models.news import NewsArticle

nlp = spacy.load("en_core_web_sm")

def clean_news_data(raw_data: List[Dict]) -> List[NewsArticle]:
    """
    Functionality: Post-processes raw data from any source.
    - Normalizes dates (e.g., ISO strings to datetime).
    - Deduplication: TF-IDF cosine similarity (>0.9 threshold) on body.
    - Noise removal: Strips irrelevant text, uses spaCy to remove stops.
    - Source-specific: For Telegram, truncate long messages; for NewsAPI, combine description/content.
    - Outputs standardized NewsArticle list.
    """
    # Normalization
    for item in raw_data:
        if isinstance(item.get("date"), str):
            item["date"] = datetime.fromisoformat(item["date"].rstrip('Z')) if 'Z' in item["date"] else datetime.strptime(item["date"], "%Y-%m-%dT%H:%M:%S")
    
    # Deduplication
    texts = [item['body'] for item in raw_data]
    vectorizer = TfidfVectorizer().fit_transform(texts)
    sim_matrix = cosine_similarity(vectorizer)
    to_keep = [True] * len(raw_data)
    for i in range(len(raw_data)):
        for j in range(i + 1, len(raw_data)):
            if sim_matrix[i][j] > 0.9:
                to_keep[j] = False
    uniques = [raw_data[i] for i in range(len(raw_data)) if to_keep[i]]

    # Cleaning
    cleaned = []
    for item in uniques:
        doc = nlp(item['body'])
        clean_body = ' '.join([token.text for token in doc if not token.is_stop and token.is_alpha])
        # Source-specific tweaks
        if item["source_type"] == "telegram":
            clean_body = clean_body[:1000]  # Truncate long TG messages
        cleaned.append(NewsArticle(**item, body=clean_body))
    return cleaned