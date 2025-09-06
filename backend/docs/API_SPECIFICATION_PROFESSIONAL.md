# NewsBrief Backend API Specification v1.0

## Professional-Grade API Documentation

**Audience:** Frontend engineers, DevOps, Backend integrators  
**Scope:** Production-ready API for mobile-first Ethiopian news platform  
**Standards:** REST Level 3, OpenAPI 3.0 compatible, FAANG production quality

---

## 🌐 Base URLs & Environment Strategy

| Environment | Core API                           | Scraper                       | Summarizer                       | Vector DB                      | Search API                   |
| ----------- | ---------------------------------- | ----------------------------- | -------------------------------- | ------------------------------ | ---------------------------- |
| Local Dev   | `http://localhost:8080`            | `http://localhost:8001`       | `http://localhost:8002`          | `http://localhost:8003`        | `http://localhost:8004`      |
| Staging     | `https://api-staging.newsbrief.et` | `http://scraper-staging:8001` | `http://summarizer-staging:8002` | `http://vectordb-staging:8003` | `http://search-staging:8004` |
| Production  | `https://api.newsbrief.et`         | `http://scraper:8001`         | `http://summarizer:8002`         | `http://vectordb:8003`         | `http://search:8004`         |

## 🔐 Authentication & Security

### **JWT Token Format (MongoDB ObjectId)**

```json
{
  "sub": "507f1f77bcf86cd799439011",
  "iss": "newsbrief.et",
  "exp": 1693123200,
  "iat": 1693119600,
  "aud": ["mobile", "web"],
  "scope": ["read:stories", "write:preferences"],
  "email_verified": true,
  "token_id": "66c1234567890abcdef12345"
}
```

### **Unified Token System**

All authentication tokens (refresh, email verification, password reset) are managed in a single MongoDB collection with discriminator fields:

```javascript
// MongoDB tokens collection structure
{
  _id: ObjectId("66c1234567890abcdef12345"),
  user_id: ObjectId("507f1f77bcf86cd799439011"),
  token_type: "refresh_token", // "email_verify" | "password_reset"
  token_hash: "sha256_hash_value",
  expires_at: ISODate("2025-08-26T10:30:00Z"),
  device_info: { // only for refresh_token
    user_agent: "NewsBrief/1.0.0 (iOS 16.0; iPhone14,2)",
    ip_address: "192.168.1.100"
  },
  used_at: null, // only for one-time tokens (email_verify, password_reset)
  created_at: ISODate("2025-08-25T10:30:00Z")
}
```

### **Request Headers (Required)**

```yaml
Content-Type: application/json
Accept: application/json
User-Agent: "NewsBrief/1.0.0 (iOS 16.0; iPhone14,2)"
X-Request-ID: "req_550e8400-e29b-41d4-a716-446655440000"
Authorization: "Bearer <jwt_token>" # For protected endpoints
```

### **Security Response Headers**

```yaml
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
X-XSS-Protection: "1; mode=block"
Strict-Transport-Security: "max-age=31536000; includeSubDomains"
X-RateLimit-Limit: "60"
X-RateLimit-Remaining: "45"
X-RateLimit-Reset: "1693123200"
X-Response-Time: "234"
```

### **Rate Limiting Policy**

| Endpoint Pattern                | Limit   | Window | Scope    | Premium Multiplier |
| ------------------------------- | ------- | ------ | -------- | ------------------ |
| `GET /v1/feed`                  | 60 req  | 1 min  | Per IP   | 2x                 |
| `GET /v1/search`                | 30 req  | 1 min  | Per IP   | 3x                 |
| `POST /v1/chat/query`           | 5 req   | 1 min  | Per User | 4x                 |
| `POST /v1/auth/login`           | 5 req   | 1 min  | Per IP   | N/A                |
| `PATCH /v1/me/*`                | 120 req | 1 min  | Per User | 1.5x               |
| `POST /v1/me/subscriptions`     | 10 req  | 1 min  | Per User | 2x                 |
| `DELETE /v1/me/subscriptions/*` | 10 req  | 1 min  | Per User | 2x                 |
| `GET /v1/sources`               | 30 req  | 1 min  | Per IP   | 2x                 |

---

## 📊 Standardized Error Response Model

**All error responses use consistent structure:**

```typescript
interface ErrorResponse {
  error: {
    code: string; // Machine-readable error code
    message: string; // Human-readable message
    details?: object; // Additional context
    request_id: string; // For debugging/support
    timestamp: string; // ISO8601
  };
}
```

### **Standard Error Codes**

```yaml
VALIDATION_ERROR: # 400 - Invalid request data
  message: "Field validation failed"
  details: { field: "email", reason: "invalid_format" }

AUTHENTICATION_REQUIRED: # 401 - Missing/invalid token
  message: "Valid authentication required"

FORBIDDEN: # 403 - Insufficient permissions
  message: "Access denied for this resource"

RESOURCE_NOT_FOUND: # 404 - Endpoint or data not found
  message: "Requested resource does not exist"

CONFLICT: # 409 - Duplicate/conflicting data
  message: "Resource already exists"
  details: { field: "email", value: "user@example.com" }

RATE_LIMIT_EXCEEDED: # 429 - Too many requests
  message: "Rate limit exceeded"
  details: { retry_after: 60, limit: 60 }

INTERNAL_ERROR: # 500 - Server-side failure
  message: "Internal server error"

SERVICE_UNAVAILABLE: # 503 - Dependency failure
  message: "Upstream service unavailable"
  details: { service: "summarizer", retry_after: 30 }
```

