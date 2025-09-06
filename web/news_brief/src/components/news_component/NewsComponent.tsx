"use client";

import { apiClient, News, TodayNews, Topic, TrendingNews, getAccessToken } from "@/lib/api";
import { useContext, useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { ThemeContext } from "@/app/contexts/ThemeContext";
import { motion } from "framer-motion";
import { useTranslation } from "react-i18next";

export default function NewsComponent() {
  const [todaysNews, setTodaysNews] = useState<TodayNews[] | null>(null);
  const [trendingNews, setTrendingNews] = useState<TrendingNews[] | null>(null);
  const [subscribedTopic1News, setSubscribedTopic1News] = useState<TrendingNews[] | null>(null);
  const [subscribedTopic2News, setSubscribedTopic2News] = useState<TrendingNews[] | null>(null);
  const [topics, setTopics] = useState<Topic[]>([]);
  const [userTopics, setUserTopics] = useState<string[]>([]);
  const [loading, setLoading] = useState(true);
  const [bookmarkedNews, setBookmarkedNews] = useState<Set<string>>(new Set());
  const [errorMessage, setErrorMessage] = useState<string | null>(null);
  const router = useRouter();
  const context = useContext(ThemeContext);
  if (!context)
    throw new Error("NewsComponent must be used inside ThemeProvider");
  const { theme } = context;
  const { i18n } = useTranslation();

  useEffect(() => {
    (async () => {
      try {
        setLoading(true);
        // First, get basic data
        const [todaysData, trendingData, topicsData, userData] = await Promise.all([
            apiClient.getTodaysNews(),
          apiClient.getTrendingNews(1, 6), // Get first 6 trending news items
            apiClient.getTopics(),
          apiClient.getUser(), // Get user's subscribed topics
          ]);
        
        setTodaysNews(todaysData);
        setTrendingNews(trendingData?.news || []);
        setTopics(topicsData);
        
        // Get user's subscribed topics from multiple possible sources
        let userTopicIds: string[] = [];
        
        // Try from API response first
        if (userData.topic_interest && userData.topic_interest.length > 0) {
          userTopicIds = userData.topic_interest;
          console.log("Found topics from API:", userTopicIds);
        } else {
          console.log("No topics from API, checking localStorage...");
          // Fallback to localStorage (same as top bar)
          try {
            const personData = localStorage.getItem("person");
            console.log("localStorage person data:", personData);
            if (personData) {
              const parsed = JSON.parse(personData);
              console.log("Parsed person data:", parsed);
              userTopicIds = parsed.user?.preferences?.topics || [];
              console.log("Topics from localStorage:", userTopicIds);
            } else {
              console.log("No person data in localStorage");
            }
          } catch (error) {
            console.error("Error reading from localStorage:", error);
          }
        }
        
        // If user is subscribed to all topics or has many topics, use all available topics
        if (userTopicIds.length >= topicsData.length * 0.8 || userTopicIds.length === 0) {
          console.log("User appears to be subscribed to all topics, using all available topics");
          userTopicIds = topicsData.map(topic => topic.id);
        }
        
        setUserTopics(userTopicIds);
        console.log("Final user's subscribed topic IDs:", userTopicIds);
        console.log("User is logged in:", !!getAccessToken());
        console.log("Available topics in system:", topicsData.map(t => ({ id: t.id, name: t.label.en })));
        
        // Get news for user's first two subscribed topics or default topics
        let topic1Data, topic2Data;
        
        try {
          const topicPromises = [];
          
          if (userTopicIds && userTopicIds.length > 0) {
            console.log("Using user's subscribed topics:", userTopicIds);
            // Get news for first subscribed topic
            if (userTopicIds[0]) {
              console.log("Fetching news for topic 1:", userTopicIds[0]);
              topicPromises.push(apiClient.getTopicNews(userTopicIds[0], 1, 6));
            } else {
              // Default to first available topic
              if (topicsData[0]) {
                console.log("Using first available topic:", topicsData[0].id);
                topicPromises.push(apiClient.getTopicNews(topicsData[0].id, 1, 6));
              } else {
                topicPromises.push(Promise.resolve({ news: [], total: 0, total_pages: 0, page: 1, limit: 10 }));
              }
            }
            
            // Get news for second subscribed topic
            if (userTopicIds[1]) {
              console.log("Fetching news for topic 2:", userTopicIds[1]);
              topicPromises.push(apiClient.getTopicNews(userTopicIds[1], 1, 6));
            } else {
              // Default to second available topic
              if (topicsData[1]) {
                console.log("Using second available topic:", topicsData[1].id);
                topicPromises.push(apiClient.getTopicNews(topicsData[1].id, 1, 6));
              } else {
                topicPromises.push(Promise.resolve({ news: [], total: 0, total_pages: 0, page: 1, limit: 10 }));
              }
            }
          } else {
            console.log("No user subscribed topics found, using first two available topics");
            // User has no subscribed topics, use first two available topics
            if (topicsData[0]) {
              console.log("Using first available topic:", topicsData[0].id, topicsData[0].label.en);
              topicPromises.push(apiClient.getTopicNews(topicsData[0].id, 1, 6));
            } else {
              topicPromises.push(Promise.resolve({ news: [], total: 0, total_pages: 0, page: 1, limit: 10 }));
            }
            
            if (topicsData[1]) {
              console.log("Using second available topic:", topicsData[1].id, topicsData[1].label.en);
              topicPromises.push(apiClient.getTopicNews(topicsData[1].id, 1, 6));
            } else {
              topicPromises.push(Promise.resolve({ news: [], total: 0, total_pages: 0, page: 1, limit: 10 }));
            }
          }
          
          [topic1Data, topic2Data] = await Promise.all(topicPromises);
          console.log("Topic 1 API response:", topic1Data);
          console.log("Topic 2 API response:", topic2Data);
          setSubscribedTopic1News(topic1Data.news);
          setSubscribedTopic2News(topic2Data.news);
        } catch (topicError) {
          console.error("Error fetching topic news:", topicError);
          console.log("Setting empty news arrays due to API error...");
          setSubscribedTopic1News([]);
          setSubscribedTopic2News([]);
          
          // Set empty topic data for logging
          topic1Data = { news: [], total: 0, total_pages: 0, page: 1, limit: 10 };
          topic2Data = { news: [], total: 0, total_pages: 0, page: 1, limit: 10 };
        }
        
        // Debug logging
        console.log("Today's news data:", todaysData);
        console.log("Trending news data:", trendingData);
        console.log("User's subscribed topics:", userTopicIds);
        console.log("Topics data:", topicsData);
        console.log("Number of topics loaded:", topicsData?.length);
        console.log("First trending news item topics:", trendingData?.news?.[0]?.topics);
        console.log("User data:", userData);
        console.log("User topics length:", userTopicIds?.length);
        console.log("Topic 1 data:", topic1Data);
        console.log("Topic 2 data:", topic2Data);
        console.log("Topic 1 news length:", topic1Data?.news?.length);
        console.log("Topic 2 news length:", topic2Data?.news?.length);
      } catch (err: unknown) {
        setErrorMessage(
          err instanceof Error ? err.message : "Failed to fetch news"
        );
      } finally {
        setLoading(false);
      }
    })();

    // Initialize bookmarks
    const initializeBookmarks = async () => {
      try {
        const bookmarksData = await apiClient.getBookmarks();
        console.log("Initializing bookmarks:", bookmarksData);
        // Extract news IDs from the bookmarked news items
        const bookmarkedIds = bookmarksData.news.map(news => news.id);
        console.log("Bookmarked news IDs:", bookmarkedIds);
        setBookmarkedNews(new Set(bookmarkedIds));
      } catch (error) {
        console.error("Error initializing bookmarks:", error);
        // Set empty set on error to avoid undefined state
        setBookmarkedNews(new Set());
      }
    };
    
    initializeBookmarks();
  }, []);

  const handleNewsClick = (newsId: string) => {
    const token = getAccessToken();
    if (!token) {
      // Show locked state for non-logged-in users
      alert(i18n.language === 'am' ? 'ዜና ለማየት ይመዝገቡ።' : 'Please sign in to view news details.');
      return;
    }
    router.push(`/news/${newsId}`);
  };

  // Bookmark handler
  const handleBookmark = async (newsId: string, event: React.MouseEvent) => {
    event.stopPropagation(); // Prevent triggering the news click
    
    console.log("Bookmark clicked for news:", newsId);
    console.log("Current bookmarked news:", Array.from(bookmarkedNews));
    console.log("Is currently bookmarked:", bookmarkedNews.has(newsId));
    
    try {
      if (bookmarkedNews.has(newsId)) {
        // Remove bookmark
        console.log("Removing bookmark for:", newsId);
        await apiClient.removeBookmark(newsId);
        setBookmarkedNews(prev => {
          const newSet = new Set(prev);
          newSet.delete(newsId);
          console.log("Updated bookmarked news after removal:", Array.from(newSet));
          return newSet;
        });
      } else {
        // Add bookmark
        console.log("Adding bookmark for:", newsId);
        try {
          await apiClient.saveBookmark(newsId);
          setBookmarkedNews(prev => {
            const newSet = new Set(prev).add(newsId);
            console.log("Updated bookmarked news after addition:", Array.from(newSet));
            return newSet;
          });
        } catch (error: unknown) {
          // Handle 409 error (already bookmarked) gracefully
          if (error instanceof Error && (error.message?.includes('409') || error.message?.includes('already bookmarked'))) {
            // Item is already bookmarked, just update local state
            console.log("Item was already bookmarked, updating local state for:", newsId);
            setBookmarkedNews(prev => {
              const newSet = new Set(prev).add(newsId);
              console.log("Updated bookmarked news after 409 handling:", Array.from(newSet));
              return newSet;
            });
          } else {
            throw error; // Re-throw other errors
          }
        }
      }
    } catch (error) {
      console.error("Error toggling bookmark:", error);
      // You could add a toast notification here
    }
  };

  // Helper function to get topic-based image from public folder
  const getTopicImage = (topics: string[]) => {
    // Safety check - if topics is undefined, null, or not an array, use default
    if (!topics || !Array.isArray(topics) || topics.length === 0) {
      // Use random image from other folder (1-6)
      const randomImage = Math.floor(Math.random() * 6) + 1; // 1-6
    return `/images/other/${randomImage}.jpg`;
    }
    
    // Map topic IDs to topic names and then to image folders
    const topicNames = getTopicNames(topics);
    const primaryTopic = topicNames[0]?.toLowerCase() || 'general';
    
    console.log("getTopicImage: Primary topic:", primaryTopic, "from topic names:", topicNames);
    
    // Map topic names to available image folders
    const topicImageMap: { [key: string]: string } = {
      'technology': 'technology',
      'tech': 'technology',
      'health': 'health',
      'sports': 'sports',
      'environment': 'environment',
      'climate': 'environment',
      'science': 'environment',
      'business': 'technology', // Use technology folder for business
      'politics': 'other',
      'arts': 'other',
      'entertainment': 'other',
      'education': 'health', // Use health folder for education
      'agriculture': 'environment', // Use environment folder for agriculture
      'travel': 'other',
      'general': 'other',
      'news': 'other'
    };
    
    const imageFolder = topicImageMap[primaryTopic] || 'other';
    
    // Select random image based on folder
    let randomImage: number;
    if (imageFolder === 'other') {
      // For other folder, use images 1-6
      randomImage = Math.floor(Math.random() * 6) + 1; // 1-6
    } else {
      // For topic-specific folders, use images 1-6
      randomImage = Math.floor(Math.random() * 6) + 1; // 1-6
    }
    
    const imagePath = `/images/${imageFolder}/${randomImage}.jpg`;
    
    console.log("getTopicImage: Using image from", imageFolder, "folder:", imagePath);
    return imagePath;
  };

  // Helper function to convert topic IDs to topic names
  const getTopicNames = (topicIds: string[]): string[] => {
    // Safety check - if topicIds is undefined, null, or not an array, return empty array
    if (!topicIds || !Array.isArray(topicIds)) {
      console.log("getTopicNames: topicIds is invalid:", topicIds);
      return [];
    }
    
    // Safety check - if topics data not loaded yet, try to infer from common topic IDs
    if (!topics || topics.length === 0) {
      console.log("getTopicNames: topics not loaded yet, trying to infer from topic IDs:", topicIds);
      // Try to infer topic names from common patterns in topic IDs
      const inferredNames = topicIds.map(id => {
        const idLower = id.toLowerCase();
        if (idLower.includes('tech') || idLower.includes('technology')) return 'Technology';
        if (idLower.includes('health') || idLower.includes('medical')) return 'Health';
        if (idLower.includes('sport') || idLower.includes('fitness')) return 'Sports';
        if (idLower.includes('env') || idLower.includes('climate') || idLower.includes('science')) return 'Environment';
        if (idLower.includes('business') || idLower.includes('economy')) return 'Business';
        if (idLower.includes('art') || idLower.includes('culture')) return 'Arts';
        if (idLower.includes('education') || idLower.includes('school')) return 'Education';
        if (idLower.includes('agriculture') || idLower.includes('farming')) return 'Agriculture';
        return 'General';
      });
      return inferredNames.length > 0 ? inferredNames : ["News"];
    }
    
    console.log("getTopicNames: Converting topic IDs:", topicIds, "with topics data:", topics.length, "topics");
    
    const result = topicIds.map(id => {
      const topic = topics.find(t => t.id === id);
      if (topic) {
        const topicName = i18n.language === 'am' ? topic.label.am : topic.label.en;
        console.log(`getTopicNames: ID ${id} -> ${topicName}`);
        return topicName;
      } else {
        console.log(`getTopicNames: Topic not found for ID ${id}, using fallback`);
        // If topic not found, try to extract a meaningful name from the ID or use a generic fallback
        return "General";
      }
    });
    
    // Remove duplicates and filter out empty strings
    const uniqueResult = [...new Set(result)].filter(name => name && name.trim() !== '');
    
    // Ensure we always return at least one topic name
    const finalResult = uniqueResult.length > 0 ? uniqueResult : ["News"];
    
    console.log("getTopicNames: Final result:", finalResult);
    return finalResult;
  };

  if (loading)
    return (
      <div
        className={`w-full max-w-7xl mx-auto px-4 space-y-12 ${
          theme === "dark" ? "bg-gray-900" : "bg-white"
        }`}
      >
        <SectionHeader title={i18n.language === 'am' ? 'ዛሬ' : 'Today'} theme={theme} />
        <div className={`grid md:grid-cols-2 lg:grid-cols-3 gap-6 pb-10`}>
          <div className="md:col-span-2">
            <FeaturedTodayShimmer theme={theme} />
          </div>
          <div
            className={`flex flex-col divide-y ${
              theme === "dark" ? "divide-gray-700" : "divide-gray-200"
            }`}
          >
            {Array.from({ length: 3 }).map((_, i) => (
              <SmallStoryShimmer key={i} theme={theme} />
            ))}
          </div>
        </div>
      </div>
    );

  if (errorMessage)
    return (
      <p
        className={`text-center py-10 ${
          theme === "dark" ? "text-gray-200" : "text-red-500"
        }`}
      >
        Error: {errorMessage}
      </p>
    );

  return (
    <div
      className={`w-full max-w-7xl mx-auto space-y-12 px-4 transition-colors duration-300 ${
        theme === "dark"
          ? "bg-gray-900 text-gray-100"
          : "bg-white text-gray-900"
      }`}
    >
      {/* Today Section */}
      <SectionHeader title={i18n.language === 'am' ? 'ዛሬ' : 'Today'} theme={theme} />
      <div
        className={`grid md:grid-cols-2 lg:grid-cols-3 gap-6 border-b pb-10 ${
          theme === "dark" ? "border-gray-700" : "border-gray-200"
        }`}
      >
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.4 }}
          className="md:col-span-2"
        >
          <FeaturedTodayNew
            news={todaysNews?.[0]}
            onClick={handleNewsClick}
            onBookmark={handleBookmark}
            isBookmarked={bookmarkedNews.has(todaysNews?.[0]?.id || '')}
            theme={theme}
            getTopicImage={getTopicImage}
            currentLanguage={i18n.language}
            getTopicNames={getTopicNames}
          />
        </motion.div>
        <div
          className={`flex flex-col divide-y ${
            theme === "dark" ? "divide-gray-700" : "divide-gray-200"
          }`}
        >
          {todaysNews && todaysNews.length > 1 ? (
            todaysNews.slice(1).map((story, i) => (
            <motion.div
              key={story.id}
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.4, delay: i * 0.1 }}
            >
                <SmallStoryNew
                story={story}
                onClick={handleNewsClick}
                onBookmark={handleBookmark}
                isBookmarked={bookmarkedNews.has(story.id)}
                theme={theme}
                  getTopicImage={getTopicImage}
                  currentLanguage={i18n.language}
                  getTopicNames={getTopicNames}
              />
            </motion.div>
            ))
          ) : (
            // Show creative placeholder when no additional stories
            <div className="py-8 px-4 text-center">
              <div className={`inline-flex items-center justify-center w-16 h-16 rounded-full mb-4 ${
                theme === "dark" ? "bg-blue-900/30" : "bg-blue-100"
              }`}>
                <svg 
                  className={`w-8 h-8 ${theme === "dark" ? "text-blue-400" : "text-blue-600"}`} 
                  fill="none" 
                  stroke="currentColor" 
                  viewBox="0 0 24 24"
                >
                  <path 
                    strokeLinecap="round" 
                    strokeLinejoin="round" 
                    strokeWidth={2} 
                    d="M19 20H5a2 2 0 01-2-2V6a2 2 0 012-2h10a2 2 0 012 2v1m2 13a2 2 0 01-2-2V7m2 13a2 2 0 002-2V9a2 2 0 00-2-2h-2m-4-3H9M7 16h6M7 8h6v4H7V8z" 
                  />
                </svg>
              </div>
              <h3 className={`text-lg font-semibold mb-2 ${
                theme === "dark" ? "text-gray-200" : "text-gray-800"
              }`}>
                Stay Tuned
              </h3>
              <p className={`text-sm leading-relaxed ${
                theme === "dark" ? "text-gray-400" : "text-gray-600"
              }`}>
                Fresh stories are being prepared for you. Check back soon for the latest updates and breaking news.
              </p>
              <div className="mt-4 flex justify-center">
                <div className={`inline-flex items-center space-x-1 px-3 py-1 rounded-full text-xs font-medium ${
                  theme === "dark" 
                    ? "bg-gray-800 text-gray-300" 
                    : "bg-gray-100 text-gray-600"
                }`}>
                  <div className="w-2 h-2 bg-green-500 rounded-full animate-pulse"></div>
                  <span>Live Updates</span>
                </div>
              </div>
            </div>
          )}
        </div>
      </div>

      {/* Trending Section */}
      <SectionHeader title={i18n.language === 'am' ? 'ተወዳጅ' : 'Trending'} theme={theme} />
      <div
        className={`overflow-x-auto scrollbar-hide -mx-4 px-4 border-b pb-10 ${
          theme === "dark" ? "border-gray-700" : "border-gray-200"
        }`}
      >
        <div className="flex gap-6 min-w-max">
          {trendingNews && trendingNews.length > 0 ? (
            trendingNews.slice(0, 6).map((item) => (
            <div key={item.id} className="w-64 flex-shrink-0">
                <TrendingCardNew
                story={item}
                onClick={handleNewsClick}
                onBookmark={handleBookmark}
                isBookmarked={bookmarkedNews.has(item.id)}
                theme={theme}
                getTopicNames={getTopicNames}
                  getTopicImage={getTopicImage}
                  currentLanguage={i18n.language}
              />
            </div>
            ))
          ) : (
            <div className="w-full text-center py-8">
              <p className={`text-sm ${theme === "dark" ? "text-gray-400" : "text-gray-600"}`}>
                No trending news available at the moment.
              </p>
            </div>
          )}
        </div>
      </div>

      {/* First Topic Section - Only show if we have data */}
      {subscribedTopic1News && subscribedTopic1News.length > 0 && (
        <NewsGridNew
          title={userTopics[0] ? getTopicNames([userTopics[0]])[0] : "Technology"}
          data={subscribedTopic1News}
        onClick={handleNewsClick}
        onBookmark={handleBookmark}
        bookmarkedNews={bookmarkedNews}
        theme={theme}
        getTopicNames={getTopicNames}
          getTopicImage={getTopicImage}
          currentLanguage={i18n.language}
        />
      )}

      {/* Second Topic Section - Only show if we have data */}
      {subscribedTopic2News && subscribedTopic2News.length > 0 && (
        <NewsGridNew
          title={userTopics[1] ? getTopicNames([userTopics[1]])[0] : "Health"}
          data={subscribedTopic2News}
        onClick={handleNewsClick}
        onBookmark={handleBookmark}
        bookmarkedNews={bookmarkedNews}
        theme={theme}
        getTopicNames={getTopicNames}
          getTopicImage={getTopicImage}
          currentLanguage={i18n.language}
      />
      )}
    </div>
  );
}

