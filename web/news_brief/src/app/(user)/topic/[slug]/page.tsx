"use client";
import React, { useEffect, useState, useContext } from "react";
import { apiClient, Topic, TrendingNews, getAccessToken } from "@/lib/api";
import TopBar from "@/components/reusable_components/search_topbar";
import ChatBot from "@/components/reusable_components/Generalchatbot";
import { ThemeContext } from "@/app/contexts/ThemeContext";
import { useTranslation } from "react-i18next";
import { useParams, useRouter } from "next/navigation";
import { NewsGridNew } from "@/components/news_component/NewsComponent";

export default function TopicNewsPage() {
  const params = useParams();
  const topicSlug = params.slug as string;
  const router = useRouter();
  
  const context = useContext(ThemeContext);
  if (!context) throw new Error("TopicNewsPage must be used inside ThemeProvider");
  const { theme } = context;
  const { i18n } = useTranslation();

  const [topic, setTopic] = useState<Topic | null>(null);
  const [topicNews, setTopicNews] = useState<TrendingNews[] | null>(null);
  const [topics, setTopics] = useState<Topic[]>([]);
  const [loading, setLoading] = useState(true);
  const [topicLoading, setTopicLoading] = useState(false);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);
  const [bookmarkedNews, setBookmarkedNews] = useState<Set<string>>(new Set());

  useEffect(() => {
    const fetchTopicNews = async () => {
      if (!topicSlug) return;
      
      try {
        setLoading(true);
        setTopicLoading(true);
        setErrorMessage(null);
        
        // Get all topics first
        const topicsData = await apiClient.getTopics();
        setTopics(topicsData);
        
        // Find the topic by slug
        const foundTopic = topicsData.find(t => t.slug === topicSlug);
        if (!foundTopic) {
          setErrorMessage("Topic not found");
          return;
        }
        
        setTopic(foundTopic);
        
        // Get news for this topic
        const newsData = await apiClient.getTopicNews(foundTopic.id, 1, 20);
        setTopicNews(newsData.news);
        
        console.log("Topic found:", foundTopic);
        console.log("Topic news:", newsData);
        
      } catch (err: unknown) {
        setErrorMessage(
          err instanceof Error ? err.message : "Failed to fetch topic news"
        );
      } finally {
        setLoading(false);
        setTopicLoading(false);
      }
    };

    if (topicSlug) {
      fetchTopicNews();
    }

    // Initialize bookmarks
    const initializeBookmarks = async () => {
      try {
        const bookmarksData = await apiClient.getBookmarks();
        console.log("Initializing bookmarks on topic page:", bookmarksData);
        // Extract news IDs from the bookmarked news items
        const bookmarkedIds = bookmarksData.news.map((news: TrendingNews) => news.id);
        console.log("Bookmarked news IDs on topic page:", bookmarkedIds);
        setBookmarkedNews(new Set(bookmarkedIds));
      } catch (error) {
        console.error("Error initializing bookmarks:", error);
        // Set empty set on error to avoid undefined state
        setBookmarkedNews(new Set());
      }
    };
    
    initializeBookmarks();
  }, [topicSlug]);

  const handleNewsClick = (newsId: string) => {
    const token = getAccessToken();
    if (!token) {
      alert(i18n.language === 'am' ? 'ዜና ለማየት ይመዝገቡ።' : 'Please sign in to view news details.');
      return;
    }
    router.push(`/news/${newsId}`);
  };

  const handleBookmark = async (newsId: string, event: React.MouseEvent) => {
    event.stopPropagation();
    
    try {
      if (bookmarkedNews.has(newsId)) {
        // Remove bookmark
        console.log("Removing bookmark for:", newsId);
        await apiClient.removeBookmark(newsId);
        setBookmarkedNews(prev => {
          const newSet = new Set(prev);
          newSet.delete(newsId);
          console.log("Updated bookmarked news after removal on topic page:", Array.from(newSet));
          return newSet;
        });
      } else {
        // Add bookmark
        console.log("Adding bookmark for:", newsId);
        try {
          await apiClient.saveBookmark(newsId);
          setBookmarkedNews(prev => {
            const newSet = new Set(prev).add(newsId);
            console.log("Updated bookmarked news after addition on topic page:", Array.from(newSet));
            return newSet;
          });
        } catch (error: unknown) {
          // Handle 409 error (already bookmarked) gracefully
          if (error instanceof Error && (error.message?.includes('409') || error.message?.includes('already bookmarked'))) {
            // Item is already bookmarked, just update local state
            console.log("Item was already bookmarked, updating local state for:", newsId);
            setBookmarkedNews(prev => {
              const newSet = new Set(prev).add(newsId);
              console.log("Updated bookmarked news after 409 handling on topic page:", Array.from(newSet));
              return newSet;
            });
          } else {
            console.error("Error toggling bookmark:", error);
          }
        }
      }
    } catch (error) {
      console.error("Error toggling bookmark:", error);
    }
  };

  const getTopicNames = (topicIds: string[]): string[] => {
    if (!topicIds || !Array.isArray(topicIds) || !topics || topics.length === 0) {
      return []; // Return empty array if topics are not loaded or found
    }
    
    return topicIds
      .map(id => {
        const topic = topics.find(t => t.id === id);
        return topic ? (i18n.language === 'am' ? topic.label.am : topic.label.en) : null;
      })
      .filter(name => name !== null) as string[];
  };

  const getTopicImage = (topics: string[]) => {
    if (!topics || topics.length === 0) {
      // Use random image from 'other' folder (1-10)
      const randomImage = Math.floor(Math.random() * 6) + 1;
      return `/images/other/${randomImage}.jpg`;
    }

    const topicNames = getTopicNames(topics);
    const primaryTopic = topicNames[0]?.toLowerCase();
    
    console.log("getTopicImage: Primary topic:", primaryTopic, "from topic names:", topicNames);

    // Topic-specific image mapping
    const topicImageMap: { [key: string]: string } = {
      'technology': 'technology',
      'tech': 'technology',
      'science': 'science',
      'health': 'health',
      'sports': 'sports',
      'business': 'business',
      'politics': 'politics',
      'entertainment': 'entertainment',
      'education': 'education',
      'environment': 'environment',
      'agriculture': 'agriculture',
      'arts': 'arts',
      'culture': 'arts',
      'world': 'world',
      'local': 'local',
      'economy': 'business',
      'finance': 'business',
      'medicine': 'health',
      'fitness': 'health',
      'climate': 'environment',
      'nature': 'environment'
    };

    const imageFolder = topicImageMap[primaryTopic] || 'other';
    const randomImage = Math.floor(Math.random() * 6) + 1;
    const imagePath = `/images/${imageFolder}/${randomImage}.jpg`;
    
    console.log("getTopicImage: Using image from", imageFolder, "folder:", imagePath);
    return imagePath;
  };

  if (loading) {
    return (
      <>
        <ChatBot />
        <div
          className={`flex flex-col lg:flex-row gap-5 min-h-screen w-full transition-colors ${
            theme === "light" ? "bg-white text-black" : "bg-gray-900 text-white"
          }`}
        >
          <div className="flex-1 lg:ml-0 lg:mt-1 px-4 lg:px-6 lg:mr-10 w-full overflow-hidden">
            <div className="flex justify-between w-full mb-4">
              <TopBar />
            </div>
            <div className="w-full max-w-7xl mx-auto space-y-12 px-4">
              <div className="space-y-8">
                {/* Shimmer for news grid */}
                <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
                  {Array.from({ length: 6 }).map((_, index) => (
                    <div key={index} className="animate-pulse">
                      <div className={`h-48 rounded-lg ${theme === "dark" ? "bg-gray-700" : "bg-gray-200"}`}></div>
                      <div className="mt-4 space-y-2">
                        <div className={`h-4 rounded ${theme === "dark" ? "bg-gray-700" : "bg-gray-200"}`}></div>
                        <div className={`h-4 rounded w-3/4 ${theme === "dark" ? "bg-gray-700" : "bg-gray-200"}`}></div>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          </div>
        </div>
      </>
    );
  }

  if (errorMessage) {
    return (
      <>
        <ChatBot />
        <div
          className={`flex flex-col lg:flex-row gap-5 min-h-screen w-full transition-colors ${
            theme === "light" ? "bg-white text-black" : "bg-gray-900 text-white"
          }`}
        >
          <div className="flex-1 lg:ml-0 lg:mt-1 px-4 lg:px-6 lg:mr-10 w-full overflow-hidden">
            <div className="flex justify-between w-full mb-4">
              <TopBar />
            </div>
            <div className="w-full max-w-7xl mx-auto space-y-12 px-4">
              <div className="text-center py-10">
                <p className={`text-lg ${
                  theme === "dark" ? "text-gray-400" : "text-gray-600"
                }`}>
                  {i18n.language === 'am' ? 'ርዕስ አልተገኘም።' : 'Topic not found.'}
                </p>
              </div>
            </div>
          </div>
        </div>
      </>
    );
  }

  return (
    <>
      <ChatBot />
      <div
        className={`flex flex-col lg:flex-row gap-5 min-h-screen w-full transition-colors ${
          theme === "light" ? "bg-white text-black" : "bg-gray-900 text-white"
        }`}
      >
        <div className="flex-1 lg:ml-0 lg:mt-1 px-4 lg:px-6 lg:mr-10 w-full overflow-hidden">
          <div className="flex justify-between w-full mb-4">
            <TopBar />
          </div>
          <div className="w-full max-w-7xl mx-auto space-y-12 px-4">
            {topicLoading ? (
              <div className="space-y-8">
                {/* Shimmer for news grid */}
                <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
                  {Array.from({ length: 6 }).map((_, index) => (
                    <div key={index} className="animate-pulse">
                      <div className={`h-48 rounded-lg ${theme === "dark" ? "bg-gray-700" : "bg-gray-200"}`}></div>
                      <div className="mt-4 space-y-2">
                        <div className={`h-4 rounded ${theme === "dark" ? "bg-gray-700" : "bg-gray-200"}`}></div>
                        <div className={`h-4 rounded w-3/4 ${theme === "dark" ? "bg-gray-700" : "bg-gray-200"}`}></div>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            ) : topicNews && topicNews.length > 0 && topic ? (
              <NewsGridNew
                title={i18n.language === 'am' ? topic.label.am : topic.label.en}
                data={topicNews}
                onClick={handleNewsClick}
                onBookmark={handleBookmark}
                bookmarkedNews={bookmarkedNews}
                theme={theme}
                getTopicNames={getTopicNames}
                getTopicImage={getTopicImage}
                currentLanguage={i18n.language}
              />
            ) : (
              <div className="text-center py-10">
                <p className={`text-lg ${
                  theme === "dark" ? "text-gray-400" : "text-gray-600"
                }`}>
                  {i18n.language === 'am' ? 'ለዚህ ርዕስ ዜና ማግኛ አልተገኘም።' : 'No news articles found for this topic.'}
                </p>
              </div>
            )}
          </div>
        </div>
      </div>
    </>
  );
}
