"use client";

import { apiClient, TodayNews, Topic, TrendingNews, getAccessToken } from "@/lib/api";
import { useContext, useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { ThemeContext } from "@/app/contexts/ThemeContext";
import { useTranslation } from "react-i18next";
import { SectionHeader, FeaturedTodayNew, TrendingCardNew, NewsGridNew } from "@/components/news_component/NewsComponent";

export default function NewsComponent() {
  const [todaysNews, setTodaysNews] = useState<TodayNews[]>([]);
  const [trendingNews, setTrendingNews] = useState<TrendingNews[]>([]);
  const [subscribedTopic1News, setSubscribedTopic1News] = useState<TrendingNews[]>([]);
  const [subscribedTopic2News, setSubscribedTopic2News] = useState<TrendingNews[]>([]);
  const [topics, setTopics] = useState<Topic[]>([]);
  const [userTopics, setUserTopics] = useState<string[]>([]);
  const [loading, setLoading] = useState(true);
  const [bookmarkedNews, setBookmarkedNews] = useState<Set<string>>(new Set());
  const [errorMessage, setErrorMessage] = useState<string | null>(null);
  const router = useRouter();
  const context = useContext(ThemeContext);

  if (!context) throw new Error("NewsComponent must be used inside ThemeProvider");
  const { theme } = context;
  const { i18n } = useTranslation();

  useEffect(() => {
    (async () => {
      try {
        setLoading(true);
        const [todaysData, trendingData, topicsData, userData] = await Promise.all([
          apiClient.getTodaysNews(),
          apiClient.getTrendingNews(1, 6),
          apiClient.getTopics(),
          apiClient.getUser(),
        ]);

        setTodaysNews(todaysData || []);
        setTrendingNews(trendingData?.news || []);
        setTopics(topicsData || []);

        let userTopicIds: string[] = [];

        if (userData?.topic_interest?.length) {
          userTopicIds = userData.topic_interest;
        } else {
          try {
            const personData = localStorage.getItem("person");
            if (personData) {
              const parsed = JSON.parse(personData);
              userTopicIds = parsed.user?.preferences?.topics || [];
            }
          } catch (error) {
            console.error("Error reading localStorage:", error);
          }
        }

        if (userTopicIds.length >= topicsData.length * 0.8 || userTopicIds.length === 0) {
          userTopicIds = topicsData.map(t => t.id);
        }

        setUserTopics(userTopicIds);

        let topic1Data: TrendingNews[] = [];
        let topic2Data: TrendingNews[] = [];

        try {
          const topicPromises: Promise<{ news: TrendingNews[] }>[] = [];

          if (userTopicIds.length > 0) {
            topicPromises.push(
              apiClient.getTopicNews(userTopicIds[0], 1, 6).then(res => res || { news: [] })
            );
            topicPromises.push(
              apiClient.getTopicNews(userTopicIds[1] || userTopicIds[0], 1, 6).then(res => res || { news: [] })
            );
          } else {
            topicPromises.push(apiClient.getTopicNews(topicsData[0]?.id || "", 1, 6).then(res => res || { news: [] }));
            topicPromises.push(apiClient.getTopicNews(topicsData[1]?.id || "", 1, 6).then(res => res || { news: [] }));
          }

          const [t1, t2] = await Promise.all(topicPromises);
          topic1Data = t1.news || [];
          topic2Data = t2.news || [];
        } catch (topicError) {
          console.error("Error fetching topic news:", topicError);
        }

        setSubscribedTopic1News(topic1Data);
        setSubscribedTopic2News(topic2Data);

      } catch (err: unknown) {
        setErrorMessage(err instanceof Error ? err.message : "Failed to fetch news");
      } finally {
        setLoading(false);
      }
    })();

    const initializeBookmarks = async () => {
      try {
        const bookmarksData = await apiClient.getBookmarks();
        const bookmarkedIds = bookmarksData.news?.map(n => n.id) || [];
        setBookmarkedNews(new Set(bookmarkedIds));
      } catch (error) {
        console.error("Error initializing bookmarks:", error);
        setBookmarkedNews(new Set());
      }
    };

    initializeBookmarks();
  }, []);

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
        await apiClient.removeBookmark(newsId);
        setBookmarkedNews(prev => {
          const newSet = new Set(prev);
          newSet.delete(newsId);
          return newSet;
        });
      } else {
        await apiClient.saveBookmark(newsId);
        setBookmarkedNews(prev => new Set(prev).add(newsId));
      }
    } catch (error: unknown) {
      console.error("Error toggling bookmark:", error);
    }
  };

  const getTopicNames = (topicIds: string[]): string[] => {
    if (!topicIds?.length || !topics?.length) return ["News"];
    return topicIds.map(id => {
      const topic = topics.find(t => t.id === id);
      return topic ? (i18n.language === 'am' ? topic.label.am : topic.label.en) : "General";
    });
  };

  const getTopicImage = (topicIds: string[]) => {
    const primaryTopic = getTopicNames(topicIds)[0]?.toLowerCase() || 'general';
    const topicMap: { [key: string]: string } = {
      technology: "technology",
      tech: "technology",
      health: "health",
      sports: "sports",
      environment: "environment",
      climate: "environment",
      science: "environment",
      business: "technology",
      politics: "other",
      arts: "other",
      entertainment: "other",
      education: "health",
      agriculture: "environment",
      travel: "other",
      general: "other",
      news: "other",
    };
    const folder = topicMap[primaryTopic] || "other";
    const rand = Math.floor(Math.random() * 6) + 1;
    return `/images/${folder}/${rand}.jpg`;
  };

  if (loading) return <p>Loading...</p>;
  if (errorMessage) return <p>Error: {errorMessage}</p>;

  return (
    <div className={`w-full max-w-7xl mx-auto space-y-12 px-4`}>
      {/* Today Section */}
      <SectionHeader title={i18n.language === 'am' ? 'ዛሬ' : 'Today'} theme={theme} />
      {todaysNews.length > 0 && (
        <FeaturedTodayNew
          news={todaysNews[0]}
          onClick={handleNewsClick}
          onBookmark={handleBookmark}
          isBookmarked={bookmarkedNews.has(todaysNews[0].id)}
          theme={theme}
          getTopicImage={getTopicImage}
          getTopicNames={getTopicNames}
          currentLanguage={i18n.language}
        />
      )}

      {/* Trending Section */}
      {trendingNews.length > 0 && trendingNews.map(item => (
        <TrendingCardNew
          key={item.id}
          story={item}
          onClick={handleNewsClick}
          onBookmark={handleBookmark}
          isBookmarked={bookmarkedNews.has(item.id)}
          theme={theme}
          getTopicImage={getTopicImage}
          getTopicNames={getTopicNames}
          currentLanguage={i18n.language}
        />
      ))}

      {/* Subscribed Topic Sections */}
      {subscribedTopic1News.length > 0 && (
        <NewsGridNew
          title={getTopicNames([userTopics[0]])[0]}
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

      {subscribedTopic2News.length > 0 && (
        <NewsGridNew
          title={getTopicNames([userTopics[1]])[0]}
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
