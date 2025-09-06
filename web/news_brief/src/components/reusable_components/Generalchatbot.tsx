"use client";
import { ThemeContext } from "@/app/contexts/ThemeContext";
import { useState, useEffect, useContext } from "react";

interface ChatBotProps {
  defaultOpen?: boolean;
}

const ChatBot = ({ defaultOpen = false }: ChatBotProps) => {
  const context = useContext(ThemeContext);
  if (!context)
    throw new Error("ToggleButton must be used inside ThemeProvider");

  const [isOpen, setIsOpen] = useState(defaultOpen);
  const [isMobile, setIsMobile] = useState(false);
  const [messages, setMessages] = useState<
    { id: number; text: string; sender: "user" | "bot" }[]
  >([
    {
      id: 1,
      text: "Hi there! I'm Tim, your News Brief Assistant. How can I help you today?",
      sender: "bot",
    },
  ]);
  const [inputValue, setInputValue] = useState("");

  // Check if device is mobile and adjust default state
  useEffect(() => {
    const checkMobile = () => {
      setIsMobile(window.innerWidth < 1024); // lg breakpoint
    };

    checkMobile();
    window.addEventListener("resize", checkMobile);

    // For mobile devices, always start closed regardless of defaultOpen prop
    if (isMobile) {
      setIsOpen(false);
    }

    return () => window.removeEventListener("resize", checkMobile);
  }, [isMobile, defaultOpen]);

  // UPDATED: Send message -> call our Next.js proxy route (/api/chat)
  const handleSendMessage = async () => {
    if (inputValue.trim() === "") return;

    // 1) Render the user's message immediately
    const userInput = inputValue;
    setMessages((prev) => [
      ...prev,
      { id: prev.length + 1, text: userInput, sender: "user" },
    ]);
    setInputValue("");

    try {
      // 2) Call your proxy API route (avoids CORS)
      const res = await fetch("/api/chat", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ message: userInput }),
      });

      // 3) Handle non-OK response
      if (!res.ok) {
        const errorText = await res.text();
        throw new Error(
          errorText || `Request failed with status ${res.status}`
        );
      }

      // 4) Parse and display the bot's reply
      const data = await res.json();
      const reply =
        (data && (data.reply as string)) || "Sorry, I didn’t understand that.";

      setMessages((prev) => [
        ...prev,
        { id: Date.now(), text: reply, sender: "bot" },
      ]);
    } catch (err: unknown) {
      // 5) Show a friendly error in chat
      let errorMessage = "Something went wrong";
      if (err instanceof Error) {
        errorMessage = err.message;
      }

      setMessages((prev) => [
        ...prev,
        {
          id: Date.now(),
          text: `⚠️ Error: ${errorMessage}`,
          sender: "bot",
        },
      ]);
    }
  };

  const handleKeyPress = (e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.key === "Enter") {
      handleSendMessage();
    }
  };

  const handleClearMessages = () => {
    setMessages([
      {
        id: 1,
        text: "Hi there! I'm Tim, your News Brief Assistant. How can I help you today?",
        sender: "bot",
      },
    ]);
  };

  return (
    <div className="fixed bottom-4 right-4 lg:bottom-6 lg:right-6  z-50 pointer-events-auto">
      {!isOpen && (
        <button
          onClick={() => setIsOpen(true)}
          className="bg-black text-white px-3 py-2 lg:px-4 lg:py-3 rounded-full hover:bg-gray-800 transition-all duration-300 flex items-center justify-center shadow-xl hover:shadow-2xl text-sm font-medium"
          aria-label="Open chat"
        >
          <svg
            xmlns="http://www.w3.org/2000/svg"
            className="h-6 w-6 lg:h-8 lg:w-8"
            fill="none"
            viewBox="0 0 24 24"
            stroke="currentColor"
          >
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth={2}
              d="M8 10h.01M12 10h.01M16 10h.01M9 16H5a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v8a2 2 0 01-2 2h-5l-5 5v-5z"
            />
          </svg>
        </button>
      )}

      {isOpen && (
        <div className="bg-white rounded-xl shadow-xl w-80 lg:w-72 h-96 lg:h-[28rem] flex flex-col overflow-hidden border border-gray-200 animate-fade-in-up">
          {/* Header */}
          <div className="bg-gradient-to-r from-gray-900 to-black text-white p-3 flex justify-between items-center shadow-md">
            <h3 className="font-bold text-xs lg:text-sm tracking-wide">
              NEWS BRIEF ASSISTANT
            </h3>
            <div className="flex space-x-1">
              <button
                onClick={handleClearMessages}
                className="text-white hover:text-gray-300 transition-colors p-1 rounded-full hover:bg-gray-800"
                aria-label="Clear chat messages"
                title="Clear chat"
              >
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  width="16"
                  height="16"
                  viewBox="0 0 24 24"
                >
                  <path
                    fill="#fff"
                    d="M19 4h-3.5l-1-1h-5l-1 1H5v2h14M6 19a2 2 0 0 0 2 2h8a2 2 0 0 0 2-2V7H6z"
                  />
                </svg>
              </button>

              <button
                onClick={() => setIsOpen(false)}
                className="text-white hover:text-gray-300 transition-colors p-1 rounded-full hover:bg-gray-800"
                aria-label="Close chat"
              >
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  className="h-5 w-5"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={2}
                    d="M6 18L18 6M6 6l12 12"
                  />
                </svg>
              </button>
            </div>
          </div>

          {/* Messages Container - More height for messages */}
          <div className="flex-1 p-3 overflow-y-auto bg-gray-50">
            <div className="space-y-3">
              {messages.map((message) => (
                <div
                  key={message.id}
                  className={`flex ${
                    message.sender === "user" ? "justify-end" : "justify-start"
                  }`}
                >
                  <div
                    className={`max-w-[85%] rounded-2xl px-3 py-2 ${
                      message.sender === "user"
                        ? "bg-black text-white rounded-br-md shadow-sm"
                        : "bg-white text-gray-800 rounded-bl-md border border-gray-200 shadow-sm"
                    }`}
                  >
                    <div className="flex items-start space-x-2">
                      {message.sender === "bot" && (
                        <div className="w-5 h-5 rounded-full bg-gray-800 flex items-center justify-center flex-shrink-0">
                          <span className="text-xs text-white font-bold">
                            T
                          </span>
                        </div>
                      )}
                      <p className="text-xs">{message.text}</p>
                      {message.sender == "user" && (
                        <button
                          className="text-gray-500 hover:text-gray-700"
                          aria-label="Listen to message"
                        >
                          <svg
                            xmlns="http://www.w3.org/2000/svg"
                            width="16"
                            height="16"
                            viewBox="0 0 1024 1024"
                            className="transition-transform hover:scale-110"
                          >
                            <path
                              fill="#fff"
                              d="M512 624c93.9 0 170-75.2 170-168V232c0-92.8-76.1-168-170-168s-170 75.2-170 168v224c0 92.8 76.1 168 170 168m330-170c0-4.4-3.6-8-8-8h-60c-4.4 0-8 3.6-8 8c0 140.3-113.7 254-254 254S258 594.3 258 454c0-4.4-3.6-8-8-8h-60c-4.4 0-8 3.6-8 8c0 168.7 126.6 307.9 290 327.6V884H326.7c-13.7 0-24.7 14.3-24.7 32v36c0 4.4 2.8 8 6.2 8h407.6c3.4 0 6.2-3.6 6.2-8v-36c0-17.7-11-32-24.7-32H548V782.1c165.3-18 294-158 294-328.1"
                            />
                          </svg>
                        </button>
                      )}
                      {message.sender === "bot" && (
                        <button
                          className="text-gray-500 hover:text-gray-700"
                          aria-label="Listen to message"
                        >
                          <svg
                            xmlns="http://www.w3.org/2000/svg"
                            width="16"
                            height="16"
                            viewBox="0 0 1024 1024"
                            className="transition-transform hover:scale-110"
                          >
                            <path
                              fill="currentColor"
                              d="M512 624c93.9 0 170-75.2 170-168V232c0-92.8-76.1-168-170-168s-170 75.2-170 168v224c0 92.8 76.1 168 170 168m330-170c0-4.4-3.6-8-8-8h-60c-4.4 0-8 3.6-8 8c0 140.3-113.7 254-254 254S258 594.3 258 454c0-4.4-3.6-8-8-8h-60c-4.4 0-8 3.6-8 8c0 168.7 126.6 307.9 290 327.6V884H326.7c-13.7 0-24.7 14.3-24.7 32v36c0 4.4 2.8 8 6.2 8h407.6c3.4 0 6.2-3.6 6.2-8v-36c0-17.7-11-32-24.7-32H548V782.1c165.3-18 294-158 294-328.1"
                            />
                          </svg>
                        </button>
                      )}
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>
          {/* Input Area */}
          <div className="border-t border-gray-200 p-3 bg-white">
            <div className="flex items-center space-x-2">
              <div className="flex-1 relative">
                <input
                  type="text"
                  value={inputValue}
                  onChange={(e) => setInputValue(e.target.value)}
                  onKeyPress={handleKeyPress}
                  placeholder="Type your message here..."
                  className="w-full border border-gray-300 rounded-full px-3 py-2 pr-8 focus:outline-none focus:ring-2 focus:ring-black focus:border-transparent text-xs"
                />
                <button className="absolute right-2 top-1/2 transform -translate-y-1/2 text-gray-500 hover:text-gray-700">
                  <svg
                    xmlns="http://www.w3.org/2000/svg"
                    width="16"
                    height="16"
                    viewBox="0 0 1024 1024"
                    className="transition-transform hover:scale-110"
                  >
                    <path
                      fill="currentColor"
                      d="M512 624c93.9 0 170-75.2 170-168V232c0-92.8-76.1-168-170-168s-170 75.2-170 168v224c0 92.8 76.1 168 170 168m330-170c0-4.4-3.6-8-8-8h-60c-4.4 0-8 3.6-8 8c0 140.3-113.7 254-254 254S258 594.3 258 454c0-4.4-3.6-8-8-8h-60c-4.4 0-8 3.6-8 8c0 168.7 126.6 307.9 290 327.6V884H326.7c-13.7 0-24.7 14.3-24.7 32v36c0 4.4 2.8 8 6.2 8h407.6c3.4 0 6.2-3.6 6.2-8v-36c0-17.7-11-32-24.7-32H548V782.1c165.3-18 294-158 294-328.1"
                    />
                  </svg>
                </button>
              </div>
              <button
                onClick={handleSendMessage}
                disabled={inputValue.trim() === ""}
                className="bg-black text-white p-2 rounded-full hover:bg-gray-800 transition-colors disabled:opacity-50 disabled:cursor-not-allowed shadow-sm"
              >
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  width="16"
                  height="16"
                  viewBox="0 0 24 24"
                  className="transition-transform hover:scale-110"
                >
                  <path
                    fill="currentColor"
                    d="M20.04 2.323c1.016-.355 1.992.621 1.637 1.637l-5.925 16.93c-.385 1.098-1.915 1.16-2.387.097l-2.859-6.432l4.024-4.025a.75.75 0 0 0-1.06-1.06l-4.025 4.024l-6.432-2.859c-1.063-.473-1-2.002.097-2.387z"
                  />
                </svg>
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default ChatBot;