---

## 📱 Public API Endpoints (Go Gin)

### **GET /v1/feed**

Get paginated story feed with filtering capabilities.

**Query Parameters:**
| Field | Type | Required | Description | Example |
|-------|------|----------|-------------|---------|
| `lang` | `"am" \| "en"` | No | Summary language preference | `am` |
| `topic` | `string` | No | Topic filter from `/v1/topics` | `economy` |
| `source` | `string` | No | News outlet filter | `addisstandard` |
| `brief_type` | `"short" \| "medium"` | No | Summary length preference | `short` |
| `since` | `string` | No | ISO8601 timestamp | `2025-08-25T00:00:00Z` |
| `limit` | `number` | No | Page size (1-50) | `20` |
| `cursor` | `string` | No | Pagination cursor | `eyJ0aW1lc3RhbXAiOjE2OTMxMjMyMDB9` |

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
      "summary_short": "Government announces $50M investment in rural farming targeting 100,000 farmers.",
      "summary_bullets": [
        "Government announces $50M investment in rural farming",
        "Program targets 100,000 smallholder farmers nationwide",
        "Focus on drought-resistant crop varieties and irrigation",
        "Initiative includes training programs and equipment subsidies",
        "Expected to increase agricultural productivity by 35%"
      ],
      "summary_lang": "am",
      "topic_tags": ["agriculture", "economy"],
      "topic_image": "https://cdn.newsbrief.et/topics/agriculture.jpg",
      "processing_status": "completed",
      "content_hash": "sha256:a1b2c3d4e5f6...",
      "reading_time_minutes": {
        "short": 1,
        "medium": 3
      },
      "engagement_score": 0.87
    }
  ],
  "next_cursor": "eyJfaWQiOiI2NmMxMjM0NTY3ODkwYWJjZGVmMTIzNDUifQ==",
  "total_available": 156,
  "server_time": "2025-08-25T10:30:00Z"
}
```

**Error Responses:**

- `400` - Invalid query parameters
- `429` - Rate limit exceeded
- `500` - Internal server error

---

### **GET /v1/story/:id**

Get detailed story by ID.

**Path Parameters:**
| Field | Type | Description |
|-------|------|-------------|
| `id` | `string` | MongoDB ObjectId (24-char hex string) |

**Success Response (200):**

```json
{
  "id": "507f1f77bcf86cd799439012",
  "title": "Ethiopia launches new agricultural initiative",
  "source": "addisstandard.com",
  "url": "https://addisstandard.com/news/ethiopia-agri-2025",
  "published_at": "2025-08-25T09:10:00Z",
  "summary_bullets": [
    "Government announces $50M investment in rural farming",
    "Program targets 100,000 smallholder farmers nationwide",
    "Focus on drought-resistant crop varieties and irrigation"
  ],
  "summary_lang": "am",
  "topic_tags": ["agriculture", "economy"],
  "processing_status": "completed",
  "content_hash": "sha256:a1b2c3d4e5f6...",
  "reading_time_minutes": 3,
  "word_count": 450,
  "scraped_at": "2025-08-25T09:05:00Z",
  "summarized_at": "2025-08-25T09:08:00Z"
}
```

**Error Responses:**

- `404` - Story not found
- `429` - Rate limit exceeded
- `500` - Internal server error

---

### **GET /v1/search**

Full-text search across stories.

**Query Parameters:**
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `q` | `string` | Yes | Search query (min 2 chars) |
| `lang` | `"am" \| "en"` | No | Preferred result language |
| `topic` | `string` | No | Topic filter |
| `since` | `string` | No | ISO8601 timestamp |
| `limit` | `number` | No | Results per page (1-50) |
| `cursor` | `string` | No | Pagination cursor |

**Success Response (200):**

```json
{
  "query": "agriculture investment",
  "items": [
    {
      "id": "507f1f77bcf86cd799439012",
      "title": "Ethiopia launches new agricultural initiative",
      "source": "addisstandard.com",
      "url": "https://addisstandard.com/news/ethiopia-agri-2025",
      "published_at": "2025-08-25T09:10:00Z",
      "summary_bullets": ["Government announces...", "..."],
      "summary_lang": "am",
      "topic_tags": ["agriculture", "economy"],
      "processing_status": "completed",
      "relevance_score": 0.95,
      "matched_terms": ["agriculture", "investment"],
      "text_score": 1.2,
      "highlight_snippets": [
        "Government announces $50M <mark>investment</mark> in rural <mark>agriculture</mark>",
        "New <mark>agricultural</mark> <mark>investment</mark> program launches nationwide"
      ]
    }
  ],
  "next_cursor": "eyJfaWQiOiI2NmMxMjM0NTY3ODkwYWJjZGVmMTIzNDYiLCJzY29yZSI6MC45NX0=",
  "total_matches": 12,
  "search_time_ms": 45,
  "mongodb_text_index_used": true
}
```

**Error Responses:**

- `400` - Missing or invalid query
- `429` - Rate limit exceeded
- `500` - Internal server error

---

### **GET /v1/daily-brief**

Get curated morning/evening story collection.

**Query Parameters:**
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `slot` | `"am" \| "pm"` | Yes | Brief timing |
| `lang` | `"am" \| "en"` | No | Content language |
| `date` | `string` | No | ISO date (YYYY-MM-DD) |

**Success Response (200):**

```json
{
  "id": "66c1234567890abcdef12347",
  "slot": "am",
  "lang": "am",
  "date": "2025-08-25",
  "title": "የጠዋት ዜና ማጠቃለያ",
  "description": "Today's 5 most important stories for Ethiopia",
  "created_at": "2025-08-25T06:00:00Z",
  "story_count": 5,
  "estimated_read_time_minutes": 8,
  "curation_algorithm": "ai_scored_v1.2",
  "stories": [
    {
      "id": "507f1f77bcf86cd799439012",
      "title": "Ethiopia launches new agricultural initiative",
      "source": "addisstandard.com",
      "published_at": "2025-08-25T05:30:00Z",
      "summary_bullets": ["Government announces...", "..."],
      "summary_lang": "am",
      "topic_tags": ["agriculture"],
      "processing_status": "completed",
      "brief_position": 1,
      "curation_score": 0.95,
      "reading_time_minutes": 2
    }
  ],
  "content_hash": "sha256:f1g2h3i4j5k6...",
  "last_updated": "2025-08-25T06:00:00Z"
}
```

**Error Responses:**

- `400` - Invalid slot or date
- `404` - Brief not available
- `429` - Rate limit exceeded
- `500` - Internal server error

---

### **GET /v1/topics**

Get supported topic categories with localized labels and images.

**Success Response (200):**

```json
{
  "topics": [
    {
      "key": "economy",
      "label": { "en": "Economy", "am": "ኢኮኖሚ" },
      "description": {
        "en": "Business, finance, and economic news",
        "am": "የንግድ፣ የፋይናንስ እና የኢኮኖሚ ዜናዎች"
      },
      "image_url": "https://cdn.newsbrief.et/topics/economy.jpg",
      "story_count": 45,
      "subscribed_sources": 8,
      "last_updated": "2025-08-25T10:00:00Z"
    },
    {
      "key": "agriculture",
      "label": { "en": "Agriculture", "am": "ግብርና" },
      "description": {
        "en": "Farming, livestock, and agricultural development",
        "am": "የግብርና፣ የእንስሳት ሀብት እና የግብርና ልማት"
      },
      "image_url": "https://cdn.newsbrief.et/topics/agriculture.jpg",
      "story_count": 23,
      "subscribed_sources": 6,
      "last_updated": "2025-08-25T09:30:00Z"
    },
    {
      "key": "politics",
      "label": { "en": "Politics", "am": "ፖለቲካ" },
      "description": {
        "en": "Government, policy, and political developments",
        "am": "የመንግስት፣ የፖሊሲ እና የፖለቲካ እድገቶች"
      },
      "image_url": "https://cdn.newsbrief.et/topics/politics.jpg",
      "story_count": 31,
      "subscribed_sources": 12,
      "last_updated": "2025-08-25T08:45:00Z"
    }
  ],
  "total_topics": 8,
  "last_updated": "2025-08-20T00:00:00Z"
}
```

---

### **POST /v1/chat/query** 🔐

AI-powered news query with web search, scraping, and summarization.

**Request Body:**

```json
{
  "query": "What is the latest news about Ethiopia's renewable energy projects?",
  "lang": "am",
  "max_sources": 5,
  "brief_type": "medium"
}
```

**Success Response (200):**

```json
{
  "query_id": "507f1f77bcf86cd799439015",
  "query": "What is the latest news about Ethiopia's renewable energy projects?",
  "response": {
    "summary_bullets": [
      "Ethiopia launches 300MW solar power project in Afar region",
      "Government signs $2B renewable energy agreement with international partners",
      "New wind farm construction begins in Tigray with 200MW capacity",
      "Ethiopia targets 30GW renewable energy capacity by 2030",
      "Hydroelectric projects face environmental concerns from local communities"
    ],
    "summary_lang": "am",
    "confidence_score": 0.92,
    "sources_used": [
      {
        "url": "https://ethiopianherald.com/renewable-energy-2025",
        "title": "Ethiopia's Renewable Energy Expansion",
        "source": "Ethiopian Herald",
        "scraped_at": "2025-08-25T10:30:00Z",
        "relevance_score": 0.95
      },
      {
        "url": "https://addisstandard.com/energy-projects-2025",
        "title": "Solar and Wind Projects Launch",
        "source": "Addis Standard",
        "scraped_at": "2025-08-25T10:31:00Z",
        "relevance_score": 0.89
      }
    ],
    "vector_matches": 3,
    "new_scrapes": 2,
    "processing_time_ms": 2340
  },
  "created_at": "2025-08-25T10:30:00Z"
}
```

**Error Responses:**

- `400` - Invalid query format
- `429` - Rate limit exceeded (5 queries per minute)
- `503` - Search service unavailable

### **GET /v1/chat/history** 🔐

Get user's chat query history.

**Query Parameters:**
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `limit` | `number` | No | Results per page (1-50) |
| `cursor` | `string` | No | Pagination cursor |

**Success Response (200):**

```json
{
  "items": [
    {
      "query_id": "507f1f77bcf86cd799439015",
      "query": "What is the latest news about Ethiopia's renewable energy projects?",
      "created_at": "2025-08-25T10:30:00Z",
      "lang": "am",
      "sources_count": 5,
      "processing_time_ms": 2340
    }
  ],
  "next_cursor": "eyJfaWQiOiI2NmMxMjM0NTY3ODkwYWJjZGVmMTIzNDYifQ==",
  "total_queries": 12
}
```

### **GET /v1/chat/query/:id** 🔐

Get detailed results for a specific chat query.

**Path Parameters:**
| Field | Type | Description |
|-------|------|-------------|
| `id` | `string` | Query ID (MongoDB ObjectId) |

**Success Response (200):**
Same as POST `/v1/chat/query` response format.

---

### **GET /v1/sources**

Get available news outlets with subscription status.

**Query Parameters:**
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `search` | `string` | No | Search outlets by name |
| `country` | `string` | No | Filter by country code |
| `lang` | `"am" \| "en"` | No | Filter by language |
| `subscribed_only` | `boolean` | No | Show only subscribed outlets |

**Success Response (200):**

```json
{
  "sources": [
    {
      "key": "addisstandard",
      "name": "Addis Standard",
      "description": "Independent news outlet covering Ethiopian politics and society",
      "url": "https://addisstandard.com",
      "logo_url": "https://cdn.newsbrief.et/sources/addisstandard.png",
      "country": "ET",
      "languages": ["en", "am"],
      "topics": ["politics", "economy", "society"],
      "rss_feeds": [
        {
          "url": "https://addisstandard.com/feed/",
          "topic": "general",
          "active": true
        }
      ],
      "reliability_score": 0.92,
      "update_frequency": "hourly",
      "avg_articles_per_day": 15,
      "last_updated": "2025-08-25T10:15:00Z"
    },
    {
      "key": "ethiopianherald",
      "name": "Ethiopian Herald",
      "description": "Ethiopia's premier English daily newspaper",
      "url": "https://ethiopianherald.com",
      "logo_url": "https://cdn.newsbrief.et/sources/ethiopianherald.png",
      "country": "ET",
      "languages": ["en", "am"],
      "topics": ["politics", "economy", "international", "sports"],
      "rss_feeds": [
        {
          "url": "https://ethiopianherald.com/feed/",
          "topic": "general",
          "active": true
        }
      ],
      "reliability_score": 0.88,
      "update_frequency": "daily",
      "avg_articles_per_day": 8,
      "last_updated": "2025-08-25T09:30:00Z"
    }
  ],
  "total_sources": 25,
  "available_countries": ["ET", "KE", "UG"],
  "available_topics": [
    "politics",
    "economy",
    "agriculture",
    "society",
    "sports",
    "international"
  ]
}
```

---

### **GET /v1/sync/manifest**

Provide sync metadata for offline-first mobile apps.

**Query Parameters:**
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `since` | `string` | No | Client's last sync timestamp |
| `lang` | `"am" \| "en"` | No | Preferred content language |

**Success Response (200):**

```json
{
  "server_time": "2025-08-25T10:30:00Z",
  "content_version": "v1.2.3",
  "mongodb_replica_set": "rs0",
  "change_stream_token": "82640000...424344",
  "stories": {
    "total_count": 234,
    "updated_since": "2025-08-25T09:00:00Z",
    "new_count": 12,
    "updated_count": 3,
    "deleted_ids": ["507f1f77bcf86cd799439013", "507f1f77bcf86cd799439014"],
    "content_hash": "sha256:a1b2c3d4...",
    "last_object_id": "66c1234567890abcdef12348"
  },
  "daily_briefs": {
    "am": {
      "available": true,
      "brief_id": "66c1234567890abcdef12347",
      "date": "2025-08-25",
      "updated": "2025-08-25T06:00:00Z",
      "content_hash": "sha256:e5f6g7h8..."
    },
    "pm": {
      "available": false,
      "date": "2025-08-25",
      "next_expected": "2025-08-25T18:00:00Z"
    }
  },
  "topics": {
    "updated": "2025-08-20T00:00:00Z",
    "content_hash": "sha256:i9j0k1l2...",
    "mongodb_collection": "topic_definitions"
  },
  "sync_strategy": {
    "recommended_interval_minutes": 15,
    "full_sync_threshold_hours": 24,
    "use_change_streams": true,
    "cursor_pagination": true,
    "max_batch_size": 100
  }
}
```

---

### **GET /health**

Basic service health check.

**Success Response (200):**

```json
{
  "status": "ok",
  "timestamp": "2025-08-25T10:30:00Z",
  "version": "1.0.0"
}
```

---

## 🔑 Authentication Endpoints

### **GET /v1/auth/providers**

List available OAuth providers.

**Success Response (200):**

```json
{
  "providers": [
    {
      "key": "google",
      "name": "Google",
      "pkce_required": true,
      "scopes": ["openid", "email", "profile"]
    }
  ]
}
```

### **POST /v1/auth/oauth/exchange**

Exchange OAuth code for app tokens.

**Request Body:**

```json
{
  "provider": "google",
  "code": "4/0Adeu5BW...",
  "code_verifier": "dBjftJeZ4CVP-mB92K27uhbUJU1p1r_wW1gFWFOEjXk",
  "redirect_uri": "newsbrief://oauth/callback"
}
```

**Success Response (200):**

```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "66c1234567890abcdef12349",
  "expires_in": 3600,
  "token_type": "Bearer",
  "user": {
    "id": "507f1f77bcf86cd799439011",
    "email": "user@example.com",
    "name": "John Doe",
    "email_verified": true,
    "created_at": "2025-08-25T10:30:00Z",
    "preferences": {
      "lang": "am",
      "topics": ["economy", "politics"],
      "data_saver": false,
      "notifications": {
        "daily_brief": { "am": true, "pm": false },
        "wifi_only": true
      }
    }
  }
}
```

**Error Responses:**

- `400` - Invalid request parameters
- `401` - Invalid authorization code
- `502` - OAuth provider unavailable

### **POST /v1/auth/register**

Create new account with email/password.

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
    "preferred_lang": "am",
    "created_at": "2025-08-25T10:30:00Z",
    "preferences": {
      "lang": "am",
      "topics": [],
      "data_saver": true,
      "text_only": false,
      "notifications": {
        "daily_brief": { "am": true, "pm": false },
        "wifi_only": true,
        "sound_enabled": false
      },
      "audio_speed": 1.0,
      "cached_days": 7
    }
  },
  "verification_token_id": "66c1234567890abcdef1234a",
  "verification_sent": true
}
```

