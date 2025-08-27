from telethon import TelegramClient
from telethon.errors import SessionPasswordNeededError
from os import getenv
from typing import List, Dict
import asyncio

async def fetch_telegram(channels: List[str], limit: int) -> List[Dict]:
    """
    Functionality: Fetches recent messages from public Telegram channels using Telethon.
    - Creates a client session (no phone/login needed for public channels).
    - Treats each message as a 'news article' (title from channel, body from text).
    - Handles async for efficiency.
    - Note: For media, extend to download URLs.
    """
    api_id = int(getenv("TELEGRAM_API_ID"))
    api_hash = getenv("TELEGRAM_API_HASH")
    if not api_id or not api_hash:
        raise ValueError("TELEGRAM_API_ID or TELEGRAM_API_HASH not set in .env")
    
    client = TelegramClient('anon', api_id, api_hash)  # Anonymous session for public access
    await client.start()
    
    messages = []
    for channel in channels:
        entity = await client.get_entity(channel)
        async for msg in client.iter_messages(entity, limit=limit):
            if msg.text:  # Skip non-text
                messages.append({
                    "title": f"Message from {channel}",
                    "author": channel,
                    "date": msg.date,
                    "body": msg.text,
                    "source_url": f"https://t.me/{channel}/{msg.id}",
                    "source_type": "telegram"
                })
    await client.disconnect()
    return messages