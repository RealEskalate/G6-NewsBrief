"use client";

import { useEffect } from "react";
import { useRouter } from "next/navigation";

export default function VerifiedPage() {
  const router = useRouter();

  useEffect(() => {
    const hash = window.location.hash.substring(1); 
    const params = new URLSearchParams(hash);

    const accessToken = params.get("access_token");
    const refreshToken = params.get("refresh_token");
    const userId = params.get("user_id");

    if (accessToken) {
      localStorage.setItem("token", accessToken);
      if (refreshToken) localStorage.setItem("refreshToken", refreshToken);
      if (userId) localStorage.setItem("userId", userId);

      router.push("/"); 
    } else {
      router.push("/signin");
    }
  }, [router]);

  return <p>Signing you in with Google...</p>;
}