**Error Responses:**

- `400` - Validation error (weak password, invalid email)
- `409` - Email already exists

### **POST /v1/auth/login**

Authenticate with email/password.

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
  "expires_in": 3600,
  "token_type": "Bearer",
  "user": {
    "id": "507f1f77bcf86cd799439011",
    "email": "user@example.com",
    "name": "John Doe",
    "email_verified": true,
    "last_login": "2025-08-25T10:30:00Z",
    "preferences": {
      "lang": "am",
      "topics": ["economy", "agriculture", "politics"],
      "data_saver": true,
      "text_only": false,
      "notifications": {
        "daily_brief": { "am": true, "pm": false },
        "wifi_only": true,
        "sound_enabled": false
      },
      "audio_speed": 1.25,
      "cached_days": 7
    }
  }
}
```

**Error Responses:**

- `401` - Invalid credentials
- `423` - Account locked due to failed attempts

### **POST /v1/auth/refresh**

Refresh access token.

**Request Body:**

```json
{
  "refresh_token": "66c1234567890abcdef12349"
}
```

**Success Response (200):**

```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expires_in": 3600,
  "token_type": "Bearer",
  "refresh_token": "66c1234567890abcdef1234b",
  "token_rotated": true
}
```

**Error Responses:**

- `401` - Invalid or expired refresh token

### **POST /v1/auth/verify-email**

Verify email address using verification token from unified token system.

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
  "user_id": "507f1f77bcf86cd799439011",
  "email_verified": true
}
```

