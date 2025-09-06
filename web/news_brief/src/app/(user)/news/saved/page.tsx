"use client";
import React, { useContext } from "react";
import TopBar from "@/components/reusable_components/search_topbar";

import ChatBot from "@/components/reusable_components/Generalchatbot";

import { ThemeContext } from "@/app/contexts/ThemeContext";
import SavedNewsComp from "@/components/news_component/SavedNewsComp";


const News = () => {
  const context = useContext(ThemeContext);

  if (!context)
    throw new Error("ToggleButton must be used inside ThemeProvider");
  const { theme } = context;

  return (
    <>
      <ChatBot />
      <div
        className={`flex flex-col lg:flex-row gap-5 min-h-screen w-full transition-colors ${
          theme === "light" ? "bg-white text-black" : "bg-gray-900 text-white"
        }`}
      >
        <div className="flex-1 lg:ml-0 lg:mt-1  px-4 lg:px-6 lg:mr-10 w-full overflow-hidden">
          <div className="flex justify-between w-full mb-4">
            <TopBar />
          </div>
          <SavedNewsComp/>
        </div>
      </div>
    </>
  );
};

export default News;
