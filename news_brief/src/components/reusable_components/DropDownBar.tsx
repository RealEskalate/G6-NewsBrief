import { useState, useRef, useEffect } from "react";
import Link from "next/link";
import { LogOut, User, Bookmark, Settings, Bell } from "lucide-react";

interface ProfileDropdownProps {
  onLogoutClick: () => void;
}

function ProfileDropdown({ onLogoutClick }: ProfileDropdownProps) {
  const [open, setOpen] = useState(false);
  const dropdownRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    function handleClickOutside(event: MouseEvent) {
      if (
        dropdownRef.current &&
        !dropdownRef.current.contains(event.target as Node)
      ) {
        setOpen(false);
      }
    }
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  return (
    <div className="relative" ref={dropdownRef}>
      <button
        className="flex items-center gap-2 px-3 py-1.5 rounded-lg bg-gray-100 text-sm font-medium hover:bg-gray-200"
        onClick={() => setOpen((prev) => !prev)}
      >
        <User size={16} />
        <span>Profile</span>
      </button>

      {open && (
        <div className="absolute right-0 mt-2 w-52 bg-gray-100 border border-gray-200 rounded-lg shadow-lg z-50 overflow-hidden">
          <ul className="text-sm">
            <li>
              <Link
                href="/foryou"
                className="flex items-center gap-2 px-4 py-2 hover:bg-gray-50"
              >
                <User size={14} /> For You
              </Link>
            </li>
            <li>
              <Link
                href="news/saved"
                className="flex items-center gap-2 px-4 py-2 hover:bg-gray-50"
              >
                <Bookmark size={14} /> Saved
              </Link>
            </li>
            <li>
              <Link
                href="/subscriptions"
                className="flex items-center gap-2 px-4 py-2 hover:bg-gray-50"
              >
                <Bell size={14} /> Subscriptions
              </Link>
            </li>
            <li>
              <Link
                href="/setting"
                className="flex items-center gap-2 px-4 py-2 hover:bg-gray-50"
              >
                <Settings size={14} /> Settings
              </Link>
            </li>
            <li>
              {/* Call the handler instead of navigating */}
              <button
                onClick={onLogoutClick}
                className="w-full text-left flex items-center gap-2 px-4 py-2 text-red-600 hover:bg-red-50"
              >
                <LogOut size={14} /> Logout
              </button>
            </li>
          </ul>
        </div>
      )}
    </div>
  );
}

export default ProfileDropdown;