**Error Responses:**

- `400` - Invalid token format
- `401` - Invalid or expired verification token
- `409` - Email already verified

### **POST /v1/auth/forgot-password**

Request password reset token (unified token system).

**Request Body:**

```json
{
  "email": "user@example.com"
}
```

**Success Response (200):**

```json
{
  "message": "Password reset instructions sent",
  "reset_token_id": "66c1234567890abcdef1234c",
  "expires_in_minutes": 30
}
```

### **POST /v1/auth/reset-password**

Reset password using reset token from unified token system.

**Request Body:**

```json
{
  "token": "66c1234567890abcdef1234c",
  "new_password": "NewSecureP@ssw0rd123!"
}
```

**Success Response (200):**

```json
{
  "message": "Password reset successfully",
  "user_id": "507f1f77bcf86cd799439011",
  "all_sessions_invalidated": true
}
```

**Error Responses:**

- `400` - Invalid token format or weak password
- `401` - Invalid or expired reset token
- `429` - Too many reset attempts

---

## 👤 User Profile & Preferences

### **GET /v1/me** 🔐

Get authenticated user profile and preferences.

**Success Response (200):**

```json
{
  "id": "507f1f77bcf86cd799439011",
  "email": "user@example.com",
  "name": "John Doe",
  "email_verified": true,
  "preferred_lang": "am",
  "created_at": "2025-08-25T10:30:00Z",
  "last_login": "2025-08-25T10:30:00Z",
  "preferences": {
    "lang": "am",
    "topics": ["economy", "agriculture", "politics"],
    "subscribed_sources": [
      "addisstandard",
      "ethiopianherald",
      "capitalethiopia"
    ],
    "data_saver": true,
    "text_only": false,
    "brief_type": "short",
    "notifications": {
      "daily_brief": { "am": true, "pm": false },
      "wifi_only": true,
      "sound_enabled": false
    },
    "audio_speed": 1.25,
    "cached_days": 7
  },
  "subscription": {
    "plan": "premium",
    "expires_at": "2025-12-25T00:00:00Z",
    "features": ["unlimited_queries", "priority_support", "advanced_search"]
  },
  "stats": {
    "stories_read": 147,
    "briefs_accessed": 23,
    "chat_queries": 8,
    "last_sync": "2025-08-25T09:15:00Z"
  }
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
  "message": "Password updated successfully",
  "all_sessions_invalidated": true,
  "new_access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "new_refresh_token": "66c1234567890abcdef1234d"
}
```

