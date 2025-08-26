// components/Sidebar.js
"use client";
import { useState } from "react";
import Link from "next/link";
import Image from "next/image";
const Sidebar = () => {
  const [activeItem, setActiveItem] = useState("Home");

  const handleItemClick = (itemName: string) => {
    setActiveItem(itemName);
  };

  return (
    <div className="w-64 bg-white text-black min-h-screen flex flex-col  p-2 rounded-lg shadow-md">
      {/* Header with News Brief */}
      <div className="flex items-center space-x-4 m-4">
        <div className="">
          <Image
            src="/logo.png"
            alt="News Brief Logo"
            width={36}
            height={36}
            className="rounded-md"
          />
        </div>
        <h1 className="text-2xl md:text-3xl font-bold">News Brief</h1>
      </div>

      {/* Navigation Menu */}
      <nav className="flex-1 p-4">
        <ul className="space-y-2">
          {[
            "Home",
            "Foryou",
            "Subscribed",
            "Saved News",
            "Setting",
            "Profile",
          ].map((item) => (
            <li key={item}>
              <Link
                // href={`/${item.toLowerCase().replace(" ", "-")}`}
                href={`/`}
                className={`flex items-center px-4 py-3 rounded-md transition-colors ${
                  activeItem === item
                    ? "bg-[#F3F4F6] text-black"
                    : "text-black hover:[#dddfe2]"
                }`}
                onClick={() => handleItemClick(item)}
              >
                <span className="mr-3 w-5 h-5 flex items-center justify-center">
                  {item === "Home" && (
                    <svg
                      xmlns="http://www.w3.org/2000/svg"
                      width="20"
                      height="20"
                      viewBox="0 0 24 24"
                      fill="currentColor"
                    >
                      <path d="M4 21V9l8-6l8 6v12h-6v-7h-4v7z" />
                    </svg>
                  )}
                  {item === "Foryou" && (
                    <svg
                      xmlns="http://www.w3.org/2000/svg"
                      width="20"
                      height="20"
                      viewBox="0 0 24 24"
                      fill="currentColor"
                    >
                      <path d="M3 3v18h18V3H3zm16 16H5V5h14v14zM9 8h2v8H9zm4 0h2v8h-2z" />
                    </svg>
                  )}
                  {item === "Subscribed" && (
                    <svg
                      xmlns="http://www.w3.org/2000/svg"
                      width="20"
                      height="20"
                      viewBox="0 0 24 24"
                      fill="currentColor"
                    >
                      <path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z" />
                    </svg>
                  )}
                  {item === "Saved News" && (
                    <svg
                      xmlns="http://www.w3.org/2000/svg"
                      width="20"
                      height="20"
                      viewBox="0 0 24 24"
                      fill="currentColor"
                    >
                      <path d="M17 3H7c-1.1 0-1.99.9-1.99 2L5 21l7-3 7 3V5c0-1.1-.9-2-2-2z" />
                    </svg>
                  )}
                  {item === "Setting" && (
                    <svg
                      xmlns="http://www.w3.org/2000/svg"
                      width="20"
                      height="20"
                      viewBox="0 0 24 24"
                      fill="currentColor"
                    >
                      <path d="M19.14 12.94c.04-.3.06-.61.06-.94 0-.32-.02-.64-.07-.94l2.03-1.58c.18-.14.23-.41.12-.61l-1.92-3.32c-.12-.22-.37-.29-.59-.22l-2.39.96c-.5-.38-1.03-.7-1.62-.94l-.36-2.54c-.04-.24-.24-.41-.48-.41h-3.84c-.24 0-.43.17-.47.41l-.36 2.54c-.59.24-1.13.57-1.62.94l-2.39-.96c-.22-.08-.47 0-.59.22L2.74 8.87c-.12.21-.08.47.12.61l2.03 1.58c-.05.3-.09.63-.09.94s.02.64.07.94l-2.03 1.58c-.18.14-.23.41-.12.61l1.92 3.32c.12.22.37.29.59.22l2.39-.96c.5.38 1.03.7 1.62.94l.36 2.54c.05.24.24.41.48.41h3.84c.24 0 .44-.17.47-.41l.36-2.54c.59-.24 1.13-.56 1.62-.94l2.39.96c.22.08.47 0 .59-.22l1.92-3.32c.12-.22.07-.47-.12-.61l-2.01-1.58zM12 15.6c-1.98 0-3.6-1.62-3.6-3.6s1.62-3.6 3.6-3.6 3.6 1.62 3.6 3.6-1.62 3.6-3.6 3.6z" />
                    </svg>
                  )}
                  {item === "Profile" && (
                    <svg
                      xmlns="http://www.w3.org/2000/svg"
                      width="20"
                      height="20"
                      viewBox="0 0 24 24"
                      fill="currentColor"
                    >
                      <path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z" />
                    </svg>
                  )}
                </span>
                {item}
              </Link>
            </li>
          ))}
        </ul>
      </nav>
    </div>
  );
};

export default Sidebar;
