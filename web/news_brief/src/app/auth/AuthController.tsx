// components/auth/AuthController.tsx
"use client";
import React, { useState } from "react";
import AuthModal from "./AuthModal";
import SignInCard from "../../components/signin_components/siginCard";
import SignUpCard from "../../components/signup_components/signupCard";
import ForgotPasswordCard from "../../components/forgotpassword_components/forgotpassCard";

type AuthMode = "signin" | "signup" | "forgot";

const AuthController: React.FC<{ onClose: () => void }> = ({ onClose }) => {
  const [mode, setMode] = useState<AuthMode>("signin");

  return (
    <AuthModal onClose={onClose}>
      {mode === "signin" && (
        <SignInCard
          onClose={onClose}
          onSwitchToSignUp={() => setMode("signup")}
          onSwitchToForgot={() => setMode("forgot")}
        />
      )}

      {mode === "signup" && (
        <SignUpCard
          onClose={onClose}
          onSwitchToSignIn={() => setMode("signin")}
        />
      )}

      {mode === "forgot" && (
        <ForgotPasswordCard
          onClose={onClose}
          onBackToSignIn={() => setMode("signin")}
        />
      )}
    </AuthModal>
  );
};

export default AuthController;