**Error Responses:**

- `400` - Weak password or validation error
- `401` - Invalid current password
- `429` - Too many password change attempts

### **GET /v1/me/subscriptions** 🔐

Get user's news outlet subscriptions.

**Success Response (200):**

```json
{
  "subscriptions": [
    {
      "source_key": "addisstandard",
      "source_name": "Addis Standard",
      "subscribed_at": "2025-08-01T10:00:00Z",
      "topics": ["politics", "economy"],
      "notification_enabled": true,
      "last_article": "2025-08-25T09:30:00Z"
    },
    {
      "source_key": "ethiopianherald",
      "source_name": "Ethiopian Herald",
      "subscribed_at": "2025-08-10T15:30:00Z",
      "topics": ["all"],
      "notification_enabled": false,
      "last_article": "2025-08-25T08:45:00Z"
    }
  ],
  "total_subscriptions": 3,
  "subscription_limit": 10,
  "premium_features": true
}
```

### **POST /v1/me/subscriptions** 🔐

Subscribe to a news outlet with topic preferences.

**Request Body:**

```json
{
  "source_key": "capitalethiopia",
  "topics": ["economy", "business"],
  "notifications": true
}
```

**Success Response (201):**

```json
{
  "subscription": {
    "source_key": "capitalethiopia",
    "source_name": "Capital Ethiopia",
    "subscribed_at": "2025-08-25T10:30:00Z",
    "topics": ["economy", "business"],
    "notification_enabled": true
  },
  "total_subscriptions": 4
}
```

