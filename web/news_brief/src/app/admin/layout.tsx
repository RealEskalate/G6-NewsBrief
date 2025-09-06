// app/(admin)/layout.tsx
"use client";

import { useEffect, useState, ReactNode } from "react";
import { useRouter } from "next/navigation";
import AdminTopBar from "../../components/Admin_components/AdminTopBar";
import { getAccessToken, getUserRole } from "@/lib/api";

export default function AdminLayout({ children }: { children: ReactNode }) {
  const router = useRouter();
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const token = getAccessToken();
    const role = getUserRole();

    if (!token || role !== "admin") {
      router.replace("/");
      return;
    }

    setIsLoading(false); 
  }, [router]);

  if (isLoading) {
    return (
      <div className="flex justify-center items-center min-h-screen">
        <p>Loading...</p>
      </div>
    );
  }

  return (
    <div className="min-h-screen flex flex-col">
      <AdminTopBar />
      <main className="flex-1 p-4 bg-gray-50 pt-16">{children}</main>
    
    </div>
  );
}
