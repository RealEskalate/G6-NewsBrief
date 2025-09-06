"use client";

import React, { useState, useEffect } from "react";
import { Eye, EyeOff } from "lucide-react";
import { useSearchParams, useRouter } from "next/navigation";
import { apiClient } from "../../lib/api"; // adjust path if needed

export default function ResetPasswordForm() {
  const searchParams = useSearchParams();
  const router = useRouter();

  const token = searchParams.get("token") || "";
  const verifier = searchParams.get("verifier") || "";

  const [password, setPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);
  const [showPasswordMessage, setShowPasswordMessage] = useState(false);

  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const [success, setSuccess] = useState("");

  // ✅ Password validation rules
  const getPasswordMessage = (pwd: string) => {
    const messages: string[] = [];
    if (pwd.length < 8) messages.push("at least 8 characters");
    if (!/[A-Z]/.test(pwd)) messages.push("an uppercase letter");
    if (!/[a-z]/.test(pwd)) messages.push("a lowercase letter");
    if (!/\d/.test(pwd)) messages.push("a number");
    if (!/[!@#$%^&*(),.?\":{}|<>]/.test(pwd))
      messages.push("a special character");

    if (messages.length === 0) return "";
    return "Password must include " + messages.join(", ") + ".";
  };

  const passwordMessage = getPasswordMessage(password);

  useEffect(() => {
    if (!token || !verifier) {
      setError("Invalid or missing reset link ❌");
    }
  }, [token, verifier]);

  const handleSubmit = async () => {
    if (!token || !verifier) {
      setError("Missing reset credentials ❌");
      return;
    }

    if (password !== confirmPassword) {
      setError("Passwords do not match ❌");
      return;
    }

    if (passwordMessage !== "") {
      setError("Password does not meet all requirements ❌");
      return;
    }

    setLoading(true);
    setError("");
    setSuccess("");

    try {
      const res = await apiClient.resetPassword(verifier, token, password);
      setSuccess(res.message || "Password reset successfully ✅");

      // clear input fields
      setPassword("");
      setConfirmPassword("");
      setShowPasswordMessage(false);

      setTimeout(() => router.push("/"), 1500);
    } catch (err: unknown) {
      if (err instanceof Error) {
        setError(err.message);
      } else {
        setError("Something went wrong ❌");
      }
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="relative w-full max-w-xs sm:max-w-sm mx-auto rounded-xl shadow-lg p-4 sm:p-5 bg-gray-50 transition-all duration-300">
      <h1 className="text-lg sm:text-xl font-bold text-center text-gray-900 mb-4">
        Reset Your Password
      </h1>

      {success && (
        <p className="text-green-600 text-center mb-2 text-xs sm:text-sm">
          {success}
        </p>
      )}
      {error && (
        <p className="text-red-500 text-center mb-2 text-xs sm:text-sm">
          {error}
        </p>
      )}

      {/* Password */}
      <div className="relative mb-2">
        <input
          type={showPassword ? "text" : "password"}
          placeholder="New Password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          onFocus={() => setShowPasswordMessage(true)}
          className="w-full px-3 py-2 rounded-lg border border-gray-200 bg-gray-50 pr-10 text-xs sm:text-sm"
        />
        {password && (
          <button
            type="button"
            onClick={() => setShowPassword(!showPassword)}
            className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-500"
          >
            {showPassword ? <EyeOff size={16} /> : <Eye size={16} />}
          </button>
        )}
      </div>

      {/* Live password validation */}
      {showPasswordMessage && passwordMessage && (
        <p className="text-red-500 text-xs mb-3">{passwordMessage}</p>
      )}

      {/* Confirm Password */}
      <div className="relative mb-4">
        <input
          type={showConfirmPassword ? "text" : "password"}
          placeholder="Confirm Password"
          value={confirmPassword}
          onChange={(e) => setConfirmPassword(e.target.value)}
          className="w-full px-3 py-2 rounded-lg border border-gray-200 bg-gray-50 pr-10 text-xs sm:text-sm"
        />
        {confirmPassword && (
          <button
            type="button"
            onClick={() => setShowConfirmPassword(!showConfirmPassword)}
            className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-500"
          >
            {showConfirmPassword ? <EyeOff size={16} /> : <Eye size={16} />}
          </button>
        )}
      </div>

      <button
        onClick={handleSubmit}
        disabled={loading}
        className="w-full bg-black text-white py-2 rounded-[20px] font-semibold hover:bg-gray-900 disabled:opacity-50 text-xs sm:text-sm"
      >
        {loading ? "Resetting..." : "Reset Password"}
      </button>
    </div>
  );
}