/* --- Shimmer Loading --- */
function Shimmer({ className, theme }: { className?: string; theme: string }) {
  return (
    <div
      className={`animate-pulse ${
        theme === "dark" ? "bg-gray-700" : "bg-gray-200"
      } rounded-md ${className}`}
    />
  );
}

function FeaturedTodayShimmer({ theme }: { theme: string }) {
  return (
    <div className="space-y-4">
      <Shimmer className="w-full h-80 rounded-lg" theme={theme} />
      <Shimmer className="w-3/4 h-6" theme={theme} />
      <Shimmer className="w-full h-4" theme={theme} />
      <Shimmer className="w-2/3 h-4" theme={theme} />
    </div>
  );
}

function SmallStoryShimmer({ theme }: { theme: string }) {
  return (
    <div className="py-4 space-y-2">
      <Shimmer className="w-1/3 h-3" theme={theme} />
      <Shimmer className="w-2/3 h-4" theme={theme} />
      <Shimmer className="w-full h-3" theme={theme} />
    </div>
  );
}


/* --- Helper Components --- */
export function SectionHeader({ title, theme }: { title: string; theme: string }) {
  return (
    <div className="flex items-center mb-6">
      <h2 className="text-xl font-bold tracking-tight flex items-center gap-2">
        <span className="w-1.5 h-6 bg-blue-600 rounded-full"></span>
        {title}
      </h2>
    </div>
  );
}