**Error Responses:**

- `400` - Invalid source key or topics
- `409` - Already subscribed to this source
- `402` - Subscription limit reached (upgrade required)

### **PATCH /v1/me/subscriptions/:source_key** 🔐

Update subscription preferences for a news outlet.

**Path Parameters:**
| Field | Type | Description |
|-------|------|-------------|
| `source_key` | `string` | News outlet identifier |

**Request Body:**

```json
{
  "topics": ["politics", "economy", "agriculture"],
  "notifications": false
}
```

**Success Response (200):**

```json
{
  "subscription": {
    "source_key": "addisstandard",
    "source_name": "Addis Standard",
    "subscribed_at": "2025-08-01T10:00:00Z",
    "topics": ["politics", "economy", "agriculture"],
    "notification_enabled": false,
    "updated_at": "2025-08-25T10:30:00Z"
  }
}
```

### **GET /v1/me/analytics** 🔐

Get user reading analytics and recommendations.

**Query Parameters:**
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `period` | `"week" \| "month" \| "year"` | No | Analytics timeframe |

**Success Response (200):**

```json
{
  "period": "month",
  "date_range": {
    "from": "2025-07-25T00:00:00Z",
    "to": "2025-08-25T00:00:00Z"
  },
  "reading_stats": {
    "articles_read": 89,
    "time_spent_minutes": 267,
    "daily_average": 8.9,
    "completion_rate": 0.76
  },
  "topic_breakdown": [
    { "topic": "economy", "articles": 34, "percentage": 38.2 },
    { "topic": "agriculture", "articles": 28, "percentage": 31.5 },
    { "topic": "politics", "articles": 27, "percentage": 30.3 }
  ],
  "source_breakdown": [
    { "source": "addisstandard", "articles": 45, "percentage": 50.6 },
    { "source": "ethiopianherald", "articles": 32, "percentage": 36.0 },
    { "source": "capitalethiopia", "articles": 12, "percentage": 13.4 }
  ],
  "recommendations": [
    {
      "type": "new_topic",
      "topic": "technology",
      "reason": "Growing interest in related articles",
      "confidence": 0.82
    },
    {
      "type": "new_source",
      "source": "theethiopianpost",
      "reason": "Covers your favorite topics extensively",
      "confidence": 0.75
    }
  ]
}
```

### **POST /v1/me/notifications/test** 🔐

Send test notification to verify notification settings.

**Request Body:**

```json
{
  "type": "daily_brief",
  "slot": "am"
}
```

**Success Response (200):**

```json
{
  "message": "Test notification sent successfully",
  "notification_id": "507f1f77bcf86cd799439018",
  "sent_at": "2025-08-25T10:30:00Z",
  "delivery_status": "delivered"
}
```

### **GET /v1/me/export** 🔐

Export user data (GDPR compliance).

**Query Parameters:**
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `format` | `"json" \| "csv"` | No | Export format |
| `include` | `string[]` | No | Data types to include |

**Success Response (200):**

```json
{
  "export_id": "exp_507f1f77bcf86cd799439019",
  "status": "processing",
  "estimated_completion": "2025-08-25T10:35:00Z",
  "download_url": null,
  "expires_at": "2025-08-26T10:30:00Z"
}
```

### **DELETE /v1/me** 🔐

Delete user account and all associated data.

**Request Body:**

```json
{
  "password": "UserP@ssw0rd123!",
  "confirmation": "DELETE_MY_ACCOUNT"
}
```

**Success Response (200):**

```json
{
  "message": "Account deletion initiated",
  "deletion_id": "del_507f1f77bcf86cd799439020",
  "data_retention_days": 30,
  "complete_deletion_date": "2025-09-24T10:30:00Z"
}
```

### **DELETE /v1/me/subscriptions/:source_key** 🔐

Unsubscribe from a news outlet.

**Path Parameters:**
| Field | Type | Description |
|-------|------|-------------|
| `source_key` | `string` | News outlet identifier |

**Success Response (200):**

