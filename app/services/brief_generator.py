from openai import AsyncOpenAI
from os import getenv

async def generate_brief(query: str) -> str:
    """
    Functionality: Uses LLM to generate a news brief from cleaned data.
    - Fetches from DB or in-memory.
    - Prompt: "Summarize recent news on [query] into a brief."
    """
    client = AsyncOpenAI(api_key=getenv("OPENAI_API_KEY"))
    response = await client.chat.completions.create(
        model="gpt-4o",
        messages=[{"role": "user", "content": f"Summarize news on {query}"}]
    )
    return response.choices[0].message.content