export function TopicTag({ text, theme }: { text: string; theme: string }) {
  return (
    <span
      className={`inline-block px-2 py-0.5 rounded-full uppercase tracking-wide text-[10px] font-medium ${
        theme === "dark"
          ? "bg-gray-800 text-gray-300"
          : "bg-gray-100 text-gray-600"
      }`}
    >
      {text}
    </span>
  );
}

function SmallStory({
  story,
  onClick,
  theme,
  getTopicNames,
}: {
  story: News;
  onClick: (id: string) => void;
  theme: string;
  getTopicNames: (topicIds: string[]) => string[];
}) {
  const topicNames = getTopicNames(story.topics);
  return (
    <div
      className={`py-4 cursor-pointer rounded-md px-2 transition-colors ${
        theme === "dark" ? "hover:bg-gray-800" : "hover:bg-gray-50"
      }`}
      onClick={() => onClick(story.id)}
    >
      <div className="flex items-center gap-2 mb-1 flex-wrap">
        {topicNames.map((topicName, i) => (
          <TopicTag key={i} text={topicName} theme={theme} />
        ))}
        <p
          className={`text-[11px] ${
            theme === "dark" ? "text-gray-400" : "text-gray-500"
          }`}
        >
          {story.posted_at}
        </p>
      </div>
      <h3
        className={`text-sm font-semibold mb-1 ${
          theme === "dark" ? "text-gray-100" : ""
        }`}
      >
        {story.title}
      </h3>
      <p
        className={`text-xs line-clamp-2 leading-relaxed ${
          theme === "dark" ? "text-gray-300" : "text-gray-600"
        }`}
      >
        {story.description}
      </p>
    </div>
  );
}

