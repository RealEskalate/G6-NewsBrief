"use client";
// API service layer for backend integration
const API_BASE_URL = "https://news-brief-core-api.onrender.com/api/v1";

// Types matching backend interfaces
export interface News {
  id: string;
  title: string;
  description: string;
  topics: string[];
  source: string;
  posted_at: string;
  image_url: string;
}

export interface TodayNews {
  id: string;
  title: string;
  body: string;
  title_en: string;
  title_am: string;
  body_en: string;
  body_am: string;
  summary_en: string;
  summary_am: string;
  language: string;
  source_id: string;
  topics: string[];
  published_at: string;
  published_date_localized: string;
  created_at: string;
  updated_at: string;
  is_bookmarked?: boolean; // Made optional since it's not always in the response
}

export interface TrendingNews {
  id: string;
  title: string;
  body: string;
  title_en: string;
  title_am: string;
  body_en: string;
  body_am: string;
  summary_en: string;
  summary_am: string;
  language: string;
  source_id: string;
  topics: string[];
  published_at: string;
  published_date_localized: string;
  created_at: string;
  updated_at: string;
  is_bookmarked: boolean;
}

export interface TrendingNewsResponse {
  news: TrendingNews[];
  total: number;
  total_pages: number;
  page: number;
  limit: number;
}
export interface Source {
  id:string;
  slug: string;
  name: string;
  description: string;
  url: string;
  logo_url: string;
  languages: string;
  topics: string[];
  reliability_score: number;
}

// API response structure for subscriptions
export interface SubscriptionResponse {
  source_slug: string;
  source_name: string;
  subscribed_at: string;
  topics: string[];
}

export interface SubscriptionsApiResponse {
  subscriptions: SubscriptionResponse[];
  total_subscriptions: number;
  subscription_limit: number;
}

export interface SourcesApiResponse {
  sources: Source[];
  total_sources: number;
}
export interface Topic {
  id: string;
  slug: string;
  label: {
    en: string;
    am: string;
  };
  story_count: number;
}

interface TopicsResponse {
  topics: Topic[];
  total_topics: number;
}
export interface User {
  id: string;
  fullname: string;
  email: string;
  role?: "admin" | "user";
  subscribed: string[]; // news sources / publishers user follows
  topic_interest: string[]; // topics user is interested in
  saved_news: string[]; // IDs of saved news articles
}

export interface Category {
  id: number;
  name: string;
}
class ApiClient {
  private baseURL: string;
  private topicsCache: Topic[] = [];

  constructor(baseURL: string) {
    this.baseURL = baseURL;
  }

  private async request<T>(
    endpoint: string,
    options: RequestInit = {}
  ): Promise<T> {
    const url = `${this.baseURL}${endpoint}`;

    const token = typeof window !== "undefined" ? getAccessToken() : null;
    console.log("Making request to:", url);
    console.log("Token available:", !!token);

    const config: RequestInit = {
      ...options,
      headers: {
        "Content-Type": "application/json",
        ...(token && { Authorization: `Bearer ${token}` }),
        ...(options.headers || {}),
      },
    };

    const response = await fetch(url, config);

    if (!response.ok) {
      let errorData = {};
      try {
        errorData = await response.json();
        console.error("API Error Response:", errorData);
      } catch (e) {
        console.error("Error parsing error response:", e);
      }
      throw new Error(
        `HTTP error! status: ${response.status} - ${JSON.stringify(errorData)}`
      );
    }

    const contentType = response.headers.get("content-type");
    if (contentType && contentType.includes("application/json")) {
      try {
        return await response.json();
      } catch (e) {
        console.error("Error parsing successful JSON response:", e);
        throw new Error("Failed to parse JSON response.");
      }
    } else {
      return {} as T;
    }
  }
  // authenticated profile
  async getProfile(): Promise<User> {
    return this.request<User>("/me", { method: "GET" });
  }

  async getSources(): Promise<Source[]> {
    const res = await this.request<SourcesApiResponse>("/sources", {
      method: "GET",
    });
    console.log("getting source", res);
    return res.sources;
  }
  
