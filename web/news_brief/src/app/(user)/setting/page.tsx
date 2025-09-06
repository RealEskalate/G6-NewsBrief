"use client";
import React, { useContext, useState, useEffect } from "react";
import { Edit2, Eye, EyeOff } from "lucide-react";
import TopBar from "@/components/reusable_components/topBar";
import { useTranslation } from "react-i18next";
import { ThemeContext } from "@/app/contexts/ThemeContext";
import { apiClient, User, Source, Topic } from "../../../lib/api";

type TabId = "customization" | "account" | "categories" | "subscriptions";

const SettingsPage = () => {
  const { t } = useTranslation();
  const context = useContext(ThemeContext);
  if (!context)
    throw new Error("SettingsPage must be used inside ThemeProvider");

  const { theme, setTheme } = context;

  const [activeTab, setActiveTab] = useState<TabId>("account");
  const [profile, setProfile] = useState<User | null>(null);
  const [fullName, setFullName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [editingFullName, setEditingFullName] = useState(false);
  const [editingEmail, setEditingEmail] = useState(false);
  const [editingPassword, setEditingPassword] = useState(false);
  const [passwordVisible, setPasswordVisible] = useState(false);

  const [sources, setSources] = useState<Source[]>([]);
  const [subscriptions, setSubscriptions] = useState<Source[]>([]);
  const [selectedSource, setSelectedSource] = useState("");
  const [error, setError] = useState<boolean | null | string>(null);
  const [loading, setLoading] = useState<boolean | null | string>(null);
  const [saving, setSaving] = useState(false);

  const [tags, setTags] = useState<string[]>([]);
  const [newTag, setNewTag] = useState("");

  // Topics state
  const [allTopics, setAllTopics] = useState<Topic[]>([]);
  const [subscribedTopics, setSubscribedTopics] = useState<
    {
      slug: string;
      topic_name: string;
      label: { en: string; am: string };
      story_count: number;
    }[]
  >([]);
  const [selectedTopic, setSelectedTopic] = useState("");

  const tabs: { id: TabId; label: string }[] = [
    { id: "customization", label: t("settings.tabs.customization") },
    { id: "account", label: t("settings.tabs.account") },
    { id: "categories", label: t("settings.tabs.categories") },
    { id: "subscriptions", label: t("settings.tabs.subscriptions") },
  ];
  const [hasChanges, setHasChanges] = useState(false);

  // Watch for profile edits and any changes in subscriptions to enable save button
  useEffect(() => {
    if (editingFullName || editingEmail || editingPassword || selectedSource) {
      setHasChanges(true);
    } else {
      setHasChanges(false);
    }
  }, [editingFullName, editingEmail, editingPassword, selectedSource]);

  // Load sources + subscriptions + topics from API
  useEffect(() => {
    const fetchData = async () => {
      try {
        const [allSources, mySubs, topics, subscribedTopicsData] =
          await Promise.all([
            apiClient.getSources(),
            apiClient.getSubscriptions(),
            apiClient.getTopics(),
            apiClient.getSubscribedTopics(),
          ]);

        console.log("from source", allSources);
        setSources(allSources);
        setSubscriptions(mySubs);
        setAllTopics(topics);
        setSubscribedTopics(subscribedTopicsData);

        // Load tags from localStorage (keep for backward compatibility)
        const savedTags = localStorage.getItem("userTags");
        if (savedTags) {
          try {
            const parsedTags = JSON.parse(savedTags);
            setTags(parsedTags);
          } catch (e) {
            console.error("Error parsing saved tags:", e);
            setTags([]);
          }
        } else {
          setTags([]);
        }
      } catch (err) {
        console.error("Error fetching data:", err);
      }
    };
    fetchData();
  }, []);

  // Save tags to localStorage whenever tags change
  useEffect(() => {
    if (tags.length > 0) {
      localStorage.setItem("userTags", JSON.stringify(tags));
    }
  }, [tags]);

  // Add subscription
  const handleAddSubscription = async () => {
    if (!selectedSource) return;
    try {
      await apiClient.addSubscription(selectedSource);
      const updated = await apiClient.getSubscriptions();
      setSubscriptions(updated);
      setSelectedSource("");
    } catch (err) {
      console.error("Failed to add subscription:", err);
      alert(
        `Failed to add subscription: ${
          err instanceof Error ? err.message : "Unknown error"
        }`
      );
    }
  };
  const saveBtnClass = `px-4 py-2 rounded-lg transition-colors ${
    hasChanges
      ? "bg-black text-white hover:bg-gray-800"
      : theme === "dark"
      ? "bg-gray-700 text-gray-100 hover:bg-gray-600"
      : "bg-gray-300 text-gray-900 hover:bg-gray-400"
  }`;

  // Remove subscription
  const handleRemoveSubscription = async (slug: string) => {
    try {
      await apiClient.removeSubscription(slug);
      setHasChanges(true);
      setSubscriptions(subscriptions.filter((s) => s.slug !== slug));
    } catch (err) {
      console.error("Failed to remove subscription:", err);
    }
  };

  // Add topic subscription
  const handleAddTopicSubscription = async () => {
    if (!selectedTopic) return;
    try {
      await apiClient.subscribeToTopic(selectedTopic);
      // Refresh subscribed topics
      const updatedSubscribedTopics = await apiClient.getSubscribedTopics();
      setSubscribedTopics(updatedSubscribedTopics);
      setSelectedTopic("");
    } catch (err) {
      console.error("Error adding topic subscription:", err);
    }
  };

  // Remove topic subscription
  const handleRemoveTopicSubscription = async (topicId: string) => {
    try {
      await apiClient.unsubscribeFromTopic(topicId);
      // Refresh subscribed topics
      const updatedSubscribedTopics = await apiClient.getSubscribedTopics();
      setSubscribedTopics(updatedSubscribedTopics);
    } catch (err) {
      console.error("Error removing topic subscription:", err);
    }
  };

  // Fetch profile from API or localStorage
  useEffect(() => {
    const fetchProfile = async () => {
      try {
        let data: User | null = null;
        try {
          data = await apiClient.getProfile();
        } catch {
          const stored = localStorage.getItem("person");
          if (stored) {
            const parsed = JSON.parse(stored);
            const user = parsed.user;
            data = {
              id: user?.id ?? "",
              fullname: user?.fullname ?? "",
              email: user?.email ?? user?.username ?? "",
              role: user?.role ?? "user",
              subscribed: [],
              topic_interest: [],
              saved_news: [],
            };
          }
        }
        if (data) {
          setProfile(data);
          setFullName(data.fullname);
          setEmail(data.email);
        } else {
          setError("No profile data found.");
        }
      } catch (err: unknown) {
        setError(err instanceof Error ? err.message : "Failed to load profile");
      } finally {
        setLoading(false);
      }
    };
    fetchProfile();
  }, []);

  const handleSave = async () => {
    if (!profile) return;
    setSaving(true);
    setError(null);

    try {
      const updated = await apiClient.updateProfile({
        fullname: fullName,
        ...(editingPassword && password ? { password } : {}),
      });

      setProfile(updated);
      setEditingFullName(false);
      setEditingEmail(false);
      setEditingPassword(false);
      setPassword("");

      const stored = localStorage.getItem("person");
      if (stored) {
        const parsed = JSON.parse(stored);
        parsed.user = {
          ...parsed.user,
          fullname: updated.fullname,
          email: updated.email,
        };
        localStorage.setItem("person", JSON.stringify(parsed));
      }

      // Profile updated successfully - could add toast notification here
    } catch (err: unknown) {
      setError(err instanceof Error ? err.message : "Failed to update profile");
    } finally {
      setSaving(false);
    }
  };

  // Dynamic classes for theme
  const inputClass = `w-full border rounded-lg px-3 py-2 ${
    theme === "dark"
      ? "bg-gray-800 border-gray-600 focus:ring-gray-500 text-gray-100"
      : "bg-gray-100 border-gray-300 focus:ring-gray-300 text-gray-900"
  } focus:outline-none focus:ring-2`;

  const sectionClass = `border rounded-2xl p-5 sm:p-6 shadow-sm transition-colors duration-300 ${
    theme === "dark"
      ? "border-gray-700 bg-gray-900"
      : "border-gray-200 bg-gray-50"
  }`;

  return (
    <>
      <TopBar />
      <div
        className={`flex flex-col md:flex-row min-h-screen transition-colors duration-300 ${
          theme === "dark"
            ? "bg-[#1A1A1A] text-gray-100"
            : "bg-gray-50 text-gray-900"
        }`}
      >
        <div className="flex-1 pt-6 md:pt-10 px-4 sm:px-6 lg:px-8 flex justify-center">
          <div className="w-full max-w-4xl">
            {/* Header */}
            <div className="flex flex-col md:flex-row justify-between items-start md:items-center mb-6 md:mb-8 gap-4 md:gap-0">
              <h1 className="text-2xl sm:text-3xl font-semibold">
                {t("settings.title")}
              </h1>
              <button
                onClick={handleSave}
                className={saveBtnClass}
                disabled={saving}
              >
                {saving ? t("settings.saving") : t("settings.saveChanges")}
              </button>
            </div>

            {/* Tabs */}
            <div
              className={`flex overflow-x-auto space-x-3 mb-6 p-2 rounded-xl transition-colors ${
                theme === "dark" ? "bg-gray-800" : "bg-gray-200"
              }`}
            >
              {tabs.map((tab) => (
                <button
                  key={tab.id}
                  onClick={() => setActiveTab(tab.id)}
                  className={`px-4 py-2 text-sm font-medium rounded-lg transition flex-shrink-0 ${
                    activeTab === tab.id
                      ? theme === "dark"
                        ? "bg-gray-700 text-gray-100 shadow-sm"
                        : "bg-gray-300 text-gray-900 shadow-sm"
                      : theme === "dark"
                      ? "text-gray-300 hover:text-gray-100"
                      : "text-gray-700 hover:text-gray-900"
                  }`}
                >
                  {tab.label}
                </button>
              ))}
            </div>

            {/* Customization Tab */}
            {activeTab === "customization" && (
              <section className={sectionClass}>
                <h2 className="text-lg font-medium mb-4">
                  {t("settings.tabs.customization")}
                </h2>
                <div className="mb-4">
                  <label className="block text-sm font-medium mb-1">
                    {t("settings.theme")}
                  </label>
                  <select
                    value={theme}
                    onChange={(e) =>
                      setTheme(e.target.value as "light" | "dark" | "system")
                    }
                    className={`${inputClass}`}
                  >
                    <option value="system">System Default</option>
                    <option value="light">Light</option>
                    <option value="dark">Dark</option>
                  </select>
                </div>
                <div className="flex items-center justify-between">
                  <span className="text-sm text-gray-700">
                    {t("settings.showAvatars")}
                  </span>
                  <input
                    type="checkbox"
                    className="form-checkbox h-5 w-5 text-black rounded"
                  />
                </div>
              </section>
            )}

            {/* Account Tab */}
            {activeTab === "account" && (
              <section className={sectionClass}>
                <h2 className="text-xl sm:text-2xl font-semibold mb-4">
                  {t("settings.account.title")}
                </h2>
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 sm:gap-6">
                  {/* Full Name */}
                  <div className="relative">
                    <label className="block text-sm font-medium mb-1">
                      {t("auth.fullName")}
                    </label>
                    <div className="relative">
                      <input
                        type="text"
                        value={fullName}
                        onChange={(e) => setFullName(e.target.value)}
                        className={`${inputClass} pr-10 ${
                          editingFullName ? "text-gray-900" : "text-gray-400"
                        }`}
                        disabled={!editingFullName}
                        placeholder={t(
                          "settings.account.placeholders.fullName"
                        )}
                      />
                      <button
                        type="button"
                        onClick={() => setEditingFullName(true)}
                        className="absolute right-2 top-2.5 text-gray-500 hover:text-gray-700"
                      >
                        <Edit2 size={16} />
                      </button>
                    </div>
                  </div>
                  {/* Email */}
                  <div className="relative">
                    <label className="block text-sm font-medium mb-1">
                      {t("auth.email")}
                    </label>
                    <div className="relative">
                      <input
                        type="email"
                        value={email}
                        onChange={(e) => setEmail(e.target.value)}
                        className={`${inputClass} pr-10 ${
                          editingEmail ? "text-gray-900" : "text-gray-400"
                        }`}
                        disabled={!editingEmail}
                        placeholder={t("settings.account.placeholders.email")}
                      />
                      {/* <button
                        type="button"
                        onClick={() => setEditingEmail(true)}
                        className="absolute right-2 top-2.5 text-gray-500 hover:text-gray-700"
                      >
                        <Edit2 size={16} />
                      </button> */}
                    </div>
                  </div>
                  {/* Password */}
                  <div className="relative sm:col-span-2">
                    <label className="block text-sm font-medium mb-1">
                      {t("auth.password")}
                    </label>
                    <div className="relative">
                      <input
                        type={
                          editingPassword
                            ? passwordVisible
                              ? "text"
                              : "password"
                            : "text"
                        }
                        value={editingPassword ? password : "●●●●●●●"}
                        onChange={(e) => setPassword(e.target.value)}
                        placeholder={t(
                          "settings.account.placeholders.password"
                        )}
                        className={`${inputClass} pr-10 ${
                          editingPassword ? "text-gray-900" : "text-gray-400"
                        }`}
                        disabled={!editingPassword}
                      />
                      {!editingPassword ? (
                        <button
                          type="button"
                          onClick={() => {
                            setEditingPassword(true);
                            setPassword("");
                          }}
                          className="absolute right-2 top-2.5 text-gray-500 hover:text-gray-700"
                        >
                          <Edit2 size={16} />
                        </button>
                      ) : (
                        <button
                          type="button"
                          onClick={() => setPasswordVisible(!passwordVisible)}
                          className="absolute right-2 top-2.5 text-gray-500 hover:text-gray-700"
                        >
                          {passwordVisible ? (
                            <EyeOff size={16} />
                          ) : (
                            <Eye size={16} />
                          )}
                        </button>
                      )}
                    </div>
                  </div>
                </div>
              </section>
            )}

            {/* Categories Tab */}
            {activeTab === "categories" && (
              <>
                <section className={sectionClass}>
                  <h2 className="text-lg font-medium mb-4">
                    {t("settings.tabs.categories")}
                  </h2>
                  <p className="text-sm text-gray-600 mb-4">
                    Manage your topic interests to personalize your news feed.
                  </p>

                  {/* Current subscribed topics */}
                  <div className="mb-6">
                    <h3 className="text-md font-medium mb-3">
                      Subscribed Topics
                    </h3>
                    {subscribedTopics.length > 0 ? (
                      <div className="flex flex-wrap gap-2">
                        {subscribedTopics.map((topic) => (
                          <span
                            key={topic.slug}
                            className="flex items-center gap-2 bg-blue-100 text-blue-800 px-3 py-1.5 rounded-full text-sm font-medium"
                          >
                            {topic.label?.en || topic.topic_name}
                            <button
                              onClick={() =>
                                handleRemoveTopicSubscription(topic.slug)
                              }
                              className="text-blue-500 hover:text-blue-800 ml-1"
                            >
                              ✕
                            </button>
                          </span>
                        ))}
                      </div>
                    ) : (
                      <p className="text-gray-500 text-sm">
                        No topics subscribed yet. Subscribe to topics to
                        personalize your news feed.
                      </p>
                    )}
                  </div>
                </section>

                <section className={sectionClass}>
                  <h3 className="text-md font-medium mb-3">
                    Subscribe to Topics
                  </h3>
                  <div className="flex flex-col sm:flex-row items-start sm:items-center gap-3">
                    <select
                      value={selectedTopic}
                      onChange={(e) => setSelectedTopic(e.target.value)}
                      className={`${inputClass} flex-1`}
                    >
                      <option value="">Select a topic...</option>
                      {allTopics
                        .filter(
                          (topic) =>
                            !subscribedTopics.some(
                              (sub) => sub.slug === topic.id
                            )
                        )
                        .map((topic) => (
                          <option key={topic.id} value={topic.id}>
                            {topic.label?.en || topic.id}
                          </option>
                        ))}
                    </select>
                    <button
                      onClick={handleAddTopicSubscription}
                      disabled={!selectedTopic}
                      className="bg-[#0B66FF] text-white px-4 py-2 rounded-lg hover:bg-[#EAF2FF] hover:text-black transition w-full sm:w-auto disabled:opacity-50 disabled:cursor-not-allowed"
                    >
                      + Subscribe
                    </button>
                  </div>
                </section>
              </>
            )}

            {/* Subscriptions Tab */}
            {activeTab === "subscriptions" && (
              <section className={sectionClass}>
                <h2 className="text-lg font-medium mb-4">
                  {t("settings.tabs.subscriptions")}
                </h2>

                {/* Current subscriptions */}
                <div className="space-y-3 mb-6">
                  {subscriptions.map((sub) => (
                    <div
                      key={sub.slug}
                      className="flex flex-col sm:flex-row sm:justify-between items-start sm:items-center border border-gray-200 rounded-xl px-4 py-3 gap-2 sm:gap-0"
                    >
                      <div className="flex items-center gap-3">
                        {sub.logo_url && (
                          <img
                            src={sub.logo_url}
                            alt={sub.name}
                            className="w-6 h-6 rounded"
                          />
                        )}
                        <span className="text-gray-800 font-medium">
                          {sub.name}
                        </span>
                      </div>
                      <button
                        onClick={() => handleRemoveSubscription(sub.slug)}
                        className="text-sm border border-gray-300 rounded-lg px-3 py-1.5 hover:bg-[#EAF2FF] hover:border-[#0B66FF] hover:text-[#0B66FF] transition"
                      >
                        Remove
                      </button>
                    </div>
                  ))}
                  {subscriptions.length === 0 && (
                    <p className="text-gray-500 text-sm">
                      No subscriptions yet.
                    </p>
                  )}
                </div>

                {/* Add subscription */}
                <div className="flex flex-col sm:flex-row items-start sm:items-center gap-3">
                  <select
                    value={selectedSource}
                    onChange={(e) => setSelectedSource(e.target.value)}
                    className={`${inputClass} flex-1`}
                  >
                    <option value="">Select a source...</option>
                    {sources
                      .filter(
                        (src) =>
                          !subscriptions.some((sub) => sub.slug === src.slug)
                      )
                      .map((src) => (
                        <option key={src.slug} value={src.slug}>
                          {src.name}
                        </option>
                      ))}
                  </select>
                  <button
                    onClick={handleAddSubscription}
                    className="bg-[#0B66FF] text-white px-4 py-2 rounded-lg hover:bg-[#EAF2FF] hover:text-black transition w-full sm:w-auto"
                  >
                    + Add
                  </button>
                </div>
              </section>
            )}
          </div>
        </div>
      </div>
    </>
  );
};

export default SettingsPage;
