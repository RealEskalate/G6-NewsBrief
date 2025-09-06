"use client";
import React, { useContext, useState } from "react";
import { Bell, Globe } from "lucide-react";
import Button from "./Button";
import SignInCard from "../signin_components/siginCard";
import SignUpCard from "../signup_components/signupCard";
import ForgotPasswordCard from "../../components/forgotpassword_components/forgotpassCard";
import { ThemeContext } from "@/app/contexts/ThemeContext";
import { getAccessToken } from "@/lib/api";
import DarkMode from "../dark_mode/DarkMode";
import ProfileDropdown from "./DropDownBar";
import Link from "next/link";
import { useTranslation } from "react-i18next";

const token = getAccessToken();

export default function TopBar() {
  const context = useContext(ThemeContext);
  if (!context) throw new Error("TopBar must be used inside ThemeProvider");
  const { theme } = context;

  const { t, i18n } = useTranslation();

  const [open, setOpen] = useState(false);
  const [view, setView] = useState<"signin" | "signup" | "forgot">("signin");

  const bgBtn =
    theme === "light"
      ? "hover:bg-gray-200 text-black"
      : "hover:bg-gray-700 text-white";

  const handleLanguageChange = (e: React.ChangeEvent<HTMLSelectElement>) => {
    i18n.changeLanguage(e.target.value);
  };

  return (
    <>
      <header
        className={`w-full sticky top-0 z-20 transition-colors ${
          theme === "light" ? "bg-white text-black" : "bg-gray-900 text-white"
        }`}
      >
        <div className="max-w-7xl mx-auto px-4 py-3 flex items-center justify-between">
          {/* Logo */}
          <Link href="/" className="flex items-center gap-2">
            <img src="/logo.png" className="w-6" alt="logo" />
            <p className="font-semibold hidden sm:block">News Brief</p>
          </Link>

          {/* Right Actions */}
          <div className="flex items-center gap-3 flex-shrink-0">
            {/* Dark Mode toggle */}
            <div className="hidden sm:block">
              <DarkMode />
            </div>

            {/* Notifications */}


            {/* Language Dropdown */}
            <div className="relative">
              <select
                className={`appearance-none pr-6 cursor-pointer text-sm outline-none rounded-md border px-2 py-1 ${
                  theme === "light"
                    ? "bg-white text-black border-gray-300 hover:bg-gray-100"
                    : "bg-gray-800 text-white border-gray-600 hover:bg-gray-700"
                }`}
                value={i18n.language}
                onChange={handleLanguageChange}
              >
                <option value="en">{t("languages.english")}</option>
                <option value="am">{t("languages.amharic")}</option>
              </select>
              <Globe
                size={16}
                className={`absolute right-2 top-1/2 -translate-y-1/2 pointer-events-none ${
                  theme === "light" ? "text-black" : "text-white"
                }`}
              />
            </div>

            {/* Login / Profile */}
            {!token ? (
              <Button
                variant="primary"
                className="rounded-lg px-4 py-1.5 text-sm"
                onClick={() => {
                  setOpen(true);
                  setView("signin");
                }}
              >
                {t("auth.login")}
              </Button>
            ) : (
              <ProfileDropdown
                onLogoutClick={() => {
                  setView("signin");
                  setOpen(true);
                }}
              />
            )}
          </div>
        </div>
      </header>

      {/* Auth Modal */}
      {open && (
        <div className="fixed inset-0 bg-black/40 flex items-center justify-center z-50">
          {view === "signin" && (
            <SignInCard
              onClose={() => setOpen(false)}
              onSwitchToSignUp={() => setView("signup")}
              onSwitchToForgot={() => setView("forgot")}
            />
          )}
          {view === "signup" && (
            <SignUpCard
              onClose={() => setOpen(false)}
              onSwitchToSignIn={() => setView("signin")}
            />
          )}
          {view === "forgot" && (
            <ForgotPasswordCard
              onClose={() => setOpen(false)}
              onBackToSignIn={() => setView("signin")}
            />
          )}
        </div>
      )}
    </>
  );
}