```json
{
  "message": "Successfully unsubscribed from Addis Standard",
  "source_key": "addisstandard",
  "unsubscribed_at": "2025-08-25T10:30:00Z",
  "remaining_subscriptions": 2
}
```

### **PATCH /v1/me/topics** 🔐

Update user's interested topics (affects all subscriptions).

**Request Body:**

```json
{
  "topics": ["economy", "agriculture", "technology", "health"],
  "apply_to_existing_subscriptions": true
}
```

**Success Response (200):**

```json
{
  "topics": ["economy", "agriculture", "technology", "health"],
  "updated_subscriptions": [
    {
      "source_key": "addisstandard",
      "previous_topics": ["politics", "economy"],
      "new_topics": ["economy", "agriculture", "technology", "health"]
    }
  ],
  "updated_at": "2025-08-25T10:30:00Z"
}
```

````

### **PATCH /v1/me/preferences** 🔐

Update user preferences (partial update).

**Request Body:**

```json
{
  "lang": "en",
  "topics": ["economy", "health"],
  "data_saver": false,
  "notifications": {
    "daily_brief": { "am": true, "pm": true }
  }
}
````

**Success Response (200):**

```json
{
  "lang": "en",
  "topics": ["economy", "health"],
  "data_saver": false,
  "text_only": false,
  "notifications": {
    "daily_brief": { "am": true, "pm": true },
    "wifi_only": true,
    "sound_enabled": false
  },
  "audio_speed": 1.25,
  "cached_days": 7,
  "updated_at": "2025-08-25T10:30:00Z"
}
```

### **POST /v1/me/preferences/merge** 🔐

Merge guest preferences with user account at login.

**Request Body:**

```json
{
  "guest_preferences": {
    "lang": "am",
    "topics": ["agriculture", "culture"],
    "data_saver": true,
    "cached_days": 3
  },
  "strategy": "merge"
}
```

**Success Response (200):**

```json
{
  "merged_preferences": {
    "lang": "am",
    "topics": ["economy", "agriculture", "culture", "politics"],
    "data_saver": true,
    "text_only": false,
    "notifications": {
      "daily_brief": { "am": true, "pm": false },
      "wifi_only": true
    },
    "audio_speed": 1.25,
    "cached_days": 3
  },
  "merge_summary": {
    "added_topics": ["culture"],
    "updated_fields": ["lang", "data_saver", "cached_days"]
  }
}
```

---

## 🛠 Internal/Operator Endpoints

### **GET /internal/metrics**

Prometheus-format metrics.

**Response (200) - text/plain:**

```
# HELP newsbrief_http_requests_total Total HTTP requests
# TYPE newsbrief_http_requests_total counter
newsbrief_http_requests_total{method="GET",endpoint="/v1/feed",status="200"} 1234

# HELP newsbrief_stories_total Total stories processed
# TYPE newsbrief_stories_total counter
newsbrief_stories_total{source="addisstandard.com"} 456

# HELP newsbrief_gemini_tokens_used Total Gemini API tokens consumed
# TYPE newsbrief_gemini_tokens_used counter
newsbrief_gemini_tokens_used 45600