function SmallStoryNew({
  story,
  onClick,
  onBookmark,
  isBookmarked,
  theme,
  getTopicImage,
  currentLanguage,
  getTopicNames,
}: {
  story: TodayNews;
  onClick: (id: string) => void;
  onBookmark: (id: string, event: React.MouseEvent) => void;
  isBookmarked: boolean;
  theme: string;
  getTopicImage: (topics: string[]) => string;
  currentLanguage: string;
  getTopicNames: (topicIds: string[]) => string[];
}) {
  const title = currentLanguage === 'am' ? story.title_am : story.title_en;
  const summary = currentLanguage === 'am' ? story.summary_am : story.summary_en;
  const topicNames = getTopicNames(story.topics);
  
  return (
    <div
      className={`py-4 cursor-pointer rounded-md px-2 transition-colors ${
        theme === "dark" ? "hover:bg-gray-800" : "hover:bg-gray-50"
      }`}
      onClick={() => onClick(story.id)}
    >
      <div className="flex items-center justify-between mb-1">
        <div className="flex items-center gap-2 flex-wrap">
          {topicNames.map((topicName, i) => (
            <TopicTag key={i} text={topicName} theme={theme} />
          ))}
          <p
            className={`text-[11px] ${
              theme === "dark" ? "text-gray-400" : "text-gray-500"
            }`}
          >
            {new Date(story.published_at).toLocaleDateString()}
          </p>
        </div>
        <button
          onClick={(e) => onBookmark(story.id, e)}
          className={`p-1 rounded-full transition-colors ${
            isBookmarked 
              ? "text-yellow-500 hover:text-yellow-600" 
              : theme === "dark" 
                ? "text-gray-400 hover:text-yellow-500" 
                : "text-gray-500 hover:text-yellow-500"
          }`}
        >
          <svg className="w-4 h-4" fill={isBookmarked ? "currentColor" : "none"} stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z" />
          </svg>
        </button>
      </div>
      <h3
        className={`text-sm font-semibold mb-1 ${
          theme === "dark" ? "text-gray-100" : ""
        }`}
      >
        {title}
      </h3>
      <p
        className={`text-xs line-clamp-2 leading-relaxed ${
          theme === "dark" ? "text-gray-300" : "text-gray-600"
        }`}
      >
        {summary}
      </p>
    </div>
  );
}

