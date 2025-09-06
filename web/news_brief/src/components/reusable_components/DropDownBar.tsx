"use client";
import { useState, useRef, useEffect, useContext } from "react";
import Link from "next/link";
import { LogOut, User, Bookmark, Settings, Bell } from "lucide-react";
import { ThemeContext } from "@/app/contexts/ThemeContext";
import { useTranslation } from "react-i18next";

interface ProfileDropdownProps {
  onLogoutClick: () => void;
}

function ProfileDropdown({ onLogoutClick }: ProfileDropdownProps) {
  const [open, setOpen] = useState(false);
  const dropdownRef = useRef<HTMLDivElement>(null);

  const context = useContext(ThemeContext);
  if (!context) throw new Error("ProfileDropdown must be used inside ThemeProvider");
  const { theme } = context;

  const { t } = useTranslation();

  useEffect(() => {
    function handleClickOutside(event: MouseEvent) {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target as Node)) {
        setOpen(false);
      }
    }
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  // Theme-aware styles
  const buttonBg =
    theme === "dark"
      ? "bg-gray-800 hover:bg-gray-700 text-gray-100"
      : "bg-gray-100 hover:bg-gray-200 text-gray-900";

  const menuBg =
    theme === "dark"
      ? "bg-gray-800 border border-gray-700 text-gray-100"
      : "bg-gray-100 border border-gray-200 text-gray-900";

  const hoverItem = theme === "dark" ? "hover:bg-gray-700" : "hover:bg-gray-50";

  return (
    <div className="relative" ref={dropdownRef}>
      <button
        className={`flex items-center gap-2 px-3 py-1.5 rounded-lg text-sm font-medium transition-colors ${buttonBg}`}
        onClick={() => setOpen((prev) => !prev)}
      >
        <User size={16} />
        <span>{t("profile.menuTitle")}</span>
      </button>

      {open && (
        <div
          className={`absolute right-0 mt-2 w-52 rounded-lg shadow-lg z-50 overflow-hidden ${menuBg}`}
        >
          <ul className="text-sm">
            <li>
              <Link
                href="/foryou"
                className={`flex items-center gap-2 px-4 py-2 transition-colors ${hoverItem}`}
              >
                <User size={14} /> {t("profile.forYou")}
              </Link>
            </li>
            <li>
              <Link
                href="/news/saved"
                className={`flex items-center gap-2 px-4 py-2 transition-colors ${hoverItem}`}
              >
                <Bookmark size={14} /> {t("profile.saved")}
              </Link>
            </li>
            <li>
            </li>
            <li>
              <Link
                href="/setting"
                className={`flex items-center gap-2 px-4 py-2 transition-colors ${hoverItem}`}
              >
                <Settings size={14} /> {t("profile.settings")}
              </Link>
            </li>
            <li>
              <button
                onClick={onLogoutClick}
                className={`w-full text-left flex items-center gap-2 px-4 py-2 transition-colors ${
                  theme === "dark"
                    ? "text-red-400 hover:bg-gray-700"
                    : "text-red-600 hover:bg-red-50"
                }`}
              >
                <LogOut size={14} /> {t("profile.logout")}
              </button>
            </li>
          </ul>
        </div>
      )}
    </div>
  );
}

export default ProfileDropdown;
