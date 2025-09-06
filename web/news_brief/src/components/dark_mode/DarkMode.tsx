"use client";
import { ThemeContext } from "@/app/contexts/ThemeContext";
import { Moon, Sun } from "lucide-react";
import React, { useContext } from "react";

const DarkMode = () => {
  const context = useContext(ThemeContext);
  if (!context)
    throw new Error("ToggleButton must be used inside ThemeProvider");
  const { theme, setTheme } = context;

  return (
    <>
      <button onClick={() => setTheme(theme == "light" ? "dark" : "light")}>
        {theme == "light" ? <Moon /> : <Sun />}
      </button>
    </>
  );
};

export default DarkMode;