function FeaturedToday({
  news,
  onClick,
  theme,
  getTopicNames,
}: {
  news?: News;
  onClick: (id: string) => void;
  theme: string;
  getTopicNames: (topicIds: string[]) => string[];
}) {
  if (!news) return null;
  const topicNames = getTopicNames(news.topics);
  return (
    <div
      className={`group cursor-pointer transition-shadow  rounded-lg overflow-hidden hover:shadow-lg`}
      onClick={() => onClick(news.id)}
    >
      <div className="overflow-hidden">
        <img
          src={news.image_url}
          alt={news.title}
          className="w-full h-80 object-cover rounded-lg transition-transform duration-300 group-hover:scale-105"
        />
      </div>
      <div className="mt-4 pl-2 pb-2">
        <p
          className={`text-xs mb-1 uppercase tracking-wide ${
            theme === "dark" ? "text-gray-400" : "text-gray-500"
          }`}
        >
          {topicNames.join(', ')} · {news.posted_at}
        </p>
        <h2
          className={`text-2xl  font-bold mb-3 ${
            theme === "dark"
              ? "text-gray-100 hover:text-blue-400"
              : "hover:text-blue-600"
          }`}
        >
          {news.title}
        </h2>
        <p
          className={`text-sm line-clamp-3 leading-relaxed ${
            theme === "dark" ? "text-gray-300" : "text-gray-600"
          }`}
        >
          {news.description}
        </p>
        <p
          className={`mt-3 text-xs font-medium ${
            theme === "dark" ? "text-blue-400" : "text-blue-600"
          }`}
        >
          Continue Reading...
        </p>
      </div>
    </div>
  );
}


