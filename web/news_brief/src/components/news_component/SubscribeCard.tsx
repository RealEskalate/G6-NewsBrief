"use client";

import { useState, useEffect, useContext } from "react";
import { useRouter } from "next/navigation";
import { Bookmark, BookmarkCheck } from "lucide-react";
import { ThemeContext } from "@/app/contexts/ThemeContext";
import { apiClient, Topic } from "../../lib/api";
import {News} from "../../lib/api";
import { useTranslation } from "react-i18next";

function TopicTag({ text, theme }: { text: string; theme: string }) {
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

function SectionHeader({ title, theme }: { title: string; theme: string }) {
  return (
    <div className="flex items-center justify-between mb-6">
      <h2 className="text-xl font-bold tracking-tight flex items-center gap-2">
        <span className="w-1.5 h-6 bg-blue-600 rounded-full"></span>
        {title}
      </h2>
      <button
        className={`text-xs ${
          theme === "dark" ? "text-gray-200" : "text-blue-600"
        } hover:underline`}
      >
        View All
      </button>
    </div>
  );
}

export default function SubscribedNews() {
  const [news, setNews] = useState<News[]>([]);
  const [topics, setTopics] = useState<Topic[]>([]);
  const [loading, setLoading] = useState(true);
  const [errorMessage, setErrorMessage] = useState("");
  const router = useRouter();
  const context = useContext(ThemeContext);
  const theme = context?.theme || "light";
  const { i18n } = useTranslation();

  // Fetch subscribed news
  useEffect(() => {
    const fetchSubscribedNews = async () => {
      try {
        setLoading(true);
        const [subscribedNews, topicsData] = await Promise.all([
          apiClient.getSubscribedNews(),
          apiClient.getTopics()
        ]);
        setNews(subscribedNews);
        setTopics(topicsData);
      } catch (err: unknown) {
        setErrorMessage(
          err instanceof Error ? err.message : "Failed to fetch subscribed news"
        );
      } finally {
        setLoading(false);
      }
    };

    fetchSubscribedNews();
  }, []);

  // Helper function to convert topic IDs to topic names
  const getTopicNames = (topicIds: string[]): string[] => {
    return topicIds.map(id => {
      const topic = topics.find(t => t.id === id);
      return topic ? (i18n.language === 'am' ? topic.label.am : topic.label.en) : id;
    });
  };

  // Handle news click
  const handleNewsClick = (newsId: string) => {
    router.push(`/news/${newsId}`);
  };

  // Handle save/unsave click
  const handleSaveClick = async (e: React.MouseEvent, newsId: string) => {
    e.stopPropagation();
    try {
      // Check if already saved
      const user = await apiClient.getUser();
      const isSaved = user.saved_news.includes(newsId);
      
      if (isSaved) {
        await apiClient.removeSavedNewsItem(newsId);
      } else {
        await apiClient.saveNewsItem(newsId);
      }
      
      // Refresh the news list to update save status
      const subscribedNews = await apiClient.getSubscribedNews();
      setNews(subscribedNews);
    } catch (err) {
      console.error("Failed to toggle save:", err);
      setErrorMessage("Failed to save article");
    }
  };

  // Check if news is saved
  const isNewsSaved = async (newsId: string): Promise<boolean> => {
    try {
      const user = await apiClient.getUser();
      return user.saved_news.includes(newsId);
    } catch (err) {
      console.error("Failed to check save status:", err);
      return false;
    }
  };

  // Loading state
  if (loading) {
    return (
      <div className="p-4 text-center">
        <p className={theme === "dark" ? "text-gray-400" : "text-gray-600"}>
          Loading subscribed news...
        </p>
      </div>
    );
  }

  // Error state
  if (errorMessage) {
    return (
      <div className="p-4 text-center">
        <p className="text-red-500">{errorMessage}</p>
      </div>
    );
  }

  // Empty state
  if (news.length === 0) {
    return (
      <div className="p-4 text-center">
        <p className={theme === "dark" ? "text-gray-400" : "text-gray-600"}>
          No subscribed news yet. Subscribe to sources to see their content here.
        </p>
      </div>
    );
  }

  // Trending Card Component (inside SubscribedNews)
  const TrendingCard = ({ story }: { story: News }) => {
    const [isSaved, setIsSaved] = useState(false);

    useEffect(() => {
      const checkSavedStatus = async () => {
        const saved = await isNewsSaved(story.id);
        setIsSaved(saved);
      };
      checkSavedStatus();
    }, [story.id]);

    return (
      <div className="relative">
        <div
          className={`cursor-pointer group rounded-lg overflow-hidden transition-shadow hover:shadow-md flex flex-col md:flex-row md:items-start gap-3`}
          onClick={() => handleNewsClick(story.id)}
        >
          {/* Image */}
          <div className="md:w-1/3 overflow-hidden">
            <img
              src={story.image_url}
              alt={story.title}
              className="w-full h-28 md:h-full object-cover rounded-lg transition-transform duration-300 group-hover:scale-105"
            />
          </div>
          
          {/* Content */}
          <div className="md:w-2/3 mt-2 md:mt-0 pl-2 pb-1">
            <div className="flex items-center gap-2 mb-1 flex-wrap">
              {getTopicNames(story.topics).map((topicName, i) => (
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
            <div className="mt-2">
              <span className={`text-xs ${theme === "dark" ? "text-gray-400" : "text-gray-500"}`}>
                Source: {story.source}
              </span>
            </div>
          </div>

          {/* Save/Unsave Icon */}
          <button
            onClick={(e) => handleSaveClick(e, story.id)}
            className="absolute bottom-2 right-2 p-1.5 rounded-full bg-black/70 text-white hover:bg-black/90 transition-colors"
          >
            {isSaved ? <BookmarkCheck size={16} /> : <Bookmark size={16} />}
          </button>
        </div>
      </div>
    );
  };

  // Main content
  return (
    <div className="p-4">
      <SectionHeader title="Subscribed News" theme={theme} />
      <div
        className={`overflow-x-auto scrollbar-hide -mx-4 px-4 border-b pb-10 ${
          theme === "dark" ? "border-gray-700" : "border-gray-200"
        }`}
      >
        <div className="flex gap-6 min-w-max">
          {news.slice(0, 6).map((item) => (
            <div key={item.id} className="w-64 md:w-80 flex-shrink-0">
              <TrendingCard story={item} />
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}