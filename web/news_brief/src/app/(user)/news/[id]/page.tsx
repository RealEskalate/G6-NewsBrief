"use client";

import { useEffect, useState, useContext, useRef } from "react";
import { useParams } from "next/navigation";
import ChatBot from "../../../../components/reusable_components/Specficchatbot";
import { ThemeContext } from "../../../contexts/ThemeContext";
import TopBar from "@/components/reusable_components/search_topbar";
import { TopicTag } from "@/components/news_component/NewsComponent";
import { apiClient, TrendingNews, Topic } from "@/lib/api";

type News = TrendingNews;

type SimpleVoice = { voice_id: string; name: string };

export default function NewsDetailPage() {
  const params = useParams();
  const { theme } = useContext(ThemeContext)!;

  const [news, setNews] = useState<News | null>(null);
  const [loading, setLoading] = useState(true);
  const [topics, setTopics] = useState<Topic[]>([]);

  // --- Language toggle ---
  const [showAmharic, setShowAmharic] = useState(false);

  // --- Eleven Labs TTS ---
  const [isPlaying, setIsPlaying] = useState(false);
  const [audioUrl, setAudioUrl] = useState<string | null>(null);
  const [voices, setVoices] = useState<SimpleVoice[]>([]);
  const [selectedVoice, setSelectedVoice] = useState("ZF6FPAbjXT4488VcRRnw");
  const [selectedLanguage, setSelectedLanguage] = useState("en"); // en or am
  const audioRef = useRef<HTMLAudioElement | null>(null);
  const lastRequestRef = useRef<{
    voiceId: string;
    text: string;
    lang: string;
  } | null>(null);

  // Fetch voices
  useEffect(() => {
    async function fetchVoices() {
      try {
        const res = await fetch("/api/voices", { cache: "no-store" });
        const data = await res.json();
        if (Array.isArray(data.voices) && data.voices.length > 0) {
          setVoices(data.voices);
          setSelectedVoice(data.voices[0].voice_id);
          return;
        }
      } catch {
        setVoices([
          { voice_id: "ZF6FPAbjXT4488VcRRnw", name: "Default Voice" },
          { voice_id: "pNInz6obpgDQGcFmaJgB", name: "Rachel" },
          { voice_id: "EXAVITQu4vr4xnSDxMaL", name: "Domi" },
        ]);
      }
    }
    fetchVoices();
  }, []);

  // Fetch news and topics
  useEffect(() => {
    async function fetchData() {
      try {
        if (!params.id) return;

        const [newsData, topicsData] = await Promise.all([
          apiClient.getNewsById(params.id as string),
          apiClient.getTopics()
        ]);

        setNews(newsData);
        setTopics(topicsData);
      } catch (error) {
        console.error("Failed to fetch news:", error);
      } finally {
        setLoading(false);
      }
    }
    fetchData();
  }, [params.id]);

  // Reset audio helper
  const resetAudio = () => {
    if (audioRef.current) {
      audioRef.current.pause();
      audioRef.current = null;
    }
    if (audioUrl) {
      URL.revokeObjectURL(audioUrl);
      setAudioUrl(null);
    }
    setIsPlaying(false);
    lastRequestRef.current = null;
  };

  const handlePlayElevenLabs = async () => {
    if (!news) return;

    // Use Amharic or English text - prioritize body over summary
    const text = showAmharic
      ? news.body_am || news.summary_am || ""
      : news.body_en || news.body || news.summary_en || "";

    // Always use "en" (ElevenLabs doesn't support "am")
    const lang = "en";

    const sameAsLast =
      lastRequestRef.current &&
      lastRequestRef.current.voiceId === selectedVoice &&
      lastRequestRef.current.text === text &&
      lastRequestRef.current.lang === lang;

    if (audioRef.current && sameAsLast) {
      if (audioRef.current.paused) {
        audioRef.current.play();
        setIsPlaying(true);
      } else {
        audioRef.current.pause();
        setIsPlaying(false);
      }
      return;
    }

    resetAudio();
    try {
      const res = await fetch("/api/tts", {
        method: "POST",
        cache: "no-store",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          text,
          voice_id: selectedVoice,
          language_code: lang, // always "en"
        }),
      });

      if (!res.ok) {
        console.error("TTS request failed");
        alert("Text-to-Speech is currently unavailable. Please read the article manually.");
        return;
      }

      const blob = await res.blob();
      const url = URL.createObjectURL(blob);
      setAudioUrl(url);

      audioRef.current = new Audio(url);
      audioRef.current.play();
      setIsPlaying(true);
      lastRequestRef.current = { voiceId: selectedVoice, text, lang };

      audioRef.current.onended = () => setIsPlaying(false);
    } catch (err) {
      console.error("Unexpected error in TTS:", err);
    }
  };

  const getTopicNames = (topicIds: string[]): string[] => {
    if (!topicIds?.length || !topics?.length) return ["General"];
    return topicIds.map(id => {
      const topic = topics.find(t => t.id === id);
      return topic ? (showAmharic ? topic.label.am : topic.label.en) : "General";
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

  if (loading) {
    return (
      <>
        <ChatBot defaultOpen={true} />
        <div
          className={`flex flex-col lg:flex-row gap-5 min-h-screen w-full transition-colors ${
            theme === "light" ? "bg-white text-black" : "bg-gray-900 text-white"
          }`}
        >
          <div className="flex-1 lg:ml-0 lg:mt-1 px-4 lg:px-6 lg:mr-10 w-full overflow-hidden">
            <div className="flex justify-between w-full mb-4">
              <TopBar />
            </div>
            <main className="w-full max-w-7xl mx-auto space-y-12 px-4">
            {/* Title Shimmer */}
            <div className="h-8 bg-gray-300 rounded animate-pulse mb-4 w-3/4"></div>
            
            {/* Meta info Shimmer */}
            <div className="flex flex-wrap items-center gap-2 mb-6">
              <div className="h-6 bg-gray-300 rounded animate-pulse w-20"></div>
              <div className="h-6 bg-gray-300 rounded animate-pulse w-16"></div>
              <div className="h-4 bg-gray-300 rounded animate-pulse w-32"></div>
            </div>

            {/* Cover Image Shimmer */}
            <div className="w-full h-72 lg:h-[28rem] mb-6 rounded-lg bg-gray-300 animate-pulse"></div>

            {/* Language toggle Shimmer */}
            <div className="flex gap-3 mb-4">
              <div className="h-8 bg-gray-300 rounded animate-pulse w-16"></div>
              <div className="h-8 bg-gray-300 rounded animate-pulse w-16"></div>
            </div>

            {/* Content Shimmer */}
            <div className="space-y-3 mb-10">
              <div className="h-4 bg-gray-300 rounded animate-pulse w-full"></div>
              <div className="h-4 bg-gray-300 rounded animate-pulse w-full"></div>
              <div className="h-4 bg-gray-300 rounded animate-pulse w-3/4"></div>
              <div className="h-4 bg-gray-300 rounded animate-pulse w-full"></div>
              <div className="h-4 bg-gray-300 rounded animate-pulse w-5/6"></div>
            </div>

            {/* Listening Mode Shimmer */}
            <section className="max-w-2xl">
              <div className="h-6 bg-gray-300 rounded animate-pulse mb-3 w-32"></div>
              <div className="flex items-center gap-5 rounded-xl shadow-md p-4 bg-gray-100">
                <div className="w-16 h-16 rounded-lg bg-gray-300 animate-pulse"></div>
                <div className="flex-1">
                  <div className="h-4 bg-gray-300 rounded animate-pulse mb-2 w-3/4"></div>
                  <div className="h-3 bg-gray-300 rounded animate-pulse w-1/2"></div>
                </div>
                <div className="w-11 h-11 rounded-full bg-gray-300 animate-pulse"></div>
              </div>
            </section>
            </main>
          </div>
        </div>
      </>
    );
  }
  
  if (!news) return <p className="p-6">News not found.</p>;

  return (
    <>
      <ChatBot defaultOpen={true} />
      <div
        className={`flex flex-col lg:flex-row gap-5 min-h-screen w-full transition-colors ${
          theme === "light" ? "bg-white text-black" : "bg-gray-900 text-white"
        }`}
      >
        <div className="flex-1 lg:ml-0 lg:mt-1 px-4 lg:px-6 lg:mr-10 w-full overflow-hidden">
          <div className="flex justify-between w-full mb-4">
            <TopBar />
          </div>
          <main className="w-full max-w-7xl mx-auto space-y-12 px-4">
          {/* Title */}
          <h1 className="text-2xl lg:text-3xl font-bold mb-6">
            {showAmharic ? news.title_am || news.title : news.title_en || news.title}
          </h1>

          {/* Meta info */}
          <div className="flex flex-wrap items-center gap-2 mb-8">
            {news.topics?.map((t, i) => (
              <TopicTag key={i} text={getTopicNames([t])[0]} theme={theme} />
            ))}
            <span
              className={`text-xs ${
                theme === "dark" ? "text-gray-400" : "text-gray-500"
              }`}
            >
              {news.source_id} • {news.published_at}
            </span>
          </div>

          {/* Cover Image */}
          <div className="relative w-full h-72 lg:h-[28rem] mb-8 rounded-lg overflow-hidden shadow">
            <img
              src={getTopicImage(news.topics)}
              alt={showAmharic ? news.title_am || news.title : news.title_en || news.title}
              className="absolute inset-0 object-cover w-full h-full"
            />
          </div>

          {/* Language toggle */}
          <div className="flex gap-3 mb-6">
            <button
              onClick={() => {
                setShowAmharic(false);
                setSelectedLanguage("en");
                resetAudio();
              }}
              className={`px-3 py-1 rounded ${
                !showAmharic ? "bg-indigo-600 text-white" : "bg-gray-200 "
              }`}
            >
              English
            </button>
            <button
              onClick={() => {
                setShowAmharic(true);
                setSelectedLanguage("am");
                resetAudio();
              }}
              className={`px-3 py-1 rounded ${
                showAmharic ? "bg-indigo-600 text-white" : "bg-gray-200 "
              }`}
            >
              አማርኛ
            </button>
          </div>

          {/* Description - Display full body content */}
          <div
            className={`text-base leading-relaxed mb-12 ${
              theme === "dark" ? "text-gray-300" : "text-gray-700"
            }`}
          >
            {showAmharic
              ? news.body_am || news.summary_am || "No Amharic version available."
              : news.body_en || news.body || news.summary_en || "No English version available."}
          </div>

          {/* Listening Mode */}
          <section className="max-w-2xl mb-8">
            <h2 className="text-lg font-semibold mb-3">🎧 Listening Mode</h2>
            <div
              className={`flex items-center gap-5 rounded-xl shadow-md p-4 transition-all duration-700 
              ${
                theme === "dark"
                  ? "bg-gradient-to-r from-gray-700 via-gray-600 to-gray-500 text-white"
                  : "bg-gradient-to-r from-gray-100 via-gray-50 to-white text-black"
              }`}
            >
              {/* Thumbnail */}
              <div className="relative w-16 h-16 rounded-lg overflow-hidden">
                <img
                  src={getTopicImage(news.topics)}
                  alt="Thumbnail"
                  className="absolute inset-0 object-cover w-full h-full"
                />
              </div>

              {/* Player Section */}
              <div className="flex flex-col flex-1 min-w-0">
                <h3 className="text-sm font-semibold truncate">
                  {showAmharic ? news.title_am || news.title : news.title_en || news.title}
                </h3>
                <p
                  className={`${
                    theme === "dark" ? "text-gray-300" : "text-gray-600"
                  } text-xs mb-2 truncate`}
                >
                  AI will read this article for you.
                </p>
              </div>

              {/* Play button */}
              <button
                onClick={handlePlayElevenLabs}
                className="w-11 h-11 flex items-center justify-center rounded-full bg-indigo-600 hover:bg-indigo-500 text-white"
              >
                {isPlaying ? "⏸" : "▶️"}
              </button>
            </div>
          </section>
          </main>
        </div>
      </div>
    </>
  );
}