export function FeaturedTodayNew({
  news,
  onClick,
  onBookmark,
  isBookmarked,
  theme,
  getTopicImage,
  currentLanguage,
  getTopicNames,
}: {
  news?: TodayNews;
  onClick: (id: string) => void;
  onBookmark: (id: string, event: React.MouseEvent) => void;
  isBookmarked: boolean;
  theme: string;
  getTopicImage: (topics: string[]) => string;
  currentLanguage: string;
  getTopicNames: (topicIds: string[]) => string[];
}) {
  if (!news) return null;
  
  const title = currentLanguage === 'am' ? news.title_am : news.title_en;
  const summary = currentLanguage === 'am' ? news.summary_am : news.summary_en;
  const imageUrl = getTopicImage(news.topics);
  const topicNames = getTopicNames(news.topics);
  
  return (
    <div
      className={`group cursor-pointer transition-shadow rounded-lg overflow-hidden hover:shadow-lg`}
      onClick={() => onClick(news.id)}
    >
      <div className="overflow-hidden">
        <img
          src={imageUrl}
          alt={title}
          className="w-full h-80 object-cover rounded-lg transition-transform duration-300 group-hover:scale-105"
        />
      </div>
      <div className="mt-4 pl-2 pb-2">
        <div className="flex items-center justify-between mb-1">
          <p
            className={`text-xs uppercase tracking-wide ${
              theme === "dark" ? "text-gray-400" : "text-gray-500"
            }`}
          >
            {topicNames.join(', ')} · {new Date(news.published_at).toLocaleDateString()}
          </p>
          <button
            onClick={(e) => onBookmark(news.id, e)}
            className={`p-1 rounded-full transition-colors ${
              isBookmarked 
                ? "text-yellow-500 hover:text-yellow-600" 
                : theme === "dark" 
                  ? "text-gray-400 hover:text-yellow-500" 
                  : "text-gray-500 hover:text-yellow-500"
            }`}
          >
            <svg className="w-5 h-5" fill={isBookmarked ? "currentColor" : "none"} stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z" />
            </svg>
          </button>
        </div>
        <h2
          className={`text-2xl font-bold mb-3 ${
            theme === "dark"
              ? "text-gray-100 hover:text-blue-400"
              : "hover:text-blue-600"
          }`}
        >
          {title}
        </h2>
        <p
          className={`text-sm line-clamp-3 leading-relaxed ${
            theme === "dark" ? "text-gray-300" : "text-gray-600"
          }`}
        >
          {summary}
        </p>
        <p
          className={`mt-3 text-xs font-medium ${
            theme === "dark" ? "text-blue-400" : "text-blue-600"
          }`}
        >
          Continue Reading...
        </p>
      </div>
    </div>
  );
}

function FeaturedStory({
  news,
  onClick,
  theme,
  getTopicNames,
}: {
  news?: News;
  onClick: (id: string) => void;
  theme: string;
  getTopicNames: (topicIds: string[]) => string[];
}) {
  if (!news) return null;
  const topicNames = getTopicNames(news.topics);
  return (
    <div
      className={`group cursor-pointer rounded-lg overflow-hidden transition-shadow hover:shadow-md`}
      onClick={() => onClick(news.id)}
    >
      <div className="overflow-hidden">
        <img
          src={news.image_url}
          alt={news.title}
          className="w-full h-52 object-cover rounded-lg transition-transform duration-300 group-hover:scale-105"
        />
      </div>
      <div className="mt-3 pl-2 pb-1">
        <div className="flex items-center gap-2 mb-1 flex-wrap">
          {topicNames.map((topicName, i) => (
            <TopicTag key={i} text={topicName} theme={theme} />
          ))}
          <p
            className={`text-[11px] ${
              theme === "dark" ? "text-gray-400" : "text-gray-500"
            }`}
          >
            {news.posted_at}
          </p>
        </div>
        <h2
          className={`text-lg font-bold mb-1 ${
            theme === "dark"
              ? "text-gray-100 hover:text-blue-400"
              : "hover:text-blue-600"
          }`}
        >
          {news.title}
        </h2>
        <p
          className={`text-sm line-clamp-2 ${
            theme === "dark" ? "text-gray-300" : "text-gray-600"
          }`}
        >
          {news.description}
        </p>
      </div>
    </div>
  );
}

function FeaturedStoryNew({
  news,
  onClick,
  onBookmark,
  isBookmarked,
  theme,
  getTopicNames,
  getTopicImage,
  currentLanguage,
}: {
  news?: TrendingNews;
  onClick: (id: string) => void;
  onBookmark: (id: string, event: React.MouseEvent) => void;
  isBookmarked: boolean;
  theme: string;
  getTopicNames: (topicIds: string[]) => string[];
  getTopicImage: (topics: string[]) => string;
  currentLanguage: string;
}) {
  if (!news) return null;
  
  const title = currentLanguage === 'am' ? news.title_am : news.title_en;
  const summary = currentLanguage === 'am' ? news.summary_am : news.summary_en;
  const topicNames = getTopicNames(news.topics);
  const imageUrl = getTopicImage(news.topics);
  
  return (
    <div
      className={`group cursor-pointer rounded-lg overflow-hidden transition-shadow hover:shadow-md`}
      onClick={() => onClick(news.id)}
    >
      <div className="overflow-hidden">
        <img
          src={imageUrl}
          alt={title}
          className="w-full h-52 object-cover rounded-lg transition-transform duration-300 group-hover:scale-105"
        />
      </div>
      <div className="mt-3 pl-2 pb-1">
        <div className="flex items-center justify-between mb-1">
          <div className="flex items-center gap-2 flex-wrap">
            {topicNames.map((topicName, i) => (
              <TopicTag key={i} text={topicName} theme={theme} />
            ))}
            <p
              className={`text-[11px] ${
                theme === "dark" ? "text-gray-400" : "text-gray-500"
              }`}
            >
              {new Date(news.published_at).toLocaleDateString()}
            </p>
          </div>
          <button
            onClick={(e) => onBookmark(news.id, e)}
            className={`p-1 rounded-full transition-colors ${
              isBookmarked 
                ? "text-yellow-500 hover:text-yellow-600" 
                : theme === "dark" 
                  ? "text-gray-400 hover:text-yellow-500" 
                  : "text-gray-500 hover:text-yellow-500"
            }`}
          >
            <svg className="w-4 h-4" fill={isBookmarked ? "currentColor" : "none"} stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z" />
            </svg>
          </button>
        </div>
        <h2
          className={`text-lg font-bold mb-1 ${
            theme === "dark"
              ? "text-gray-100 hover:text-blue-400"
              : "hover:text-blue-600"
          }`}
        >
          {title}
        </h2>
        <p
          className={`text-sm line-clamp-2 ${
            theme === "dark" ? "text-gray-300" : "text-gray-600"
          }`}
        >
          {summary}
        </p>
      </div>
    </div>
  );
}