  async getSubscriptions(): Promise<Source[]> {
    const res = await this.request<SubscriptionsApiResponse>(
      "/me/subscriptions",
      { method: "GET" }
    );
    console.log("getting subscription", res);

    // Transform API response to match Source interface
    // We need to get full source details from the sources endpoint
    const allSources = await this.getSources();

    return res.subscriptions.map((sub) => {
      const sourceDetails = allSources.find((s) => s.slug === sub.source_slug);
      return {
        id: sourceDetails?.id || "",
        slug: sub.source_slug,
        name: sub.source_name,
        description: sourceDetails?.description || "",
        url: sourceDetails?.url || "",
        logo_url: sourceDetails?.logo_url || "",
        languages: sourceDetails?.languages || "",
        topics: sub.topics,
        reliability_score: sourceDetails?.reliability_score || 0,
      };
    });
  }

  async getTopics(): Promise<Topic[]> {
    try {
      const res = await this.request<TopicsResponse>("/topics", {
        method: "GET",
      });
      console.log("getting general topics", res);

      if (res && res.topics) {
        return res.topics;
      }

      return [];
    } catch (error) {
      console.error("Error fetching topics:", error);
      // Return empty array if API call fails
      return [];
    }
  }
  async addSubscription(sourceSlug: string): Promise<void> {
    await this.request(`/me/subscriptions`, {
      method: "POST",
      body: JSON.stringify({ source_key: sourceSlug }),
    });
  }

  async removeSubscription(sourceSlug: string): Promise<void> {
    await this.request(`/me/subscriptions/${sourceSlug}`, {
      method: "DELETE",
    });
  }

  async addTopic(topicSlug: string): Promise<void> {
    await this.request(`/me/topics`, {
      method: "POST",
      body: JSON.stringify({ topic_key: topicSlug }),
    });
  }

  async removeTopic(topicSlug: string): Promise<void> {
    await this.request(`/me/topics/${topicSlug}`, {
      method: "DELETE",
    });
  }

  async updateProfile(data: { fullname?: string }): Promise<User> {
    return this.request<User>("/me", {
      headers: {
        Authorization: `Bearer ${getAccessToken()}`,
      },
      method: "PUT",
      body: JSON.stringify(data),
    });
  }
  //  get user
  async getUser(): Promise<User> {
    return {
      id: "u123",
      fullname: "John Doe",
      email: "john@example.com",
      role: "user", // add this
      subscribed: ["TechCrunch", "BBC", "Reuters"], // sources user follows
      topic_interest: ["AI", "Tech", "Science"], // topics user cares about
      saved_news: ["1", "3", "2", "5"],
    };
  }

  async signUp(fullname: string, email: string, password: string) {
    const options = {
      method: "POST",
      body: JSON.stringify({ fullname, email, password }),
    };
    const res = await fetch(`${this.baseURL}/auth/register`, options);
    const status_code = res.status;
    if (status_code === 409) {
      const error = new Error("User already Exists") as Error & {
        statusCode?: number;
      };
      error.statusCode = 409;
      throw error;
    }

    const data = await res.json();
    if (status_code == 201) {
      const methods = {
        method: "POST",
        body: JSON.stringify({ email, password }),
      };
      const logged_res = await fetch(`${this.baseURL}/auth/login`, methods);

      const logged_val = await logged_res.json();
      localStorage.setItem("person", JSON.stringify(logged_val));
      console.log(logged_val);
    }
    return {
      message: data.message,
      status_code,
    };
  }

  // Save user topics to backend
  async saveUserTopics(topicIds: string[]): Promise<void> {
    console.log("Saving topics to backend:", topicIds);
    console.log("Request body will be:", JSON.stringify({ topics: topicIds }));
    console.log("Access token:", getAccessToken() ? "Present" : "Missing");
    
    try {
      // Try PUT method first as it's more appropriate for updating user preferences
      await this.request(`/me/topics`, {
        method: "PUT",
        headers: {
          Authorization: `Bearer ${getAccessToken()}`,
        },
        body: JSON.stringify({ topics: topicIds }),
      });
      console.log("Topics saved successfully");
    } catch (error) {
      console.error("Error saving topics with PUT, trying POST:", error);
      try {
        // Fallback to POST method
        await this.request(`/me/topics`, {
          method: "POST",
          headers: {
            Authorization: `Bearer ${getAccessToken()}`,
          },
          body: JSON.stringify({ topics: topicIds }),
        });
        console.log("Topics saved successfully with POST");
      } catch (postError) {
        console.error("Error saving topics with POST:", postError);
        throw postError;
      }
    }
  }

