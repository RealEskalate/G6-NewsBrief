"use client";

import { useEffect } from "react";

const Logout = () => {
  useEffect(() => {
    localStorage.clear();
    window.location.href = "/";
  }, []);

  return null;
};

export default Logout;