function TrendingCard({
  story,
  onClick,
  theme,
  getTopicNames,
}: {
  story: News;
  onClick: (id: string) => void;
  theme: string;
  getTopicNames: (topicIds: string[]) => string[];
}) {
  const topicNames = getTopicNames(story.topics);
  return (
    <div
      className={`cursor-pointer group rounded-lg overflow-hidden transition-shadow hover:shadow-md`}
      onClick={() => onClick(story.id)}
    >
      <div className="overflow-hidden">
        <img
          src={story.image_url}
          alt={story.title}
          className="w-full h-28 object-cover rounded-lg transition-transform duration-300 group-hover:scale-105"
        />
      </div>
      <div className="mt-2 pl-2 pb-1">
        <div className="flex items-center gap-2 mb-1 flex-wrap">
          {topicNames.map((topicName, i) => (
            <TopicTag key={i} text={topicName} theme={theme} />
          ))}
          <p
            className={`text-[11px] ${
              theme === "dark" ? "text-gray-400" : "text-gray-500"
            }`}
          >
            {story.posted_at}
          </p>
        </div>
        <h4
          className={`text-sm font-semibold mb-1 line-clamp-2 ${
            theme === "dark"
              ? "text-gray-100 hover:text-blue-400"
              : "hover:text-blue-600"
          }`}
        >
          {story.title}
        </h4>
        <p
          className={`text-xs line-clamp-2 leading-relaxed ${
            theme === "dark" ? "text-gray-300" : "text-gray-600"
          }`}
        >
          {story.description}
        </p>
      </div>
    </div>
  );
}

export function TrendingCardNew({
  story,
  onClick,
  onBookmark,
  isBookmarked,
  theme,
  getTopicNames,
  getTopicImage,
  currentLanguage,
}: {
  story: TrendingNews;
  onClick: (id: string) => void;
  onBookmark: (id: string, event: React.MouseEvent) => void;
  isBookmarked: boolean;
  theme: string;
  getTopicNames: (topicIds: string[]) => string[];
  getTopicImage: (topics: string[]) => string;
  currentLanguage: string;
}) {
  const title = currentLanguage === 'am' ? story.title_am : story.title_en;
  const summary = currentLanguage === 'am' ? story.summary_am : story.summary_en;
  const topicNames = getTopicNames(story.topics);
  const imageUrl = getTopicImage(story.topics);
  
  return (
    <div
      className={`cursor-pointer group rounded-lg overflow-hidden transition-shadow hover:shadow-md`}
      onClick={() => onClick(story.id)}
    >
      <div className="overflow-hidden">
        <img
          src={imageUrl}
          alt={title}
          className="w-full h-28 object-cover rounded-lg transition-transform duration-300 group-hover:scale-105"
        />
      </div>
      <div className="mt-2 pl-2 pb-1">
        <div className="flex items-center justify-between mb-1">
          <div className="flex items-center gap-2 flex-wrap">
            {topicNames.map((topicName, i) => (
              <TopicTag key={i} text={topicName} theme={theme} />
            ))}
            <p
              className={`text-[11px] ${
                theme === "dark" ? "text-gray-400" : "text-gray-500"
              }`}
            >
              {new Date(story.published_at).toLocaleDateString()}
            </p>
          </div>
          <button
            onClick={(e) => onBookmark(story.id, e)}
            className={`p-1 rounded-full transition-colors ${
              isBookmarked 
                ? "text-yellow-500 hover:text-yellow-600" 
                : theme === "dark" 
                  ? "text-gray-400 hover:text-yellow-500" 
                  : "text-gray-500 hover:text-yellow-500"
            }`}
          >
            <svg className="w-4 h-4" fill={isBookmarked ? "currentColor" : "none"} stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z" />
            </svg>
          </button>
        </div>
        <h4
          className={`text-sm font-semibold mb-1 line-clamp-2 ${
            theme === "dark"
              ? "text-gray-100 hover:text-blue-400"
              : "hover:text-blue-600"
          }`}
        >
          {title}
        </h4>
        <p
          className={`text-xs line-clamp-2 leading-relaxed ${
            theme === "dark" ? "text-gray-300" : "text-gray-600"
          }`}
        >
          {summary}
        </p>
      </div>
    </div>
  );
}

