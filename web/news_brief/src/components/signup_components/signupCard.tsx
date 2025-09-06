"use client";
import React, { useState, useEffect, useContext } from "react";
import Image from "next/image";
import { Eye, EyeOff } from "lucide-react";
import { apiClient, Topic } from "../../lib/api";
import { ThemeContext } from "@/app/contexts/ThemeContext";
import { useTranslation } from "react-i18next";

interface SignUpCardProps {
  onClose?: () => void;
  onSwitchToSignIn?: () => void;
}

const STORAGE_KEY = "selectedInterests";

const SignUpCard: React.FC<SignUpCardProps> = ({
  onClose,
  onSwitchToSignIn,
}) => {
  const { t } = useTranslation();
  const context = useContext(ThemeContext);
  if (!context) throw new Error("SignUpCard must be used inside ThemeProvider");
  const { theme } = context;

  const [fullName, setFullName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const [success, setSuccess] = useState("");
  const [showPasswordMessage, setShowPasswordMessage] = useState(false);
  const [showInterestSelection, setShowInterestSelection] = useState(false);

  const [topics, setTopics] = useState<Topic[]>([]);
  const [selectedInterests, setSelectedInterests] = useState<string[]>(() => {
    if (typeof window !== "undefined") {
      const stored = localStorage.getItem(STORAGE_KEY);
      return stored ? JSON.parse(stored) : [];
    }
    return [];
  });

  // Remove old user data on mount
  useEffect(() => {
    localStorage.removeItem("person");
  }, []);

  const getPasswordMessage = (pwd: string) => {
    const messages: string[] = [];
    const parts = t("auth.passwordRequirements").split(",");
    if (pwd.length < 8) messages.push(parts[0]);
    if (!/[A-Z]/.test(pwd)) messages.push(parts[1]);
    if (!/[a-z]/.test(pwd)) messages.push(parts[2]);
    if (!/\d/.test(pwd)) messages.push(parts[3]);
    if (!/[!@#$%^&*(),.?":{}|<>]/.test(pwd)) messages.push(parts[4]);
    return messages.length
      ? t("auth.passwordRequirements").split(":")[0] +
          " " +
          messages.join(", ") +
          "."
      : "";
  };

  const handleSignUp = async () => {
    if (password !== confirmPassword) {
      setError(t("auth.passwordsDoNotMatch"));
      return;
    }
    if (getPasswordMessage(password) !== "") {
      setError(t("auth.passwordDoesNotMeetRequirements"));
      return;
    }

    setLoading(true);
    setError("");
    setSuccess("");

    try {
      const res = await apiClient.signUp(fullName, email, password);

      if (res.status_code === 201) {
        setSuccess(res.message || t("auth.userCreatedSuccess"));

        // Load topics from API
        const topicsData = await apiClient.getTopics();
        setTopics(topicsData);

        setShowInterestSelection(true);
      }

      setFullName("");
      setEmail("");
      setPassword("");
      setConfirmPassword("");
      setShowPasswordMessage(false);
    } catch (err: unknown) {
      if (err instanceof Error) {
        const statusError = err as Error & { statusCode?: number };
        if (statusError.statusCode === 409)
          setError(t("auth.accountAlreadyRegistered"));
        else setError(statusError.message);
      } else setError(t("auth.somethingWentWrong"));
    } finally {
      setLoading(false);
    }
  };

  const toggleInterest = (interest: string) => {
    setSelectedInterests((prev) => {
      const updated = prev.includes(interest)
        ? prev.filter((i) => i !== interest)
        : [...prev, interest];
      localStorage.setItem(STORAGE_KEY, JSON.stringify(updated));
      return updated;
    });
  };

  // Tailwind theme classes
  const bgCard = theme === "light" ? "bg-gray-50" : "bg-gray-900";
  const textMain = theme === "light" ? "text-gray-900" : "text-gray-100";
  const textSecondary = theme === "light" ? "text-gray-500" : "text-gray-400";
  const inputBase = `w-full mb-3 px-4 py-3 rounded-xl border focus:ring-2 focus:ring-blue-500 focus:outline-none transition-colors`;
  const inputBg =
    theme === "light"
      ? "bg-gray-50 border-gray-200 text-black placeholder-gray-500"
      : "bg-gray-800 border-gray-700 text-white placeholder-gray-400";
  const btnPrimary =
    theme === "light"
      ? "bg-black text-white hover:bg-gray-800"
      : "bg-white text-black hover:bg-gray-200";
  const btnGoogle =
    theme === "light"
      ? "text-black border border-gray-300 hover:bg-gray-100"
      : "text-white border border-gray-600 hover:bg-gray-700";

  const passwordMessage = getPasswordMessage(password);

// Interest button styles
const interestBase =
  "cursor-pointer px-4 py-2 rounded-3xl border-2 text-center font-medium transition-all w-[140px]";

// Dark mode: selected = black bg, white text; hover = dark gray
// Light mode: selected = white bg, black text; hover = light gray
const selectedClasses =
  theme === "dark"
    ? "bg-white text-black border-white hover:bg-gray-200"
    : "bg-black text-white border-black hover:bg-gray-800";

const unselectedClasses =
  theme === "dark"
    ? "bg-gray-800 text-gray-300 border-gray-700 hover:bg-gray-700"
    : "bg-gray-100 text-gray-700 border-gray-300 hover:bg-gray-200";

  return (
    <div
      className={`relative w-full max-w-md sm:max-w-lg mx-3 sm:mx-auto rounded-2xl shadow-xl p-4 sm:p-8 ${bgCard} transition-all duration-300`}
    >
      {!showInterestSelection ? (
        <>
          {onClose && (
            <button
              onClick={onClose}
              className="absolute top-3 right-3 text-gray-500 hover:text-gray-700 dark:hover:text-gray-200 text-xl font-bold"
            >
              ✕
            </button>
          )}

          <h1
            className={`text-xl sm:text-2xl font-bold text-center mb-4 sm:mb-6 ${textMain}`}
          >
            {t("auth.signup")}
          </h1>

          {success && (
            <p className="text-green-600 text-center mb-3 text-sm sm:text-base">
              {success}
            </p>
          )}
          {error && (
            <p className="text-red-500 text-center mb-3 text-sm sm:text-base">
              {error}
            </p>
          )}

          <input
            type="text"
            placeholder={t("auth.fullName")}
            value={fullName}
            onChange={(e) => setFullName(e.target.value)}
            className={`${inputBase} ${inputBg} text-sm sm:text-base`}
          />
          <input
            type="email"
            placeholder={t("auth.email")}
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            className={`${inputBase} ${inputBg} text-sm sm:text-base`}
          />

          <div className="relative">
            <input
              type={showPassword ? "text" : "password"}
              placeholder={t("auth.password")}
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              onFocus={() => setShowPasswordMessage(true)}
              className={`${inputBase} ${inputBg} pr-10 text-sm sm:text-base`}
            />
            {password && (
              <button
                type="button"
                onClick={() => setShowPassword(!showPassword)}
                className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-500"
              >
                {showPassword ? <EyeOff size={18} /> : <Eye size={18} />}
              </button>
            )}
          </div>
          {showPasswordMessage && passwordMessage && (
            <p className="text-red-500 text-xs sm:text-sm mb-4">
              {passwordMessage}
            </p>
          )}

          <div className="relative mb-4 sm:mb-6">
            <input
              type={showConfirmPassword ? "text" : "password"}
              placeholder={t("auth.confirmPassword")}
              value={confirmPassword}
              onChange={(e) => setConfirmPassword(e.target.value)}
              className={`${inputBase} ${inputBg} pr-10 text-sm sm:text-base`}
            />
            {confirmPassword && (
              <button
                type="button"
                onClick={() => setShowConfirmPassword(!showConfirmPassword)}
                className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-500"
              >
                {showConfirmPassword ? <EyeOff size={18} /> : <Eye size={18} />}
              </button>
            )}
          </div>

          <button
            onClick={handleSignUp}
            disabled={loading}
            className={`w-full py-3 rounded-[30px] font-semibold ${btnPrimary} disabled:opacity-50 text-sm sm:text-base mb-4`}
          >
            {loading ? t("auth.signingUp") : t("auth.signup")}
          </button>

          <div className="flex items-center my-3 sm:my-6">
            <hr className="flex-1 border-gray-300 dark:border-gray-700" />
            <span
              className={`px-2 sm:px-3 text-xs sm:text-sm ${textSecondary}`}
            >
              OR
            </span>
            <hr className="flex-1 border-gray-300 dark:border-gray-700" />
          </div>

          <button
            onClick={() => apiClient.signInWithGoogle()}
            className={`w-full border py-3 rounded-[30px] flex items-center justify-center gap-2 sm:gap-3 font-medium ${btnGoogle} text-sm sm:text-base`}
          >
            <Image
              src="/images/google.png"
              width={24}
              height={24}
              alt="Google Logo"
            />
            {t("auth.continueWithGoogle")}
          </button>

          <div className="mt-4 sm:mt-6 text-center">
            <p className={`text-sm sm:text-base ${textSecondary}`}>
              {t("auth.alreadyHaveAccount")}{" "}
              <button
                onClick={() => setTimeout(() => onSwitchToSignIn?.(), 100)}
                className={`font-medium hover:underline ${textMain}`}
              >
                {t("auth.login")}
              </button>
            </p>
          </div>
        </>
      ) : (
        <div className="mt-6">
          <h2 className={`text-lg font-semibold mb-3 ${textMain}`}>
            {t("auth.selectYourInterests")}
          </h2>
          <div className="flex flex-wrap gap-3">
            {topics.length > 0 ? (
              topics.map((topic) => {
                const isSelected = selectedInterests.includes(topic.id);
                return (
                  <div
                    key={topic.id}
                    onClick={() => toggleInterest(topic.id)}
                    className={`${interestBase} ${
                      isSelected ? selectedClasses : unselectedClasses
                    }`}
                  >
                    {topic.label.en}
                  </div>
                );
              })
            ) : (
              <p
                className={`text-sm ${
                  theme === "dark" ? "text-gray-400" : "text-gray-500"
                }`}
              >
                Loading topics...
              </p>
            )}
          </div>
          
          {selectedInterests.length > 0 && selectedInterests.length < 2 && (
            <p className="text-red-500 text-sm mt-2">
              Please select at least 2 topics to continue
            </p>
          )}
          <button
            onClick={async () => {
              if (selectedInterests.length < 2) {
                setError("Please select at least 2 topics to continue");
                return;
              }
              
              try {
                // Post topics to backend
                await apiClient.saveUserTopics(selectedInterests);
                console.log("Topics saved to backend successfully");
              } catch (error) {
                console.error("Error saving topics to backend:", error);
                // Continue anyway - we'll still save to localStorage
                console.log("Continuing with localStorage only");
              }
              
              // Always update localStorage with user data including topics
              const personData = localStorage.getItem("person");
              if (personData) {
                const parsed = JSON.parse(personData);
                parsed.user.preferences.topics = selectedInterests;
                localStorage.setItem("person", JSON.stringify(parsed));
                console.log("Topics saved to localStorage");
              }
              
              // Clear temporary storage
              localStorage.removeItem(STORAGE_KEY);
              
              // Redirect to news page
              window.location.href = "/news";
            }}
            className={`mt-4 w-full py-3 rounded-[30px] font-semibold ${btnPrimary} ${
              selectedInterests.length < 2 ? 'opacity-50 cursor-not-allowed' : ''
            }`}
            disabled={selectedInterests.length < 2}
          >
            {t("auth.continue")} ({selectedInterests.length}/2+)
          </button>
        </div>
      )}
    </div>
  );
};

export default SignUpCard;