  // Get today's news
  async getTodaysNews(): Promise<TodayNews[]> {
    try {
      const res = await this.request<{ news: TodayNews[] }>("/news/today", {
        method: "GET",
      });
      console.log("Getting today's news:", res);
      return res.news || [];
    } catch (error) {
      console.error("Error fetching today's news:", error);
      return [];
    }
  }

  // Get trending news with pagination
  async getTrendingNews(page: number = 1, limit: number = 10): Promise<TrendingNewsResponse> {
    try {
      const res = await this.request<TrendingNewsResponse>(`/news/trending?page=${page}&limit=${limit}`, {
        method: "GET",
      });
      console.log("Getting trending news:", res);
      return res;
    } catch (error) {
      console.error("Error fetching trending news:", error);
      return {
        news: [],
        total: 0,
        total_pages: 0,
        page: 1,
        limit: 10
      };
    }
  }

  // Get news for a specific topic
  async getTopicNews(topicId: string, page: number = 1, limit: number = 10): Promise<TrendingNewsResponse> {
    try {
      const res = await this.request<TrendingNewsResponse>(`/topics/${topicId}/news?page=${page}&limit=${limit}`, {
        method: "GET",
        headers: {
          Authorization: `Bearer ${getAccessToken()}`,
        },
      });
      console.log(`Getting news for topic ${topicId}:`, res);
      return res;
    } catch (error) {
      console.error(`Error fetching news for topic ${topicId}:`, error);
      return {
        news: [],
        total: 0,
        total_pages: 0,
        page: 1,
        limit: 10
      };
    }
  }