export function NewsGrid({
  title,
  data,
  onClick,
  theme,
  getTopicNames,
}: {
  title: string;
  data: News[] | null;
  onClick: (id: string) => void;
  theme: string;
  getTopicNames: (topicIds: string[]) => string[];
}) {
  return (
    <>
      <SectionHeader title={title} theme={theme} />
      <div
        className={`grid md:grid-cols-2 lg:grid-cols-3 gap-6 border-b pb-8 ${
          theme === "dark" ? "border-gray-700" : "border-gray-200"
        }`}
      >
        <div className="md:col-span-2 lg:col-span-1">
          <FeaturedStory news={data?.[0]} onClick={onClick} theme={theme} getTopicNames={getTopicNames} />
        </div>
        <div
          className={`flex flex-col divide-y ${
            theme === "dark" ? "divide-gray-700" : "divide-gray-200"
          }`}
        >
          {data?.slice(1, 4).map((story) => (
            <SmallStory
              key={story.id}
              story={story}
              onClick={onClick}
              theme={theme}
              getTopicNames={getTopicNames}
            />
          ))}
        </div>
        <div
          className={`flex flex-col divide-y ${
            theme === "dark" ? "divide-gray-700" : "divide-gray-200"
          }`}
        >
          {data?.slice(4, 7).map((story) => (
            <SmallStory
              key={story.id}
              story={story}
              onClick={onClick}
              theme={theme}
              getTopicNames={getTopicNames}
            />
          ))}
        </div>
      </div>
    </>
  );
}

function SmallStoryTrending({
  story,
  onClick,
  onBookmark,
  isBookmarked,
  theme,
  getTopicImage,
  currentLanguage,
  getTopicNames,
}: {
  story: TrendingNews;
  onClick: (id: string) => void;
  onBookmark: (id: string, event: React.MouseEvent) => void;
  isBookmarked: boolean;
  theme: string;
  getTopicImage: (topics: string[]) => string;
  currentLanguage: string;
  getTopicNames: (topicIds: string[]) => string[];
}) {
  const title = currentLanguage === 'am' ? story.title_am : story.title_en;
  const summary = currentLanguage === 'am' ? story.summary_am : story.summary_en;
  const topicNames = getTopicNames(story.topics);
  
  return (
    <div
      className={`py-4 cursor-pointer rounded-md px-2 transition-colors ${
        theme === "dark" ? "hover:bg-gray-800" : "hover:bg-gray-50"
      }`}
      onClick={() => onClick(story.id)}
    >
      <div className="flex items-center justify-between mb-1">
        <div className="flex items-center gap-2 flex-wrap">
          {topicNames.map((topicName, i) => (
            <TopicTag key={i} text={topicName} theme={theme} />
          ))}
          <p
            className={`text-[11px] ${
              theme === "dark" ? "text-gray-400" : "text-gray-500"
            }`}
          >
            {new Date(story.published_at).toLocaleDateString()}
          </p>
        </div>
        <button
          onClick={(e) => onBookmark(story.id, e)}
          className={`p-1 rounded-full transition-colors ${
            isBookmarked 
              ? "text-yellow-500 hover:text-yellow-600" 
              : theme === "dark" 
                ? "text-gray-400 hover:text-yellow-500" 
                : "text-gray-500 hover:text-yellow-500"
          }`}
        >
          <svg className="w-4 h-4" fill={isBookmarked ? "currentColor" : "none"} stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z" />
          </svg>
        </button>
      </div>
      <h3
        className={`text-sm font-semibold mb-1 ${
          theme === "dark" ? "text-gray-100" : ""
        }`}
      >
        {title}
      </h3>
      <p
        className={`text-xs line-clamp-2 ${
          theme === "dark" ? "text-gray-300" : "text-gray-600"
        }`}
      >
        {summary}
      </p>
    </div>
  );
}

export function NewsGridNew({
  title,
  data,
  onClick,
  onBookmark,
  bookmarkedNews,
  theme,
  getTopicNames,
  getTopicImage,
  currentLanguage,
}: {
  title: string;
  data: TrendingNews[] | null;
  onClick: (id: string) => void;
  onBookmark: (id: string, event: React.MouseEvent) => void;
  bookmarkedNews: Set<string>;
  theme: string;
  getTopicNames: (topicIds: string[]) => string[];
  getTopicImage: (topics: string[]) => string;
  currentLanguage: string;
}) {
  return (
    <>
      <SectionHeader title={title} theme={theme} />
      <div
        className={`grid md:grid-cols-2 lg:grid-cols-3 gap-6 border-b pb-8 ${
          theme === "dark" ? "border-gray-700" : "border-gray-200"
        }`}
      >
        <div className="md:col-span-2 lg:col-span-1">
          <FeaturedStoryNew 
            news={data?.[0]} 
            onClick={onClick} 
            onBookmark={onBookmark}
            isBookmarked={bookmarkedNews.has(data?.[0]?.id || '')}
            theme={theme} 
            getTopicNames={getTopicNames}
            getTopicImage={getTopicImage}
            currentLanguage={currentLanguage}
          />
        </div>
        <div
          className={`flex flex-col divide-y ${
            theme === "dark" ? "divide-gray-700" : "divide-gray-200"
          }`}
        >
          {data?.slice(1, 4).map((story) => (
            <SmallStoryTrending
              key={story.id}
              story={story}
              onClick={onClick}
              onBookmark={onBookmark}
              isBookmarked={bookmarkedNews.has(story.id)}
              theme={theme}
              getTopicNames={getTopicNames}
              getTopicImage={getTopicImage}
              currentLanguage={currentLanguage}
            />
          ))}
        </div>
        <div
          className={`flex flex-col divide-y ${
            theme === "dark" ? "divide-gray-700" : "divide-gray-200"
          }`}
        >
          {data?.slice(4, 7).map((story) => (
            <SmallStoryTrending
              key={story.id}
              story={story}
              onClick={onClick}
              onBookmark={onBookmark}
              isBookmarked={bookmarkedNews.has(story.id)}
              theme={theme}
              getTopicNames={getTopicNames}
              getTopicImage={getTopicImage}
              currentLanguage={currentLanguage}
            />
          ))}
        </div>
      </div>
    </>
  );
}
