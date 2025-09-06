"use client";

import React, { useState, useContext } from "react";
import { apiClient } from "../../lib/api";
import { ThemeContext } from "@/app/contexts/ThemeContext";

interface ForgotPasswordCardProps {
  onClose?: () => void;
  onBackToSignIn?: () => void;
}

const ForgotPasswordCard: React.FC<ForgotPasswordCardProps> = ({ onClose, onBackToSignIn }) => {
  const context = useContext(ThemeContext);
  if (!context) throw new Error("ForgotPasswordCard must be used inside ThemeProvider");
  const { theme } = context;

  const [email, setEmail] = useState("");
  const [message, setMessage] = useState("");
  const [loading, setLoading] = useState(false);

  const handleSubmit = async () => {
    setLoading(true);
    setMessage("");
    try {
      const res = await apiClient.forgotPassword(email);
      setMessage(res.message || "Password reset link sent to your email.");
    } catch (err: unknown) {
      if (err instanceof Error) setMessage(err.message);
      else setMessage("Error sending reset link.");
    } finally {
      setLoading(false);
    }
  };

  // Theme-based classes
  const bgCard = theme === "light" ? "bg-gray-50" : "bg-gray-900";
  const textMain = theme === "light" ? "text-gray-900" : "text-gray-100";
  const textSecondary = theme === "light" ? "text-gray-500" : "text-gray-400";
  const inputBg =
    theme === "light"
      ? "bg-gray-50 border-gray-200 text-black placeholder-gray-500"
      : "bg-gray-800 border-gray-700 text-white placeholder-gray-400";
  const btnPrimary =
    theme === "light"
      ? "bg-black text-white hover:bg-gray-800"
      : "bg-white text-black hover:bg-gray-200";

  return (
    <div
      className={`relative w-full max-w-xs sm:max-w-sm mx-2 sm:mx-auto rounded-xl shadow-lg p-5 sm:p-6 ${bgCard} transition-all duration-300`}
    >
      {onClose && (
        <button
          onClick={onClose}
          className="absolute top-2 right-2 text-gray-500 hover:text-gray-700 dark:hover:text-gray-200 text-lg font-bold"
        >
          ✕
        </button>
      )}

      <h1 className={`text-lg sm:text-xl font-bold text-center mb-3 sm:mb-4 ${textMain}`}>
        Forgot Password
      </h1>

      <p className={`text-xs sm:text-sm mb-4 ${textSecondary} text-center`}>
        Enter your email and we’ll send you a link to reset your password.
      </p>

      <input
        type="email"
        placeholder="Email"
        value={email}
        onChange={(e) => setEmail(e.target.value)}
        className={`w-full mb-3 px-3 py-2 rounded-lg border ${inputBg} text-xs sm:text-sm focus:ring-2 focus:ring-blue-500 focus:outline-none`}
      />

      <button
        onClick={handleSubmit}
        disabled={loading}
        className={`w-full py-2 rounded-[20px] font-semibold ${btnPrimary} disabled:opacity-50 mb-3 text-xs sm:text-sm`}
      >
        {loading ? "Sending..." : "Send Reset Link"}
      </button>

      {message && (
        <p className={`mt-2 text-center text-xs sm:text-sm ${textSecondary}`}>{message}</p>
      )}

      <div className="mt-3 text-center">
        <button
          onClick={onBackToSignIn}
          className={`text-xs sm:text-sm font-medium hover:underline ${textMain}`}
        >
          ← Back to Sign In
        </button>
      </div>
    </div>
  );
};

export default ForgotPasswordCard;
