# NewsBrief MVP API Specification v1.0

## 2-Week MVP Implementation - Practical API Documentation

**Audience:** Frontend developers building the MVP  
**Scope:** Essential endpoints for 2-week implementation  
**Architecture:** 2 microservices (Core API + Scraper) + VectorDB + MongoDB

---

## 🌐 MVP Service Architecture (2-Service Model)

| Service                  | URL                         | Responsibility                                     |
| ------------------------ | --------------------------- | -------------------------------------------------- |
| **Core API** (Go Gin)    | `http://localhost:8080`     | User Auth, Feed, Stories, Summaries, Notifications |
| **Scraper** (FastAPI)    | `http://localhost:8001`     | Content extraction from URLs (HTTP)                |
| **Vector DB** (Pinecone) | `https://api.pinecone.io`   | Stores vector embeddings for semantic search       |
| **MongoDB**              | `mongodb://localhost:27017` | Primary data store                                 |

### **Architectural Changes:**

- Eliminated RabbitMQ for MVP: Core API directly calls Scraper over HTTP and processes results synchronously.
- Core API remains a monolith for auth, user, stories, summarization, briefs, and notifications.
- Embeddings are generated and stored by the Core API (Scraper returns clean text and metadata).

---

## 🔐 Authentication Endpoints (Part of Core API)

Handles user registration, login, and token management.

### **POST /v1/register**

Create new account.

**Request Body:**

```json
{
  "email": "user@example.com",
  "password": "SecureP@ssw0rd123!",
  "name": "John Doe",
  "lang": "am"
}
```

**Success Response (201):**

```json
{
  "user": {
    "id": "507f1f77bcf86cd799439011",
    "email": "user@example.com",
    "name": "John Doe",
    "email_verified": false,
    "preferences": {
      "lang": "am",
      "topics": [],
      "data_saver": true,
      "brief_type": "short",
      "notifications": {
        "daily_brief": true,
        "breaking_news": false
      }
    }
  },
  "verification_token_id": "66c1234567890abcdef1234a"
}
```

### **POST /v1/login**

User authentication.

**Request Body:**

```json
{
  "email": "user@example.com",
  "password": "SecureP@ssw0rd123!"
}
```

**Success Response (200):**

```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "66c1234567890abcdef12349",
  "expires_in": 3600
}
```

### **POST /v1/verify-email**

Email verification using unified token system.

**Request Body:**

```json
{
  "token": "66c1234567890abcdef1234a"
}
```

**Success Response (200):**

```json
{
  "message": "Email verified successfully",
  "email_verified": true
}
```

### **POST /v1/forgot-password**

Request password reset.

**Request Body:**

```json
{
  "email": "user@example.com"
}
```

**Success Response (200):**

```json
{
  "message": "Reset instructions sent",
  "reset_token_id": "66c1234567890abcdef1234c"
}
```

---

## 📱 Core API Endpoints (Go Gin - Port 8080)

### **GET /v1/feed**

Get paginated story feed with enhanced filtering.

**Query Parameters:**
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `lang` | `"am" \| "en"` | No | Summary language preference |
| `topic` | `string` | No | Topic filter |
| `source` | `string` | No | News outlet filter |
| `brief_type` | `"short" \| "medium"` | No | Summary type preference |
| `since` | `string` | No | ISO8601 timestamp |
| `limit` | `number` | No | Page size (1-50, default: 20) |
| `cursor` | `string` | No | Pagination cursor |

**Success Response (200):**

```json
{
  "items": [
    {
      "id": "507f1f77bcf86cd799439012",
      "title": "Ethiopia launches new agricultural initiative",
      "source": {
        "key": "addisstandard",
        "name": "Addis Standard",
        "logo_url": "https://cdn.newsbrief.et/sources/addisstandard.png"
      },
      "url": "https://addisstandard.com/news/ethiopia-agri-2025",
      "published_at": "2025-08-25T09:10:00Z",
      "summary_short": "Government announces $50M farming investment targeting 100,000 farmers.",
      "summary_bullets": [
        "Government announces $50M investment in rural farming",
        "Program targets 100,000 smallholder farmers nationwide",
        "Focus on drought-resistant crop varieties and irrigation"
      ],
      "summary_lang": "am",
      "topic_tags": ["agriculture", "economy"],
      "topic_image": "https://cdn.newsbrief.et/topics/agriculture.jpg",
      "processing_status": "completed",
      "reading_time": {
        "short": 1,
        "medium": 3
      }
    }
  ],
  "next_cursor": "eyJfaWQiOiI2NmMxMjM0NTY3ODkwYWJjZGVmMTIzNDUifQ==",
  "total_available": 156,
  "server_time": "2025-08-25T10:30:00Z"
}
```

