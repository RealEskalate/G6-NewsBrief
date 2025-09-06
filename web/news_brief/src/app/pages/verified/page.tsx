"use client";

import { useEffect } from "react";
import { useRouter } from "next/navigation";

export default function VerifiedPage() {
  const router = useRouter();

  useEffect(() => {
    const timer = setTimeout(() => {
      router.push("/"); // redirect to homepage after 3 seconds
    }, 3000);

    return () => clearTimeout(timer);
  }, [router]);

  return (
    <div className="fixed inset-0 flex items-center justify-center bg-gray-100 bg-opacity-50 z-50">
      <div className="bg-white rounded-2xl p-6 sm:p-8 text-center shadow-xl max-w-sm">
        <h1 className="text-2xl sm:text-3xl font-bold mb-4 text-green-600">
          ✅ Email Verified!
        </h1>
        <p className="text-center">
          Your email has been successfully verified. Redirecting to homepage...
        </p>
      </div>
    </div>
  );
}
