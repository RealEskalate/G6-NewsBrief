"use client";
import React from "react";
import TopBar from "@/components/reusable_components/search_topbar";
import ChatBot from "@/components/reusable_components/Generalchatbot";
import ForyouComponent from "@/components/news_component/foryouComponent";
import { ThemeContext } from "@/app/contexts/ThemeContext";
import { useContext } from "react";

export default function ForYouPage() {
  const context = useContext(ThemeContext);
  if (!context) throw new Error("ForYouPage must be used inside ThemeProvider");
  const { theme } = context;

  return (
    <>
      <ChatBot />
      <div
        className={`flex flex-col lg:flex-row gap-5 min-h-screen w-full transition-colors duration-300 ${
          theme === "light" ? "bg-white text-black" : "bg-gray-900 text-white"
        }`}
      >
        <div className="flex-1 lg:ml-0 lg:mt-1 px-4 lg:px-6 lg:mr-10 w-full overflow-hidden">
          {/* Top Bar aligned consistently with News page */}
          <div className="flex justify-between w-full mb-4">
            <TopBar />
          </div>

          {/* For You Content */}
          <ForyouComponent />
        </div>
      </div>
    </>
  );
}
