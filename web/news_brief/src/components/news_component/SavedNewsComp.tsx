"use client";

import { useContext, useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { apiClient, TrendingNews, Topic } from "@/lib/api";
import { useTranslation } from "react-i18next";
import { ThemeContext } from "@/app/contexts/ThemeContext";
import { BookmarkMinus } from "lucide-react";
import { TopicTag } from "@/components/news_component/NewsComponent";

export default function SavedNewsComp() {
  const [savedNews, setSavedNews] = useState<TrendingNews[]>([]);
  const [topics, setTopics] = useState<Topic[]>([]);
  const [loading, setLoading] = useState(true);
  const router = useRouter();
  const context = useContext(ThemeContext);
  const { i18n } = useTranslation();

  if (!context) throw new Error("SavedNews must be used inside ThemeProvider");
  const { theme } = context;

  useEffect(() => {
    async function fetchSaved() {
      try {
        const [bookmarksData, topicsData] = await Promise.all([
          apiClient.getBookmarks(),
          apiClient.getTopics()
        ]);
        setSavedNews(bookmarksData.news);
        setTopics(topicsData);
      } finally {
        setLoading(false);
      }
    }
    fetchSaved();
  }, []);

  const handleUnsave = async (id: string) => {
    try {
      await apiClient.removeBookmark(id);
      setSavedNews((prev) => prev.filter((n) => n.id !== id));
    } catch (error) {
      console.error("Error removing bookmark:", error);
    }
  };

  const handleClick = (id: string) => {
    router.push(`/news/${id}`);
  };

  // Helper function to convert topic IDs to topic names
  const getTopicNames = (topicIds: string[] | undefined): string[] => {
    if (!topicIds || !Array.isArray(topicIds) || topicIds.length === 0) {
      return ["General"];
    }
    
    return topicIds.map(id => {
      const topic = topics.find(t => t.id === id);
      return topic ? (i18n.language === 'am' ? topic.label.am : topic.label.en) : id;
    });
  };

  return (
    <div className="max-w-7xl mx-auto px-4 py-8">
      <h1
        className={`text-2xl font-bold mb-6 ${
          theme === "dark" ? "text-white" : "text-gray-900"
        }`}
      >
        {i18n.language === 'am' ? 'የተቀመጡ ዜናዎች' : 'Saved News'}
      </h1>

      {loading ? (
        <p className="text-center text-gray-500">Loading...</p>
      ) : savedNews.length === 0 ? (
        <p className="text-center text-gray-400 text-lg">
          {i18n.language === 'am' ? 'ምንም የተቀመጡ ዜናዎች የሉም' : 'No Saved News'}
        </p>
      ) : (
        <div className="grid gap-6">
          {savedNews.map((news) => (
            <SavedNewsCard
              key={news.id}
              news={news}
              onClick={handleClick}
              onUnsave={handleUnsave}
              theme={theme}
              getTopicNames={getTopicNames}
              currentLanguage={i18n.language}
            />
          ))}
        </div>
      )}
    </div>
  );
}



export function SavedNewsCard({
  news,
  onClick,
  onUnsave,
  theme,
  getTopicNames,
  currentLanguage,
}: {
  news: TrendingNews;
  onClick: (id: string) => void;
  onUnsave: (id: string) => void;
  theme: string;
  getTopicNames: (topicIds: string[] | undefined) => string[];
  currentLanguage: string;
}) {
  return (
    <div
      className={`group flex flex-col sm:flex-row gap-4 p-4 rounded-lg border transition hover:shadow-md cursor-pointer
        ${theme === "dark" ? "bg-gray-800 border-gray-700" : "bg-gray-50 border-gray-200"}`}
      onClick={() => onClick(news.id)}
    >
      {/* Image */}
      <div className="relative overflow-hidden rounded-lg w-full sm:w-1/3">
        <img
          src={`/images/other/${Math.floor(Math.random() * 10) + 1}.jpg`}
          alt={currentLanguage === 'am' ? news.title_am || news.title : news.title_en || news.title}
          className="w-full h-full object-cover aspect-[4/3] sm:aspect-auto transition-transform duration-300 group-hover:scale-105"
        />
      </div>

      {/* Caption */}
      <div className="relative flex flex-col p-3.5 w-full sm:w-2/3">
        {/* Tags + timestamp */}
        <div className="flex items-center gap-2 mb-2 flex-wrap">
          {getTopicNames(news.topics).map((topicName, i) => (
            <TopicTag key={i} text={topicName} theme={theme} />
          ))}
          <span
            className={`text-[11px] ${
              theme === "dark" ? "text-gray-400" : "text-gray-500"
            }`}
          >
            {news.published_at}
          </span>
        </div>

        {/* Title */}
        <h2
          className={`text-lg font-bold mb-1 ${
            theme === "dark"
              ? "text-gray-100 hover:text-blue-400"
              : "text-gray-900 hover:text-blue-600"
          }`}
        >
          {currentLanguage === 'am' ? news.title_am || news.title : news.title_en || news.title}
        </h2>

        {/* Description */}
        <p
          className={`text-sm line-clamp-2 ${
            theme === "dark" ? "text-gray-300" : "text-gray-600"
          }`}
        >
          {currentLanguage === 'am' 
            ? news.summary_am || news.body_am || news.body 
            : news.summary_en || news.body_en || news.body
          }
        </p>

        {/* Unsave button */}
        <button
          onClick={(e) => {
            e.stopPropagation();
            onUnsave(news.id);
          }}
          className="absolute top-0 right-0 p-1 rounded-md cursor-pointer"
          aria-label="Unsave"
          title="Unsave"
        >
          <BookmarkMinus
            size={20}
            className={`${
              theme === "dark"
                ? "text-red-400 hover:text-red-300"
                : "text-red-600 hover:text-red-700"
            }`}
          />
        </button>
      </div>
    </div>
  );
}