# HELP newsbrief_response_time_seconds HTTP response time
# TYPE newsbrief_response_time_seconds histogram
newsbrief_response_time_seconds_bucket{endpoint="/v1/feed",le="0.1"} 100
newsbrief_response_time_seconds_bucket{endpoint="/v1/feed",le="0.5"} 150
```

### **GET /internal/status**

Deep health check with dependencies.

**Success Response (200):**

```json
{
  "status": "healthy",
  "timestamp": "2025-08-25T10:30:00Z",
  "version": "1.0.0",
  "uptime_seconds": 86400,
  "services": {
    "mongodb": {
      "status": "up",
      "response_time_ms": 12,
      "replica_set": "rs0",
      "primary": "mongodb-1:27017",
      "connection_pool": { "active": 5, "max": 20 },
      "collections_status": {
        "users": "healthy",
        "tokens": "healthy",
        "stories": "healthy",
        "daily_briefs": "healthy"
      },
      "index_health": "all_optimal"
    },
    "scraper": {
      "status": "up",
      "response_time_ms": 45,
      "last_check": "2025-08-25T10:29:30Z"
    },
    "summarizer": {
      "status": "up",
      "gemini_available": true,
      "response_time_ms": 234,
      "daily_token_usage": 15420
    }
  },
  "background_jobs": {
    "feed_ingestion": {
      "last_run": "2025-08-25T10:15:00Z",
      "status": "completed",
      "articles_processed": 23,
      "mongodb_batch_inserts": 23
    },
    "daily_brief_generation": {
      "last_run": "2025-08-25T06:00:00Z",
      "status": "completed",
      "briefs_generated": 2,
      "aggregation_pipeline_time_ms": 1250
    },
    "token_cleanup": {
      "last_run": "2025-08-25T02:00:00Z",
      "status": "completed",
      "expired_tokens_removed": 47
    }
  },
  "mongodb_metrics": {
    "documents_total": 156823,
    "data_size_mb": 234.5,
    "index_size_mb": 45.2,
    "ops_per_second": 127
  }
}
```

---

## 🤖 Microservice Endpoints

### **Scraper Service (FastAPI)**

#### **POST /scrape**

Extract article content from URL with vector storage.

**Request Body:**

```json
{
  "url": "https://addisstandard.com/news/ethiopia-agri-2025",
  "timeout_seconds": 30,
  "store_in_vector_db": true,
  "content_category": "news_article"
}
```

**Success Response (200):**

```json
{
  "url": "https://addisstandard.com/news/ethiopia-agri-2025",
  "title": "Ethiopia launches new agricultural initiative",
  "text": "The Ethiopian government today announced a $50M investment program targeting rural farmers...",
  "lang": "en",
  "source": "addisstandard.com",
  "scraped_at": "2025-08-25T10:30:00Z",
  "word_count": 450,
  "reading_time_minutes": 3,
  "content_hash": "sha256:a1b2c3d4e5f6...",
  "vector_stored": true,
  "vector_id": "vec_507f1f77bcf86cd799439016"
}
```

### **Summarizer Service (Go)**

#### **POST /summarize**

Generate short and medium length summaries from article text.

**Request Body:**

```json
{
  "text": "The Ethiopian government today announced a $50M investment program...",
  "title": "Ethiopia launches new agricultural initiative",
  "source": "addisstandard.com",
  "target_lang": "am",
  "summary_types": ["short", "medium"],
  "max_bullets": 5
}
```

**Success Response (200):**

```json
{
  "summary_short": "Government announces $50M investment in rural farming targeting 100,000 farmers.",
  "summary_bullets": [
    "መንግስት ለገጠር ገበሬዎች 50 ሚልዮን ዶላር ኢንቨስትመንት ፕሮግራም አስታውቋል",
    "ፕሮግራሙ በአገሪቱ ውስጥ 100,000 አነስተኛ ገበሬዎችን ያነጣጠረ ነው",
    "ብርቱ ሰብል ዝርያዎች እና መስኖ ላይ ያተኮረ ነው",
    "ትምህርት ፕሮግራሞች እና የመሳሪያ ድጎማዎችን ያካትታል",
    "የግብርና ምርታማነት በ35% እንደሚጨምር ይጠበቃል"
  ],
  "summary_lang": "am",
  "confidence_score": 0.95,
  "tokens_used": 450,
  "processing_time_ms": 1230,
  "reading_time": {
    "short": 1,
    "medium": 3
  }
}
```

### **Vector Database Service (Python/FastAPI)**

#### **POST /store**

Store content embeddings for semantic search.

**Request Body:**

```json
{
  "content_id": "507f1f77bcf86cd799439012",
  "text": "The Ethiopian government today announced a $50M investment program...",
  "title": "Ethiopia launches new agricultural initiative",
  "metadata": {
    "source": "addisstandard.com",
    "topic": "agriculture",
    "lang": "en",
    "scraped_at": "2025-08-25T10:30:00Z"
  }
}
```

**Success Response (200):**

```json
{
  "vector_id": "vec_507f1f77bcf86cd799439016",
  "content_id": "507f1f77bcf86cd799439012",
  "embedding_dimension": 1536,
  "stored_at": "2025-08-25T10:31:00Z",
  "similarity_ready": true
}
```

#### **POST /search**

Semantic search across stored content embeddings.

**Request Body:**

```json
{
  "query": "renewable energy projects in Ethiopia",
  "limit": 5,
  "similarity_threshold": 0.7,
  "filters": {
    "topic": "energy",
    "lang": "en",
    "date_range": {
      "from": "2025-08-01T00:00:00Z",
      "to": "2025-08-25T23:59:59Z"
    }
  }
}
```

**Success Response (200):**

```json
{
  "matches": [
    {
      "content_id": "507f1f77bcf86cd799439017",
      "vector_id": "vec_507f1f77bcf86cd799439017",
      "similarity_score": 0.94,
      "title": "Ethiopia's Solar Power Initiative",
      "text_snippet": "The government announced plans to build a 300MW solar facility...",
      "metadata": {
        "source": "ethiopianherald.com",
        "topic": "energy",
        "scraped_at": "2025-08-24T14:20:00Z"
      }
    }
  ],
  "total_matches": 12,
  "query_time_ms": 45,
  "used_cache": false
}
```

### **Search Service (Go)**

#### **POST /web-search**

Perform web search and return relevant URLs for scraping.

**Request Body:**

```json
{
  "query": "Ethiopia renewable energy projects 2025",
  "max_results": 10,
  "domains": [
    "ethiopianherald.com",
    "addisstandard.com",
    "capitalethiopia.com"
  ],
  "date_filter": "past_week"
}
```

**Success Response (200):**

```json
{
  "results": [
    {
      "url": "https://ethiopianherald.com/renewable-energy-2025",
      "title": "Ethiopia's Renewable Energy Expansion Plans",
      "snippet": "The government has announced ambitious renewable energy targets...",
      "source": "ethiopianherald.com",
      "published_date": "2025-08-24T00:00:00Z",
      "relevance_score": 0.95
    }
  ],
  "total_results": 8,
  "search_time_ms": 234,
  "search_engine": "google",
  "query_processed": "Ethiopia renewable energy projects 2025"
}
```

---

This specification represents **FAANG-level professional standards** with:

- ✅ Complete HTTP status code coverage
- ✅ Consistent error handling
- ✅ Comprehensive security model
- ✅ Rate limiting strategy
- ✅ Detailed data validation
- ✅ Production observability
- ✅ Offline-first considerations
- ✅ Microservice architecture clarity

**Implementation Priority:** Start with core endpoints (auth, feed, story) then add advanced features incrementally.
