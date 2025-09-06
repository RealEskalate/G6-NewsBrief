// components/auth/AuthModal.tsx
"use client";
import React, { useEffect } from "react";

type Props = {
  children: React.ReactNode;
  onClose?: () => void;
};

const AuthModal: React.FC<Props> = ({ children, onClose }) => {
  // Close when pressing ESC
  useEffect(() => {
    const onKey = (e: KeyboardEvent) => {
      if (e.key === "Escape") onClose?.();
    };
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  }, [onClose]);

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center">
      {/* Backdrop: click to close */}
      <button
        aria-label="Close modal"
        className="absolute inset-0 bg-black/40 backdrop-blur-sm"
        onClick={onClose}
      />
      {/* Modal content */}
      <div className="relative z-10 w-full max-w-md px-3">
        {children}
      </div>
    </div>
  );
};

export default AuthModal;