---

### **GET /v1/story/:id**

Get detailed story by MongoDB ObjectId.

**Success Response (200):**

```json
{
  "id": "507f1f77bcf86cd799439012",
  "title": "Ethiopia launches new agricultural initiative",
  "source": {
    "key": "addisstandard",
    "name": "Addis Standard",
    "logo_url": "https://cdn.newsbrief.et/sources/addisstandard.png"
  },
  "url": "https://addisstandard.com/news/ethiopia-agri-2025",
  "published_at": "2025-08-25T09:10:00Z",
  "summary_short": "Government announces $50M farming investment.",
  "summary_bullets": [
    "Government announces $50M investment in rural farming",
    "Program targets 100,000 smallholder farmers nationwide",
    "Focus on drought-resistant crop varieties and irrigation"
  ],
  "summary_lang": "am",
  "topic_tags": ["agriculture", "economy"],
  "topic_image": "https://cdn.newsbrief.et/topics/agriculture.jpg",
  "reading_time": {
    "short": 1,
    "medium": 3
  },
  "word_count": 450,
  "scraped_at": "2025-08-25T09:05:00Z",
  "summarized_at": "2025-08-25T09:08:00Z"
}
```

---

### **GET /v1/search**

**MVP Implementation**: MongoDB text search + Semantic search via Vector DB.

**Query Parameters:**
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `q` | `string` | Yes | Search query (min 2 chars) |
| `type`| `"text" \| "semantic"` | No | Type of search (default: `text`) |
| `topic` | `string` | No | Topic filter |
| `source` | `string` | No | Source filter |
| `limit` | `number` | No | Results per page (1-50) |

**Success Response (200):**

```json
{
  "query": "agriculture investment",
  "items": [
    {
      "id": "507f1f77bcf86cd799439012",
      "title": "Ethiopia launches new agricultural initiative",
      "source": {
        "key": "addisstandard",
        "name": "Addis Standard",
        "logo_url": "https://cdn.newsbrief.et/sources/addisstandard.png"
      },
      "published_at": "2025-08-25T09:10:00Z",
      "summary_short": "Government announces $50M farming investment.",
      "topic_tags": ["agriculture", "economy"],
      "score": 0.89,
      "matched_terms": ["agriculture", "investment"]
    }
  ],
  "total_matches": 12,
  "search_method": "pinecone_vector_search"
}
```

---

### **GET /v1/topics**

Get topic categories with images and descriptions.

**Success Response (200):**

```json
{
  "topics": [
    {
      "key": "agriculture",
      "label": { "en": "Agriculture", "am": "ግብርና" },
      "description": {
        "en": "Farming, livestock, and agricultural development",
        "am": "የግብርና፣ የእንስሳት ሀብት እና የግብርና ልማት"
      },
      "image_url": "https://cdn.newsbrief.et/topics/agriculture.jpg",
      "story_count": 23
    },
    {
      "key": "economy",
      "label": { "en": "Economy", "am": "ኢኮኖሚ" },
      "description": {
        "en": "Business, finance, and economic news",
        "am": "የንግድ፣ የፋይናንስ እና የኢኮኖሚ ዜናዎች"
      },
      "image_url": "https://cdn.newsbrief.et/topics/economy.jpg",
      "story_count": 45
    }
  ],
  "total_topics": 6
}
```

---

### **GET /v1/sources**

Get available news outlets with subscription support.

**Query Parameters:**
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `subscribed_only` | `boolean` | No | Show only user's subscriptions |

**Success Response (200):**

