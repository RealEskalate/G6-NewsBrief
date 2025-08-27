from openai import AsyncOpenAI
from os import getenv
import logging

logger = logging.getLogger(__name__)

async def generate_brief(text: str) -> str:
    """Generate a news brief from input text using OpenAI."""
    client = AsyncOpenAI(api_key=getenv("OPENAI_API_KEY"))
    try:
        response = await client.chat.completions.create(
            model="gpt-4o",
            messages=[{"role": "user", "content": f"Summarize the following news articles into a concise brief:\n{text}"}]
        )
        return response.choices[0].message.content
    except Exception as e:
        logger.error(f"Brief generation failed: {e}")
        return "Failed to generate brief."