"use client";

import { useState, useEffect, useContext } from "react";
import { useRouter } from "next/navigation";
import { BookmarkCheck } from "lucide-react";
import { ThemeContext } from "@/app/contexts/ThemeContext";
import { apiClient, Topic } from "../../lib/api";
import { useTranslation } from "react-i18next";

interface News {
  id: string;
  title: string;
  description: string;
  topics: string[];
  source: string;
  posted_at: string;
  image_url: string;
}

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

export default function SavedNewsCard() {
  const [news, setNews] = useState<News[]>([]);
  const [topics, setTopics] = useState<Topic[]>([]);
  const [loading, setLoading] = useState(true);
  const [errorMessage, setErrorMessage] = useState("");
  const [showUnsavePrompt, setShowUnsavePrompt] = useState(false);
  const [selectedNewsId, setSelectedNewsId] = useState<string | null>(null);
  const router = useRouter();
  const context = useContext(ThemeContext);
  const theme = context?.theme || "light";
  const { i18n } = useTranslation();

  // Fetch saved news
  useEffect(() => {
    const fetchSavedNews = async () => {
      try {
        setLoading(true);
        const [savedNews, topicsData] = await Promise.all([
          apiClient.getSavedNews(),
          apiClient.getTopics()
        ]);
        setNews(savedNews);
        setTopics(topicsData);
      } catch (err: unknown) {
        setErrorMessage(
          err instanceof Error ? err.message : "Failed to fetch saved news"
        );
      } finally {
        setLoading(false);
      }
    };

    fetchSavedNews();
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

  // Handle unsave click
  const handleUnsaveClick = (e: React.MouseEvent, newsId: string) => {
    e.stopPropagation();
    setSelectedNewsId(newsId);
    setShowUnsavePrompt(true);
  };

  // Confirm unsave
  const confirmUnsave = async (e: React.MouseEvent) => {
    e.stopPropagation();
    if (selectedNewsId) {
      try {
        await apiClient.removeSavedNewsItem(selectedNewsId);
        setNews(prev => prev.filter(item => item.id !== selectedNewsId));
      } catch (err) {
        console.error("Failed to unsave news:", err);
        setErrorMessage("Failed to unsave article");
      }
    }
    setShowUnsavePrompt(false);
    setSelectedNewsId(null);
  };

  // Cancel unsave
  const cancelUnsave = (e: React.MouseEvent) => {
    e.stopPropagation();
    setShowUnsavePrompt(false);
    setSelectedNewsId(null);
  };

  // Loading state
  if (loading) {
    return (
      <div className="p-4 text-center">
        <p className={theme === "dark" ? "text-gray-400" : "text-gray-600"}>
          Loading saved news...
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
          No saved articles yet.
        </p>
      </div>
    );
  }

  // Trending Card Component (inside SavedNews)
  const TrendingCard = ({ story }: { story: News }) => {
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
          </div>

          {/* Save/Unsave Icon */}
          <button
            onClick={(e) => handleUnsaveClick(e, story.id)}
            className="absolute bottom-2 right-2 p-1.5 rounded-full bg-black/70 text-white hover:bg-black/90 transition-colors"
          >
            <BookmarkCheck size={16} />
          </button>
        </div>
      </div>
    );
  };

  // Main content
  return (
    <div className="p-4">
      <SectionHeader title="Saved News" theme={theme} />
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

      {/* Unsave Prompt */}
      {showUnsavePrompt && (
        <div 
          className="fixed inset-0 bg-black/50 flex items-center justify-center z-50"
          onClick={(e) => {
            e.stopPropagation();
            setShowUnsavePrompt(false);
            setSelectedNewsId(null);
          }}
        >
          <div 
            className={`w-80 p-6 rounded-xl ${
              theme === "dark" ? "bg-gray-800" : "bg-white"
            }`}
            onClick={(e) => e.stopPropagation()}
          >
            <h3 className={`text-lg font-semibold mb-3 ${
              theme === "dark" ? "text-white" : "text-black"
            }`}>
              Unsave Article?
            </h3>
            <p className={`text-sm mb-4 ${
              theme === "dark" ? "text-gray-300" : "text-gray-600"
            }`}>
              Are you sure you want to remove this article from your saved items?
            </p>
            <div className="flex gap-3 justify-end">
              <button
                onClick={cancelUnsave}
                className={`px-4 py-2 rounded-lg text-sm ${
                  theme === "dark" 
                    ? "bg-gray-700 text-white hover:bg-gray-600" 
                    : "bg-gray-200 text-black hover:bg-gray-300"
                }`}
              >
                Cancel
              </button>
              <button
                onClick={confirmUnsave}
                className="px-4 py-2 rounded-lg bg-red-600 text-white text-sm hover:bg-red-700"
              >
                Unsave
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}