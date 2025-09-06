"use client";
import React, { ButtonHTMLAttributes, useContext } from "react";
import { ThemeContext } from "@/app/contexts/ThemeContext";

interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: "primary" | "secondary" | "tertiary";
  children: React.ReactNode;
  className?: string;
}

const Button: React.FC<ButtonProps> = ({ variant = "primary", children, className = "", ...props }) => {
  const context = useContext(ThemeContext);
  if (!context) throw new Error("Button must be used inside ThemeProvider");
  const { theme } = context;

  const baseClasses = "font-medium transition-colors duration-200 rounded-md px-4 py-2";

  let variantClasses = "";

  switch (variant) {
    case "primary":
      variantClasses =
        theme === "dark"
          ? "bg-[#27233A] text-black border border-gray-100 hover:bg-gray-600 hover:text-black"
          : "bg-[#27233A] text-white border border-black hover:bg-gray-600 hover:text-white";
      break;
    case "secondary":
      variantClasses =
        theme === "dark"
          ? "bg-gray-800 text-white border border-gray-700 hover:bg-gray-700 hover:text-white"
          : "bg-white text-black border border-black hover:bg-gray-100 hover:text-black";
      break;
    case "tertiary":
      variantClasses =
        theme === "dark"
          ? "bg-gray-700 text-white hover:bg-gray-600"
          : "bg-gray-200 text-black hover:bg-gray-300";
      break;
  }

  return (
    <button className={`${baseClasses} ${variantClasses} ${className}`} {...props}>
      {children}
    </button>
  );
};

export default Button;
