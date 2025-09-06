'use client';
import { apiClient, TrendingNews, Topic } from "@/lib/api";
import { useContext, useEffect, useState } from "react";
import Button from "../reusable_components/Button";
import { Bookmark } from "lucide-react";
import { ThemeContext } from "@/app/contexts/ThemeContext";
import { useTranslation } from "react-i18next";
import { useRouter } from "next/navigation";


export default function ForyouComponent() {
  const [news, setNews] = useState<TrendingNews[] | null>(null);
  const [topics, setTopics] = useState<Topic[]>([]);
  const [loading, setLoading] = useState(true);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);
  const [isFallback, setIsFallback] = useState(false);
  const [bookmarkedNews, setBookmarkedNews] = useState<Set<string>>(new Set());
  const router = useRouter();

  const context = useContext(ThemeContext);
  if (!context)
    throw new Error("ToggleButton must be used inside ThemeProvider");
  const { theme } = context;
  const { i18n } = useTranslation();

  useEffect(() => {
    const getInformation = async () => {
      try {
        setLoading(true);
        const [forYouData, topicsData, bookmarksData] = await Promise.all([
          apiClient.getForYouFeed(1, 20), // Get first 20 items
          apiClient.getTopics(),
          apiClient.getBookmarks() // Initialize bookmarks
        ]);
        
        // Initialize bookmarked news
        const bookmarkedIds = new Set(bookmarksData.news.map((news: TrendingNews) => news.id));
        setBookmarkedNews(bookmarkedIds);
        
        // If personalized feed is empty, get trending and today's news as fallback
        if (forYouData.news.length === 0) {
          console.log("Personalized feed is empty, fetching trending and today's news as fallback");
          setIsFallback(true);
          const [trendingData, todayData] = await Promise.all([
            apiClient.getTrendingNews(1, 10), // Get 10 trending news
            apiClient.getTodaysNews() // Get today's news
          ]);
          
          // Combine trending and today's news, removing duplicates
          const combinedNews = [...trendingData.news, ...todayData.map(news => ({
            ...news,
            is_bookmarked: news.is_bookmarked ?? false
          }))];
          const uniqueNews = combinedNews.filter((news, index, self) => 
            index === self.findIndex(n => n.id === news.id)
          );
          
          setNews(uniqueNews.slice(0, 20)); // Limit to 20 items
        } else {
          setIsFallback(false);
          setNews(forYouData.news);
        }
        
        setTopics(topicsData);
        console.log("For You component - Topics loaded:", topicsData.length);
        console.log("For You component - News loaded:", news?.length || 0);
      } catch (err: unknown) {
        console.error("Error in For You component:", err);
        if (err instanceof Error) setErrorMessage(err.message);
        else setErrorMessage("Failed to fetch news");
      } finally {
        setLoading(false);
      }
    };
    getInformation();
  }, []);

  // Helper function to convert topic IDs to topic names
  const getTopicNames = (topicIds: string[] | undefined): string[] => {
    if (!topicIds || !Array.isArray(topicIds) || topicIds.length === 0) {
      console.log("getTopicNames: No topics provided, returning General");
      return ["General"];
    }
    
    console.log("getTopicNames: Processing topics:", topicIds);
    return topicIds.map(id => {
      const topic = topics.find(t => t.id === id);
      return topic ? (i18n.language === 'am' ? topic.label.am : topic.label.en) : id;
    });
  };

  // Helper function to get topic-based image
  const getTopicImage = (topics: string[] | undefined) => {
    if (!topics || !Array.isArray(topics) || topics.length === 0) {
      // Use random image from other folder (1-10)
      const randomImage = Math.floor(Math.random() * 10) + 1;
      return `/images/other/${randomImage}.jpg`;
    }

    const topicNames = getTopicNames(topics);
    const primaryTopic = topicNames[0]?.toLowerCase();
    
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
    const randomImage = Math.floor(Math.random() * 10) + 1;
    const imagePath = `/images/${imageFolder}/${randomImage}.jpg`;
    
    return imagePath;
  };

  // Handle news click navigation
  const handleNewsClick = (newsId: string) => {
    router.push(`/news/${newsId}`);
  };

  // Handle bookmark toggle
  const handleBookmark = async (newsId: string, event: React.MouseEvent) => {
    event.stopPropagation();
    try {
      if (bookmarkedNews.has(newsId)) {
        console.log("Removing bookmark for:", newsId);
        await apiClient.removeBookmark(newsId);
        setBookmarkedNews(prev => {
          const newSet = new Set(prev);
          newSet.delete(newsId);
          console.log("Updated bookmarked news after removal:", Array.from(newSet));
          return newSet;
        });
      } else {
        console.log("Adding bookmark for:", newsId);
        try {
          await apiClient.saveBookmark(newsId);
          setBookmarkedNews(prev => {
            const newSet = new Set(prev).add(newsId);
            console.log("Updated bookmarked news after addition:", Array.from(newSet));
            return newSet;
          });
        } catch (error: unknown) {
          if (error instanceof Error && (error.message?.includes('409') || error.message?.includes('already bookmarked'))) {
            console.log("Item was already bookmarked, updating local state for:", newsId);
            setBookmarkedNews(prev => {
              const newSet = new Set(prev).add(newsId);
              console.log("Updated bookmarked news after 409 handling:", Array.from(newSet));
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

  if (loading) return (
    <div className={`${theme === "light" ? "bg-white text-black" : "bg-gray-900 text-white"} w-full p-4`}>
      <p className="text-center">Loading news ...</p>
    </div>
  );
  
  if (errorMessage) return (
    <div className={`${theme === "light" ? "bg-white text-black" : "bg-gray-900 text-white"} w-full p-4`}>
      <p className="text-center text-red-500">Error: {errorMessage}</p>
    </div>
  );

  return (
    <div className={`${theme === "light" ? "bg-white text-black" : "bg-gray-900 text-white"} w-full`}>
      <h1 className="my-5 font-bold text-xl">
        {isFallback 
          ? (i18n.language === 'am' ? 'ዛሬ የተወደዱ ዜናዎች' : 'Trending & Today\'s News')
          : (i18n.language === 'am' ? 'ለእርስዎ' : 'For You')
        }
      </h1>
      {isFallback && (
        <p className="text-sm text-gray-500 mb-4">
          {i18n.language === 'am' 
            ? 'የተለየ ዜና አልተገኘም፣ ዛሬ የተወደዱ ዜናዎችን እናሳያለን።' 
            : 'No personalized content found, showing trending and today\'s news.'
          }
        </p>
      )}

      <div className="space-y-4">
        {news?.map((item, index) => (
          <div
            key={index}
            className="flex flex-col lg:flex-row gap-5 rounded-lg border shadow-sm my-2 border-[#E6E6E6] w-full overflow-hidden cursor-pointer hover:shadow-md transition-shadow"
            onClick={() => handleNewsClick(item.id)}
          >
            <img
              src={getTopicImage(item.topics)}
              className="w-full lg:w-[20%] h-48 lg:h-auto object-cover rounded-t-lg lg:rounded-tl-lg lg:rounded-bl-lg lg:rounded-t-none"
              alt={i18n.language === 'am' ? item.title_am || item.title : item.title_en || item.title}
            />
            <div className="p-4 flex-1 min-w-0">
              <div className="flex flex-col sm:flex-row sm:justify-between gap-2 sm:gap-0">
                <div className="flex flex-wrap gap-2">
                  {getTopicNames(item.topics).map((topicName, idx) => (
                    <Button
                      key={idx}
                      variant="tertiary"
                      className="rounded-full px-4 py-1 text-sm flex-shrink-0"
                    >
                      {topicName}
                    </Button>
                  ))}
                </div>
                <p className="text-gray-400 my-2 text-sm">{item.published_at}</p>
              </div>

              <div className="mt-2">
                <p className="font-bold text-lg my-2">
                  {i18n.language === 'am' ? item.title_am || item.title : item.title_en || item.title}
                </p>
                <p className="my-2 font-light">
                  {i18n.language === 'am' 
                    ? item.summary_am || item.body_am || item.body 
                    : item.summary_en || item.body_en || item.body
                  }
                </p>
              </div>

              <div className="flex gap-2 my-2">
                <Button 
                  variant="tertiary" 
                  className={`rounded-full p-2 ${bookmarkedNews.has(item.id) ? 'text-blue-600' : 'text-gray-400'}`}
                  onClick={(e) => handleBookmark(item.id, e)}
                >
                  <Bookmark className={`w-4 h-4 ${bookmarkedNews.has(item.id) ? 'fill-current' : ''}`} />
                </Button>
              </div>

              <p className="text-sm text-gray-400">Source: {item.source_id}</p>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