```json
{
  "sources": [
    {
      "key": "addisstandard",
      "name": "Addis Standard",
      "description": "Independent news outlet covering Ethiopian politics",
      "url": "https://addisstandard.com",
      "logo_url": "https://cdn.newsbrief.et/sources/addisstandard.png",
      "languages": ["en", "am"],
      "topics": ["politics", "economy", "society"],
      "reliability_score": 0.92,
      "update_frequency": "hourly"
    }
  ],
  "total_sources": 12
}
```

---

## 👤 User Management Endpoints

### **GET /v1/me** 🔐

Get user profile and preferences.

**Success Response (200):**

```json
{
  "id": "507f1f77bcf86cd799439011",
  "email": "user@example.com",
  "name": "John Doe",
  "email_verified": true,
  "preferences": {
    "lang": "am",
    "topics": ["economy", "agriculture", "politics"],
    "subscribed_sources": ["addisstandard", "ethiopianherald"],
    "brief_type": "short",
    "data_saver": true,
    "notifications": {
      "daily_brief": true,
      "breaking_news": false
    }
  },
  "subscription": {
    "plan": "free",
    "source_limit": 5,
    "current_subscriptions": 2
  },
  "stats": {
    "stories_read": 147,
    "last_active": "2025-08-25T09:15:00Z"
  }
}
```

### **PATCH /v1/me/preferences** 🔐

Update user preferences, including notification settings.

**Request Body:**

```json
{
  "lang": "en",
  "topics": ["economy", "agriculture", "technology"],
  "brief_type": "medium",
  "data_saver": false,
  "notifications": {
    "daily_brief": false
  }
}
```

**Success Response (200):**

```json
{
  "preferences": {
    "lang": "en",
    "topics": ["economy", "agriculture", "technology"],
    "brief_type": "medium",
    "data_saver": false,
    "notifications": {
      "daily_brief": false,
      "breaking_news": false
    }
  },
  "updated_at": "2025-08-25T10:30:00Z"
}
```

### **PUT /v1/me/topics** 🔐

Replace the entire list of selected topics for the user.

**Request Body:**

```json
{ "topics": ["economy", "agriculture", "technology"] }
```

**Success Response (200):**

```json
{
  "topics": ["economy", "agriculture", "technology"],
  "updated_at": "2025-08-25T10:30:00Z"
}
```

### **PATCH /v1/me/topics** 🔐

Add or remove specific topics from the user's selection.

**Request Body (add):**

```json
{ "action": "add", "topics": ["politics"] }
```

**Request Body (remove):**

```json
{ "action": "remove", "topics": ["technology"] }
```

**Success Response (200):**

```json
{
  "topics": ["economy", "agriculture", "politics"],
  "updated_at": "2025-08-25T10:31:00Z"
}
```

### **GET /v1/me/subscriptions** 🔐

Get user's source subscriptions.

**Success Response (200):**

```json
{
  "subscriptions": [
    {
      "source_key": "addisstandard",
      "source_name": "Addis Standard",
      "subscribed_at": "2025-08-01T10:00:00Z",
      "topics": ["politics", "economy"]
    }
  ],
  "total_subscriptions": 2,
  "subscription_limit": 5
}
```

### **POST /v1/me/subscriptions** 🔐

Subscribe to a news outlet.

**Request Body:**

```json
{
  "source_key": "ethiopianherald",
  "topics": ["all"]
}
```

**Success Response (201):**

```json
{
  "subscription": {
    "source_key": "ethiopianherald",
    "source_name": "Ethiopian Herald",
    "topics": ["all"],
    "subscribed_at": "2025-08-25T10:30:00Z"
  },
  "total_subscriptions": 3
}
```

### **DELETE /v1/me/subscriptions/:source_key** 🔐

Unsubscribe from news outlet.

**Success Response (200):**

```json
{
  "message": "Successfully unsubscribed",
  "source_key": "addisstandard",
  "remaining_subscriptions": 2
}
```

### **PATCH /v1/me/password** 🔐

Change user password.

**Request Body:**

```json
{
  "current_password": "OldP@ssw0rd123!",
  "new_password": "NewSecureP@ssw0rd456!"
}
```

**Success Response (200):**

```json
{
  "message": "Password updated successfully"
}
```

