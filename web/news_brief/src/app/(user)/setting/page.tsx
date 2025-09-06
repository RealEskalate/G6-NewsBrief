"use client";
import React, { useContext, useState, useEffect } from "react";
import { Edit2, Eye, EyeOff } from "lucide-react";
import TopBar from "@/components/reusable_components/search_topbar";
import ChatBot from "@/components/reusable_components/Generalchatbot";
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

  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const [userTopics, setUserTopics] = useState<Topic[]>([]);
  const [availableTopics, setAvailableTopics] = useState<Topic[]>([]);
  const [selectedTopic, setSelectedTopic] = useState("");
  const [topicsLoading, setTopicsLoading] = useState(false);

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
        const allSources = await apiClient.getSources();
        const mySubs = await apiClient.getSubscriptions();
        
        // Get all available topics (for the dropdown)
        const allTopics = await apiClient.getTopics();
        console.log("from source", allSources);
        console.log("from all topics", allTopics);
        setSources(allSources);
        setSubscriptions(mySubs);
        setAvailableTopics(allTopics);

        // Get user's current topic interests
        const userTopics = await apiClient.getUserTopics();
        console.log("from user topics", userTopics);
        console.log("userTopics length:", userTopics.length);
        console.log("Setting userTopics state with:", userTopics);
        setUserTopics(userTopics);
      } catch (err) {
        console.error("Error fetching sources/subs/topics:", err);
      }
    };
    fetchData();
  }, []);

  // Debug: Monitor userTopics state changes
  useEffect(() => {
    console.log("userTopics state changed:", userTopics);
    console.log("userTopics state length:", userTopics.length);
  }, [userTopics]);

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
      ? theme === "dark"
        ? "bg-white text-black hover:bg-gray-200"
        : "bg-black text-white hover:bg-gray-800"
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

  // Topic functions
  const addTopic = async () => {
    if (!selectedTopic) return;
    setTopicsLoading(true);
    try {
      await apiClient.addTopic(selectedTopic);
      const updatedUserTopics = await apiClient.getUserTopics();
      setUserTopics(updatedUserTopics);
      setSelectedTopic("");
    } catch (err) {
      console.error("Failed to add topic:", err);
      alert(
        `Failed to add topic: ${
          err instanceof Error ? err.message : "Unknown error"
        }`
      );
    } finally {
      setTopicsLoading(false);
    }
  };

  const removeTopic = async (topicSlug: string) => {
    setTopicsLoading(true);
    try {
      // Find the topic by slug to get the ID for the API call
      const topic = userTopics.find(t => t.slug === topicSlug);
      if (!topic) {
        throw new Error("Topic not found");
      }
      await apiClient.removeTopic(topic.id);
      // Refresh user topics directly
      const updatedUserTopics = await apiClient.getUserTopics();
      setUserTopics(updatedUserTopics);
    } catch (err) {
      console.error("Failed to remove topic:", err);
      alert(
        `Failed to remove topic: ${
          err instanceof Error ? err.message : "Unknown error"
        }`
      );
    } finally {
      setTopicsLoading(false);
    }
  };

  // Dynamic classes for theme
  const inputClass = `w-full border rounded-lg px-3 py-2 ${
    theme === "dark"
      ? "bg-gray-700 border-gray-600 focus:ring-gray-500 text-gray-100"
      : "bg-white border-gray-300 focus:ring-gray-300 text-gray-900"
  } focus:outline-none focus:ring-2`;

  const sectionClass = `border rounded-2xl p-5 sm:p-6 shadow-sm transition-colors duration-300 ${
    theme === "dark"
      ? "border-gray-700 bg-gray-800"
      : "border-gray-200 bg-white"
  }`;

  

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
                theme === "dark" ? "bg-gray-700" : "bg-gray-100"
              }`}
            >
              {tabs.map((tab) => (
                <button
                  key={tab.id}
                  onClick={() => setActiveTab(tab.id)}
                  className={`px-4 py-2 text-sm font-medium rounded-lg transition flex-shrink-0 ${
                    activeTab === tab.id
                      ? theme === "dark"
                        ? "bg-gray-600 text-gray-100 shadow-sm"
                        : "bg-white text-gray-900 shadow-sm"
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
                  <p className={`text-sm mb-4 ${
                    theme === "dark" ? "text-gray-400" : "text-gray-600"
                  }`}>
                    Manage your topic interests to personalize your news feed.
                  </p>

                  {userTopics.length > 0 ? (
                    <div className="flex flex-wrap gap-2">
                      {userTopics.map((topic) => (
                        <span
                          key={topic.slug}
                          className="flex items-center gap-2 bg-blue-100 text-blue-800 px-3 py-1.5 rounded-full text-sm font-medium"
                        >
                          {topic.label.en}
                          <button
                            onClick={() => removeTopic(topic.slug)}
                            disabled={topicsLoading}
                            className="text-blue-500 hover:text-blue-800 ml-1 disabled:opacity-50 disabled:cursor-not-allowed"
                          >
                            ✕
                          </button>
                        </span>
                      ))}
                    </div>
                  ) : (
                    <div>
                      <p className="text-gray-500 text-sm">
                        No topics selected yet. Add some topics to personalize
                        your news feed.
                      </p>
                    </div>
                  )}
                </section>

                <section className={sectionClass}>
                  <h3 className="text-md font-medium mb-3">
                    Add Topic Interest
                  </h3>
                  <div className="flex flex-col sm:flex-row items-start sm:items-center gap-3">
                    <select
                      value={selectedTopic}
                      onChange={(e) => setSelectedTopic(e.target.value)}
                      className={`${inputClass} flex-1`}
                    >
                      <option value="">Select a topic...</option>
                      {availableTopics
                        .filter(
                          (topic) =>
                            !userTopics.some((userTopic) => userTopic.slug === topic.slug)
                        )
                        .map((topic) => (
                          <option key={topic.slug} value={topic.id}>
                            {topic.label.en}
                          </option>
                        ))}
                    </select>
                    <button
                      onClick={addTopic}
                      disabled={!selectedTopic || topicsLoading}
                      className="bg-[#0B66FF] text-white px-4 py-2 rounded-lg hover:bg-[#EAF2FF] hover:text-black transition w-full sm:w-auto disabled:opacity-50 disabled:cursor-not-allowed"
                    >
                      {topicsLoading ? "Adding..." : "+ Add Topic"}
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
                        className={`text-sm border rounded-lg px-3 py-1.5 transition ${
                          theme === "dark"
                            ? "border-gray-600 text-gray-300 hover:bg-gray-700 hover:border-gray-500 hover:text-white"
                            : "border-gray-300 text-gray-700 hover:bg-gray-100 hover:border-gray-400 hover:text-gray-900"
                        }`}
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
                    className={`px-4 py-2 rounded-lg transition w-full sm:w-auto ${
                      theme === "dark"
                        ? "bg-white text-black hover:bg-gray-200"
                        : "bg-black text-white hover:bg-gray-800"
                    }`}
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
