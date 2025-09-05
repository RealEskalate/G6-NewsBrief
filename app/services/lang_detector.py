import os
import langid

def detect_language(text: str) -> str:
    """Detect the language of the given text using langid library."""
    try:
        lang, _ = langid.classify(text)
        return lang
    except Exception as e:
        print(f"Language detection failed: {e}")
        return "unknown"