---

## Daily Briefs & Notifications

### **GET /v1/briefs** 🔐

Get personalized daily briefs.

**Query Parameters:**
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `date` | `string` | No | Date in `YYYY-MM-DD` format (default: today) |
| `type` | `"morning" \| "evening"` | No | Type of brief (default: latest) |

**Success Response (200):**

```json
{
  "brief_id": "brief_66c1234567890abcdef1234e",
  "type": "morning",
  "date": "2025-08-26",
  "title": "Your Morning Briefing for August 26, 2025",
  "headline_story": {
    "id": "507f1f77bcf86cd799439012",
    "title": "Ethiopia launches new agricultural initiative",
    "summary_short": "Government announces $50M farming investment targeting 100,000 farmers."
  },
  "top_stories": [
    { "id": "...", "title": "...", "summary_short": "..." },
    { "id": "...", "title": "...", "summary_short": "..." }
  ],
  "generated_at": "2025-08-26T06:00:00Z"
}
```

### **GET /v1/me/notifications** 🔐

Get a list of notifications for the user.

**Success Response (200):**

```json
{
  "notifications": [
    {
      "id": "notif_66c1234567890abcdef1234f",
      "type": "daily_brief_ready",
      "title": "Your Morning Brief is ready!",
      "message": "Catch up on the latest news for August 26.",
      "data": { "brief_id": "brief_66c1234567890abcdef1234e" },
      "is_read": false,
      "created_at": "2025-08-26T06:01:00Z"
    }
  ],
  "unread_count": 1
}
```

### **POST /v1/me/notifications/mark-read** 🔐

Mark one or more notifications as read.

**Request Body:**

```json
{
  "notification_ids": ["notif_66c1234567890abcdef1234f"]
}
```

**Success Response (200):**

```json
{
  "message": "Notifications marked as read",
  "updated_count": 1
}
```

---

## 🔁 Synchronous Scraping Flow (No Queue)

The Core API calls the Scraper via HTTP and processes the response inline. This keeps deployment simple on Render and avoids managing a message broker.

- Core API -> Scraper: `POST {SCRAPER_BASE_URL}/v1/scrape`

**Request:**

```json
{
  "url": "https://addisstandard.com/news/ethiopia-agri-2025",
  "source_key": "addisstandard"
}
```

**Response:**

```json
{
  "title": "Ethiopia launches new agricultural initiative",
  "text": "The Ethiopian government today announced...",
  "published_at": "2025-08-25T09:10:00Z",
  "author": "...",
  "language": "en"
}
```

- Core API actions: sanitize -> summarize (Gemini) -> embed and upsert to Pinecone -> persist story to MongoDB.

---

## 🐳 MVP Deployment

```yaml
# docker-compose.yml
version: "3.8"
services:
  mongodb:
    image: mongo:7.0
    ports:
      - "27017:27017"

  core-api:
    build: ./core-api
    ports:
      - "8080:8080"
    depends_on:
      - mongodb
    environment:
      MONGODB_URI: "mongodb://mongodb:27017/newsbrief"
      SCRAPER_BASE_URL: "http://scraper:8001"
      PINECONE_API_KEY: ${PINECONE_API_KEY}
      GEMINI_API_KEY: ${GEMINI_API_KEY}

  scraper:
    build: ./scraper
    ports:
      - "8001:8001"
    environment:
      # Scraper does not need Pinecone in this simplified flow
      LOG_LEVEL: info
```

---

## 📝 Error Responses (Same as Full API)

All endpoints use consistent error format:

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Field validation failed",
    "details": { "field": "email", "reason": "invalid_format" },
    "request_id": "req_550e8400-e29b-41d4-a716-446655440000",
    "timestamp": "2025-08-25T10:30:00Z"
  }
}
```

**Common Status Codes:**

- `200` - Success
- `201` - Created
- `400` - Validation Error
- `401` - Authentication Required
- `403` - Forbidden
- `404` - Not Found
- `409` - Conflict (duplicate data)
- `429` - Rate Limited
- `500` - Internal Error

---

This MVP API specification provides everything needed for the 2-week implementation with the consolidated 2-service architecture and a simple, queue-less scraping flow.
