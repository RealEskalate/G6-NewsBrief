"use client";

import { useEffect } from "react";
import { useRouter } from "next/navigation";

export default function AuthSuccessPage() {
  const router = useRouter();

  useEffect(() => {
    const params = new URLSearchParams(window.location.search);

    const accessToken = params.get("access_token");
    const refreshToken = params.get("refresh_token");
    const userId = params.get("user_id");
    const email = params.get("email");
    const fullname = params.get("fullname");
    const username = params.get("username");

    if (accessToken && refreshToken && userId) {
      const userData = {
        user: {
          id: userId,
          username: username || email || "",
          email: email || "",
          role: "user",
          fullname: fullname || "",
          avatar_url: null,
          is_verified: false,
          created_at: new Date().toISOString(),
        },
        access_token: accessToken,
        refresh_token: refreshToken,
      };

      localStorage.setItem("person", JSON.stringify(userData));

      router.push("/news");
    } else {
      router.push("/signin");
    }
  }, [router]);

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50">
      <div className="flex flex-col items-center space-y-4 p-6 bg-white rounded-2xl shadow-lg">
        <div className="w-10 h-10 border-4 border-blue-500 border-t-transparent rounded-full animate-spin" />
        <p className="text-lg font-medium text-gray-700">
          Signing you in with Google...
        </p>
      </div>
    </div>
  );
}
