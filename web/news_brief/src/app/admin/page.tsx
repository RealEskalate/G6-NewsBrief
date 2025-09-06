"use client";
import { useEffect, useState } from "react";
import {Charts } from "@/components/reusable_components/Chart";
import { apiClient } from "@/lib/api"; // adjust path if needed

interface Analytics {
  total_users: number;
  total_news: number;
  total_sources: number;
  total_topics: number;
}

export default function Dashboard() {
  const [loading, setLoading] = useState(true);
  const [fetching, setFetching] = useState(false);
  const [latestResult, setLatestResult] = useState<{ ingested: number; ids: string[]; skipped: number } | null>(null);
  const [analytics, setAnalytics] = useState<Analytics | null>(null);

  // Simulate page loading
  useEffect(() => {
    const timer = setTimeout(() => setLoading(false), 2000);
    return () => clearTimeout(timer);
  }, []);

  // Fetch analytics data on mount
  useEffect(() => {
    async function fetchAnalytics() {
      try {
        const res = await apiClient.getAnalytics();
        setAnalytics(res);
      } catch (err) {
        console.error("Failed to fetch analytics:", err);
      }
    }

    fetchAnalytics();
  }, []);

  const handleFetchLatest = async () => {
    try {
      setFetching(true);
      const result = await apiClient.fetchLatestData();
      setLatestResult(result);
      alert(`Fetched ${result.ingested} new items!`);
      
      // Refresh analytics after fetching new data
      const res = await apiClient.getAnalytics();
      setAnalytics(res);
    } catch (err) {
      console.error("Fetch latest data failed:", err);
      alert("Failed to fetch latest data!");
    } finally {
      setFetching(false);
    }
  };

  return (
    <div className="min-h-screen bg-gray-50 px-4 sm:px-6 lg:px-12 py-6">
      <div className="flex justify-between items-center mb-4">
        <h1 className="text-lg sm:text-xl font-semibold">Admin Analytics</h1>

        <button
          onClick={handleFetchLatest}
          disabled={fetching}
          className="bg-gray-900 hover:bg-gray-800 text-white font-semibold px-6 py-2 rounded-lg shadow-md transition"
        >
          {fetching ? "Fetching..." : "Fetch Latest"}
        </button>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-4 gap-4 mb-6">
        {["total_news", "total_topics", "total_sources", "total_users"].map((key, i) => (
          <div key={i} className="rounded-xl bg-white p-4 border border-gray-100 w-full sm:w-auto">
            {loading || !analytics ? (
              <div className="animate-pulse space-y-3">
                <div className="h-4 w-24 bg-gray-200 rounded"></div>
                <div className="h-10 w-full bg-gray-200 rounded"></div>
              </div>
            ) : (
              <>
                {key === "total_news" && (
                  <>
                    <p className="text-sm font-medium mb-3">Total News</p>
                    <div className="flex items-center justify-between bg-indigo-50 rounded-lg px-3 py-2">
                      <span className="text-sm text-gray-600">Published</span>
                      <span className="text-lg font-semibold text-gray-900">{analytics.total_news}</span>
                    </div>
                  </>
                )}
                {key === "total_topics" && (
                  <>
                    <p className="text-sm font-medium mb-3">Total Topics</p>
                    <div className="flex items-center justify-between bg-indigo-50 rounded-lg px-3 py-2">
                      <span className="text-sm text-gray-600">Active</span>
                      <span className="text-lg font-semibold text-gray-900">{analytics.total_topics}</span>
                    </div>
                  </>
                )}
                {key === "total_sources" && (
                  <>
                    <p className="text-sm font-medium mb-3">Total Sources</p>
                    <div className="flex items-center justify-between bg-indigo-50 rounded-lg px-3 py-2">
                      <span className="text-sm text-gray-600">Verified</span>
                      <span className="text-lg font-semibold text-gray-900">{analytics.total_sources}</span>
                    </div>
                  </>
                )}
                {key === "total_users" && (
                  <>
                    <p className="text-sm font-medium mb-3">Total Users</p>
                    <div className="flex items-center justify-between bg-indigo-50 rounded-lg px-3 py-2">
                      <span className="text-sm text-gray-600">Registered</span>
                      <span className="text-lg font-semibold text-gray-900">{analytics.total_users}</span>
                    </div>
                  </>
                )}
              </>
            )}
          </div>
        ))}
      </div>

      {/* Charts */}
      <div className="w-full overflow-x-auto">
        {loading ? (
          <div className="animate-pulse h-72 w-full bg-gray-200 rounded-lg"></div>
        ) : (
          <Charts />
        )}
      </div>
    </div>
  );
}
