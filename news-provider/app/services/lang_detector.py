import langid

_initialized = False

def detect_language(text: str) -> str:
    """Detect the language of the given text using langid library."""
    global _initialized
    try:
        if not _initialized:
            langid.set_languages(['en', 'am'])
            _initialized = True
        lang, _ = langid.classify(text)
        return lang
    except Exception as e:
        print(f"Language detection failed: {e}")
        return "unknown"
