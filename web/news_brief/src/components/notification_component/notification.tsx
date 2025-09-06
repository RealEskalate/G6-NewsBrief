'use client';
import React, { useState, useContext } from "react";
import { ThemeContext } from "@/app/contexts/ThemeContext";

export default function Notification() {
  const context = useContext(ThemeContext);
  if (!context) throw new Error("Notification must be used inside ThemeProvider");
  const { theme } = context;

  const [dailyDigest, setDailyDigest] = useState(false);
  const [breakingNews, setBreakingNews] = useState(false);
  const [digestTime, setDigestTime] = useState("8:00 AM");

  const times = [
    "6:00 AM",
    "7:00 AM",
    "8:00 AM",
    "9:00 AM",
    "10:00 AM",
    "12:00 PM",
    "6:00 PM",
    "9:00 PM",
  ];

  return (
    <div
      className={`max-w-md mx-auto shadow-md rounded-2xl p-6 border transition-colors ${
        theme === "light"
          ? "bg-white border-gray-200 text-black"
          : "bg-gray-800 border-gray-700 text-white"
      }`}
    >
      {/* Daily Digest Toggle */}
      <div
        className={`flex items-center justify-between py-3 border-b transition-colors ${
          theme === "light" ? "border-gray-100" : "border-gray-600"
        }`}
      >
        <div>
          <h2 className={`font-semibold ${theme === "light" ? "text-gray-800" : "text-white"}`}>
            Daily Digest
          </h2>
          <p className={`text-sm ${theme === "light" ? "text-gray-500" : "text-gray-300"}`}>
            Receive a summary of top news daily
          </p>
        </div>
        <button
          onClick={() => setDailyDigest(!dailyDigest)}
          className={`relative w-12 h-6 flex items-center rounded-full transition-colors ${
            dailyDigest
              ? "bg-black"
              : theme === "light"
              ? "bg-gray-300"
              : "bg-gray-600"
          }`}
        >
          <span
            className={`absolute left-1 w-4 h-4 bg-white rounded-full shadow transform transition-transform ${
              dailyDigest ? "translate-x-6" : "translate-x-0"
            }`}
          />
        </button>
      </div>

      {/* Breaking News Alerts Toggle */}
      <div
        className={`flex items-center justify-between py-3 border-b transition-colors ${
          theme === "light" ? "border-gray-100" : "border-gray-600"
        }`}
      >
        <div>
          <h2 className={`font-semibold ${theme === "light" ? "text-gray-800" : "text-white"}`}>
            Breaking News Alerts
          </h2>
          <p className={`text-sm ${theme === "light" ? "text-gray-500" : "text-gray-300"}`}>
            Get notified about urgent news updates
          </p>
        </div>
        <button
          onClick={() => setBreakingNews(!breakingNews)}
          className={`relative w-12 h-6 flex items-center rounded-full transition-colors ${
            breakingNews
              ? "bg-black"
              : theme === "light"
              ? "bg-gray-300"
              : "bg-gray-600"
          }`}
        >
          <span
            className={`absolute left-1 w-4 h-4 bg-white rounded-full shadow transform transition-transform ${
              breakingNews ? "translate-x-6" : "translate-x-0"
            }`}
          />
        </button>
      </div>

      {/* Daily Digest Time Selector */}
      <div className="py-4">
        <label className={`block text-sm font-medium mb-2 ${theme === "light" ? "text-gray-700" : "text-gray-300"}`}>
          Daily Digest Time
        </label>
        <select
          value={digestTime}
          onChange={(e) => setDigestTime(e.target.value)}
          className={`w-full border rounded-lg p-2 focus:ring-2 focus:outline-none transition-colors ${
            theme === "light"
              ? "border-gray-300 text-gray-700 focus:ring-black bg-white"
              : "border-gray-600 text-white focus:ring-gray-500 bg-gray-700"
          }`}
        >
          {times.map((time, idx) => (
            <option key={idx} value={time}>
              {time}
            </option>
          ))}
        </select>
      </div>
    </div>
  );
}
