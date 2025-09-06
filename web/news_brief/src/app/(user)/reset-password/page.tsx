"use client";

import ResetPasswordForm from "../../../components/reset_password/reset_pass";
import { Suspense } from "react";

export default function ResetPasswordPage() {
  return (
    <div className="flex items-center justify-center min-h-screen bg-gray-50">
      <Suspense fallback={<div>Loading reset form...</div>}>
        <ResetPasswordForm />
      </Suspense>
    </div>
  );
}