  // Bookmark API methods
  async saveBookmark(newsId: string): Promise<{ message: string }> {
    try {
      const res = await this.request<{ message: string }>("/me/bookmarks", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${getAccessToken()}`,
        },
        body: JSON.stringify({ news_id: newsId }),
      });
      console.log(`Bookmark saved for news ${newsId}:`, res);
      return res;
    } catch (error) {
      console.error(`Error saving bookmark for news ${newsId}:`, error);
      throw error;
    }
  }

  async removeBookmark(newsId: string): Promise<{ message: string }> {
    try {
      const res = await this.request<{ message: string }>(`/me/bookmarks/${newsId}`, {
        method: "DELETE",
        headers: {
          Authorization: `Bearer ${getAccessToken()}`,
        },
      });
      console.log(`Bookmark removed for news ${newsId}:`, res);
      return res;
    } catch (error) {
      console.error(`Error removing bookmark for news ${newsId}:`, error);
      throw error;
    }
  }

  async getBookmarks(): Promise<{ news: TrendingNews[], total: number, total_pages: number, page: number, limit: number }> {
    try {
      const res = await this.request<{ news: TrendingNews[], total: number, total_pages: number, page: number, limit: number }>("/me/bookmarks", {
        method: "GET",
        headers: {
          Authorization: `Bearer ${getAccessToken()}`,
        },
      });
      console.log("Fetched user bookmarks:", res);
      return res;
    } catch (error) {
      console.error("Error fetching bookmarks:", error);
      return { news: [], total: 0, total_pages: 0, page: 0, limit: 0 };
    }
  }

  // Get personalized feed (For You)
  async getForYouFeed(page: number = 1, limit: number = 10): Promise<TrendingNewsResponse> {
    try {
      const res = await this.request<TrendingNewsResponse>(`/me/for-you?page=${page}&limit=${limit}`, {
        method: "GET",
        headers: {
          Authorization: `Bearer ${getAccessToken()}`,
        },
      });
      console.log("Getting for you feed:", res);
      return res;
    } catch (error) {
      console.error("Error fetching for you feed:", error);
      return {
        news: [],
        total: 0,
        total_pages: 0,
        page: 1,
        limit: 10
      };
    }
  }

  // Get subscribed topics
  async getSubscribedTopics(): Promise<{ slug: string; topic_name: string; label: { en: string; am: string }; story_count: number }[]> {
    try {
      const res = await this.request<{ slug: string; topic_name: string; label: { en: string; am: string }; story_count: number }[]>("/me/subscribed-topics", {
        method: "GET",
        headers: {
          Authorization: `Bearer ${getAccessToken()}`,
        },
      });
      console.log("Getting subscribed topics:", res);
      return res;
    } catch (error) {
      console.error("Error fetching subscribed topics:", error);
      return [];
    }
  }

  // Subscribe to a topic
  async subscribeToTopic(topicId: string): Promise<{ message: string }> {
    try {
      const res = await this.request<{ message: string }>(`/me/topics/${topicId}`, {
        method: "POST",
        headers: {
          Authorization: `Bearer ${getAccessToken()}`,
        },
      });
      console.log("Subscribed to topic:", res);
      return res;
    } catch (error) {
      console.error(`Error subscribing to topic ${topicId}:`, error);
      throw error;
    }
  }

  // Unsubscribe from a topic
  async unsubscribeFromTopic(topicId: string): Promise<{ message: string }> {
    try {
      const res = await this.request<{ message: string }>(`/me/topics/${topicId}`, {
        method: "DELETE",
        headers: {
          Authorization: `Bearer ${getAccessToken()}`,
        },
      });
      console.log("Unsubscribed from topic:", res);
      return res;
    } catch (error) {
      console.error(`Error unsubscribing from topic ${topicId}:`, error);
      throw error;
    }
  }

  async signIn(email: string, password: string) {
    const methods = {
      method: "POST",
      body: JSON.stringify({ email, password }),
    };
    const logged_res = await fetch(`${this.baseURL}/auth/login`, methods);
    const logged_val = await logged_res.json();
    const status_code = logged_res.status;
    if (status_code != 200) {
      const error = new Error("Invalid Credential") as Error & {
        statusCode?: number;
      };
      error.statusCode = 401;
      throw error;
    }
    this.loadTopics();

    localStorage.setItem("person", JSON.stringify(logged_val));
    // localStorage.setItem("topics", JSON.stringify(this.topicsCache))
    console.log(logged_val);
  }
  async getSubscribedNews(): Promise<News[]> {
    try {
      // First get the user's subscriptions
      const subscriptions = await this.getSubscriptions();

      // If no subscriptions, return empty array
      if (!subscriptions || subscriptions.length === 0) {
        return [];
      }

      // Get all news
      const allNews = await this.getDummyNews();

      // Filter news to only include items from subscribed sources
      const subscribedSources = subscriptions.map((sub) => sub.slug);
      const subscribedNews = allNews.filter((news) =>
        subscribedSources.includes(news.source.toLowerCase())
      );

      return subscribedNews;
    } catch (error) {
      console.error("Error fetching subscribed news:", error);
      throw new Error("Failed to fetch news from your subscriptions");
    }
  }

  async forgotPassword(email: string) {
    return this.request<{ message: string }>("/auth/forgot-password", {
      method: "POST",
      body: JSON.stringify({ email }),
    });
  }

  // Reset Password - use token + verifier + new password
  async resetPassword(verifier: string, token: string, password: string) {
    return this.request<{ message: string }>("/auth/reset-password", {
      method: "POST",
      body: JSON.stringify({ verifier, token, password }),
    });
  }
  signInWithGoogle() {
    // Redirect user to backend Google login route
    window.location.href = `${this.baseURL}/auth/google/login`;
  }
  async loadTopics() {
    try {
      const res = await fetch(`${this.baseURL}/topics`, {
        method: "GET",
        headers: {
          Accept: "application/json",
        },
      });

      const status_code = res.status;

      if (!res.ok) {
        throw new Error(`Failed to fetch topics, status: ${status_code}`);
      }

      const data: TopicsResponse = await res.json();

      this.topicsCache = data.topics;
      localStorage.setItem("all_topics", JSON.stringify(this.topicsCache));
      return {
        message: "Topics loaded successfully",
        status_code,
      };
    } catch (err) {
      console.error("Error loading topics:", err);
      throw err;
    }
  }

  // Get topic name by slug from local cache
  getTopicNameBySlug(slug: string): string | undefined {
    const topic = this.topicsCache.find((t) => t.slug === slug);
    return topic ? topic.label.en : undefined;
  }

  // Get topic name by id from local cache
  getTopicNameById(id: string): string | undefined {
    const topic = this.topicsCache.find((t) => t.id === id);
    return topic ? topic.label.en : undefined;
  }
  async getArtsNews(): Promise<News[]> {
    const news = await this.getDummyNews();

    // simulate 2s delay
    await new Promise((resolve) => setTimeout(resolve, 2000));

    return news.filter((n) => n.topics.includes("Arts"));
  }

  async getBusinessNews(): Promise<News[]> {
    const news = await this.getDummyNews();

    // simulate 2s delay
    await new Promise((resolve) => setTimeout(resolve, 2000));

    return news.filter((n) => n.topics.includes("Business"));
  }

  async getTopNews(): Promise<News[]> {
    return new Promise((resolve) => {
      setTimeout(() => {
        resolve([
          {
            id: "1",
            title: "Indonesia football crush: How the disaster unfolded",
            description:
              "Indonesia’s worst sports disaster left scores dead after chaos erupted at a football match.",
            topics: ["Arts"],
            source: "BBC",
            posted_at: "8 October 2022",
            image_url: "https://picsum.photos/seed/football/600/400",
          },
          {
            id: "2",
            title:
              "Philippines lottery: Questions raised as hundreds win jackpot",
            description:
              "A lottery in the Philippines with 433 jackpot winners has sparked widespread suspicion.",
            topics: ["Business"],
            source: "Reuters",
            posted_at: "8 October 2022",
            image_url: "https://picsum.photos/seed/lottery/600/400",
          },
          {
            id: "3",
            title:
              "Biden tells Al Sharpton he will run for president again in 2024",
            description:
              "President Biden has privately confirmed his intention to run for reelection.",
            topics: ["Arts"],
            source: "AP News",
            posted_at: "8 October 2022",
            image_url: "https://picsum.photos/seed/biden/600/400",
          },
          {
            id: "4",
            title:
              "Covid hospitalization hot spots across the U.S., in five charts",
            description:
              "Covid-19 hospitalizations are climbing again, with sharp increases in several states.",
            topics: ["HArts"],
            source: "NY Times",
            posted_at: "8 October 2022",
            image_url: "https://picsum.photos/seed/covid/600/400",
          },
        ]);
      }, 100);
    });
  }
  async createTopic(
    slug: string,
    en: string,
    am: string
  ): Promise<{ message: string }> {
    return this.request<{ message: string }>("/admin/create-topics", {
      headers: {
        Authorization: `Bearer ${getAccessToken()}`,
      },
      method: "POST",
      body: JSON.stringify({
        slug,
        label: {
          en,
          am,
        },
      }),
    });
  }

  async createSource(data: {
    slug: string;
    name: string;
    description: string;
    url: string;
    logo_url: string;
    languages: string;
    topics: string[];
    reliability_score: number;
  }): Promise<{ message: string }> {
    return this.request<{ message: string }>("/admin/create-sources", {
      headers: {
        Authorization: `Bearer ${getAccessToken()}`,
      },
      method: "POST",
      body: JSON.stringify(data),
    });
  }
  async createNews(data: {
  title: string;
  language: string;  
  source_id: string;    
  body: string;
  topics: string[];  
}): Promise<{ message: string }> {
  return this.request<{ message: string }>("/admin/news", {
    headers: {
      Authorization: `Bearer ${getAccessToken()}`,
    },
    method: "POST",
    body: JSON.stringify({
      title: data.title,
      language: data.language.toLowerCase(), // must be "en" or "am"
      source_id: data.source_id,               // backend expects `source_id`
      body: data.body,
      topics_id: data.topics,
       
    }),
  });
}
async getAnalytics(): Promise<{
  total_users: number;
  total_news: number;
  total_sources: number;
  total_topics: number;
}> {
  return this.request<{
    total_users: number;
    total_news: number;
    total_sources: number;
    total_topics: number;
  }>("/admin/analytics", {
    headers: {
      Authorization: `Bearer ${getAccessToken()}`,
    },
    method: "GET",
  });
}

async fetchLatestData(): Promise<{ ingested: number; ids: string[]; skipped: number }> {
  return this.request<{ ingested: number; ids: string[]; skipped: number }>(
    "/admin/ingest/scraper",
    {
      headers: {
        Authorization: `Bearer ${getAccessToken()}`,
      },
      method: "POST",
      body: JSON.stringify({ query: "", top_k: 5 }),
    }
  );
}

  async getDummyNews(): Promise<News[]> {
    return new Promise((resolve) => {
      setTimeout(() => {
        resolve([
          // === Trending ===
          {
            id: "5",
            title: "Fall back into fitness with this 31-day walking plan",
            description:
              "A change of seasons is the perfect time to start fresh — a simple 30-minute daily walk can improve your health.",
            topics: ["Arts"],
            source: "Healthline",
            posted_at: "8 October 2022",
            image_url: "https://picsum.photos/seed/fitness/600/400",
          },
          {
            id: "6",
            title: "Apple will manufacture iPhone 14 in India",
            description:
              "Apple will make its iPhone 14 in India, expanding production outside China.",
            topics: ["Arts"],
            source: "TechCrunch",
            posted_at: "8 October 2022",
            image_url: "https://picsum.photos/seed/iphone/600/400",
          },
          {
            id: "7",
            title: "Virgin Atlantic adopts gender-neutral uniform policy",
            description:
              "Virgin Atlantic will allow cabin crew to choose which uniform to wear, regardless of gender.",
            topics: ["Business"],
            source: "CNN",
            posted_at: "8 October 2022",
            image_url: "https://picsum.photos/seed/virgin/600/400",
          },
          {
            id: "8",
            title: "Next year’s Met Gala theme revealed",
            description:
              "Organizers announced the 2023 Met Gala theme: celebrating the works of Karl Lagerfeld.",
            topics: ["Arts", "Business"],
            source: "Vogue",
            posted_at: "8 October 2022",
            image_url: "https://picsum.photos/seed/metgala/600/400",
          },

          // === Arts ===
          {
            id: "9",
            title:
              "Vermeer at the National Gallery in Washington, DC declared a fake",
            description:
              "Art experts discovered that a painting long attributed to Vermeer is not authentic.",
            topics: ["Arts"],
            source: "Guardian",
            posted_at: "8 October 2022",
            image_url: "https://picsum.photos/seed/vermeer/600/400",
          },
          {
            id: "10",
            title: "10 most famous paintings in the world",
            description:
              "From Mona Lisa to The Starry Night — discover the world’s most iconic masterpieces.",
            topics: ["Arts"],
            source: "History Today",
            posted_at: "8 October 2022",
            image_url: "https://picsum.photos/seed/paintings/600/400",
          },
          {
            id: "11",
            title: "Jurassic dinosaur fossil will go up for auction in Paris",
            description:
              "A rare Jurassic fossil is expected to fetch millions at an upcoming Paris auction.",
            topics: ["Science", "Arts"],
            source: "Smithsonian",
            posted_at: "8 October 2022",
            image_url: "https://picsum.photos/seed/dinosaur/600/400",
          },

          // === Business ===
          {
            id: "12",
            title: "Elon Musk: Twitter won’t ‘take yes for an answer’",
            description:
              "Elon Musk continues to clash with Twitter ahead of the acquisition deal deadline.",
            topics: ["Business", "Arts"],
            source: "WSJ",
            posted_at: "8 October 2022",
            image_url: "https://picsum.photos/seed/musk/600/400",
          },
          {
            id: "13",
            title: "Samsung warns of 32% hit to profits on chip slump",
            description:
              "Global chip demand slowdown impacts Samsung’s earnings outlook.",
            topics: ["Business", "Technology"],
            source: "Bloomberg",
            posted_at: "8 October 2022",
            image_url: "https://picsum.photos/seed/samsung/600/400",
          },
          {
            id: "14",
            title:
              "UK declines climate warnings with new oil and gas licences approval",
            description:
              "The UK government approved new oil drilling licences despite climate concerns.",
            topics: ["Business", "Politics"],
            source: "Financial Times",
            posted_at: "8 October 2022",
            image_url: "https://picsum.photos/seed/oil/600/400",
          },

          // === Redundant / Repeated to simulate feed ===
          {
            id: "15",
            title:
              "Philippines lottery: Questions raised as hundreds win jackpot",
            description:
              "A lottery in the Philippines with 433 jackpot winners has sparked widespread suspicion.",
            topics: ["Business"],
            source: "Reuters",
            posted_at: "8 October 2022",
            image_url: "https://picsum.photos/seed/lottery/600/400",
          },
          {
            id: "16",
            title:
              "Philippines lottery: Questions raised as hundreds win jackpot",
            description:
              "A lottery in the Philippines with 433 jackpot winners has sparked widespread suspicion.",
            topics: ["Business"],
            source: "Reuters",
            posted_at: "8 October 2022",
            image_url: "https://picsum.photos/seed/lottery2/600/400",
          },
          {
            id: "17",
            title:
              "Philippines lottery: Questions raised as hundreds win jackpot",
            description:
              "A lottery in the Philippines with 433 jackpot winners has sparked widespread suspicion.",
            topics: ["Business"],
            source: "Reuters",
            posted_at: "8 October 2022",
            image_url: "https://picsum.photos/seed/lottery3/600/400",
          },
        ]);
      }, 100);
    });
  }

  async getTopic(): Promise<Category[]> {
    return new Promise((resolve) => {
      setTimeout(() => {
        resolve([
          { id: 1, name: "Agriculture" },
          { id: 2, name: "Technology" },
          { id: 3, name: "Health" },
          { id: 4, name: "Education" },
          { id: 5, name: "Sports" },
          { id: 6, name: "Entertainment" },
          { id: 7, name: "Business" },
          { id: 8, name: "Politics" },
          { id: 9, name: "Science" },
          { id: 10, name: "Travel" },
        ]);
      }, 500);
    });
  }

  async getTopicFeed(): Promise<News[]> {
    const [user, news] = await Promise.all([
      this.getUser(),
      this.getDummyNews(),
    ]);
    return news.filter((n) =>
      n.topics.some((topic) => user.topic_interest.includes(topic))
    );
  }

  async getSubscribedFeed(): Promise<News[]> {
    const [user, news] = await Promise.all([
      this.getUser(),
      this.getDummyNews(),
    ]);
    return news.filter((n) => user.subscribed.includes(n.source));
  }

  async getSavedNews(): Promise<News[]> {
    const [user, news] = await Promise.all([
      this.getUser(),
      this.getDummyNews(),
    ]);
    return news.filter((n) => user.saved_news.includes(n.id));
  }

  async deleteAllSavedNews(): Promise<void> {
    const user = await this.getUser();
    user.saved_news = [];
    return;
  }

  async saveNewsItem(newsId: string): Promise<void> {
    const user = await this.getUser();
    if (!user.saved_news.includes(newsId)) {
      user.saved_news.push(newsId);
    }
  }

  async removeSavedNewsItem(newsId: string): Promise<void> {
    const user = await this.getUser();
    user.saved_news = user.saved_news.filter((id) => id !== newsId);
  }

  // Verify email with token + verifier
  async verifyEmail(verifier: string, token: string) {
    const res = await fetch(
      `${this.baseURL}/auth/verify-email?verifier=${verifier}&token=${token}`,
      {
        method: "GET",
      }
    );

    if (!res.ok) {
      const errorData = await res.json().catch(() => ({}));
      throw new Error(errorData.message || "Verification failed ❌");
    }

    return await res.json();
  }
}

// Export singleton instance
export const apiClient = new ApiClient(API_BASE_URL);
export function getAccessToken(): string | null {
  if (typeof window !== "undefined") {
    const data = localStorage.getItem("person");
    if (data) {
      try {
        const parsed = JSON.parse(data);
        return parsed?.access_token ?? null;
      } catch {
        return null;
      }
    }
  }
  return null;
}
export function getUserRole(): "admin" | "user" | null {
  if (typeof window !== "undefined") {
    const data = localStorage.getItem("person");
    if (data) {
      try {
        const parsed = JSON.parse(data);
        return parsed?.user?.role ?? null;
      } catch {
        return null;
      }
    }
  }
  return null;
}
