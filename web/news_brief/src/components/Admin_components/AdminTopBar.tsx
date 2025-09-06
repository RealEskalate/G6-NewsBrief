"use client";
import React, { useState } from "react";
import Link from "next/link";
import { usePathname } from "next/navigation";
import {
  LayoutDashboard,
  FileText,
  Tag,
  Newspaper,
  Shield,
  Menu,
  X,
} from "lucide-react";

const AdminTopBar = () => {
  const pathname = usePathname();
  const [isOpen, setIsOpen] = useState(false);

  const linkClasses = (href: string) =>
    `flex items-center gap-1 px-2 py-1 rounded-full transition ${
      pathname === href
        ? "bg-gray-100 shadow-sm"
        : "text-gray-600 hover:text-blue-600"
    }`;

  const navLinks = [
    { href: "/admin", label: "Dashboard", icon: <LayoutDashboard size={16} /> },
    { href: "/admin/sources", label: "Sources", icon: <FileText size={16} /> },
    { href: "/admin/topics", label: "Topics", icon: <Tag size={16} /> },
    { href: "/admin/news", label: "News", icon: <Newspaper size={16} /> },
  ];

  return (
    <header className="w-full bg-white shadow-md px-6 py-3 flex items-center justify-between fixed top-0 left-0 right-0 z-50">
      {/* Left: Logo + Title */}
      <Link href="/" className="flex items-center gap-2">
        <img src="/logo.png" alt="logo" className="w-6 h-6" />
        <span className="font-bold text-lg">News Brief</span>
      </Link>

      {/* Desktop Navigation */}
      <nav className="hidden md:flex items-center gap-4 text-sm font-medium">
        {navLinks.map((link) => (
          <Link
            key={link.href}
            href={link.href}
            className={linkClasses(link.href)}
          >
            {link.icon}
            {link.label}
          </Link>
        ))}
        <Link
          href="/admin"
          className={`bg-gray-100 shadow-sm flex items-center gap-1 px-2 py-1 rounded-full transition  text-blue-600`}
        >
          <Shield size={16} />
          Admin
        </Link>
      </nav>

      {/* Mobile: Admin link + Hamburger */}
      <div className="flex items-center gap-4 md:hidden">
        <Link
          href="/admin"
          className="flex items-center gap-1 px-2 py-1 rounded-full text-blue-600"
        >
          <Shield size={16} />
          Admin
        </Link>
        <button
          onClick={() => setIsOpen(!isOpen)}
          className="p-2 rounded hover:bg-gray-100 transition"
        >
          {isOpen ? <X size={20} /> : <Menu size={20} />}
        </button>
      </div>

      {/* Mobile Menu */}
      {isOpen && (
        <nav className="absolute top-full left-0 w-full bg-white shadow-md flex flex-col gap-2 p-4 md:hidden z-50">
          {navLinks.map((link) => (
            <Link
              key={link.href}
              href={link.href}
              className={linkClasses(link.href)}
              onClick={() => setIsOpen(false)}
            >
              {link.icon}
              {link.label}
            </Link>
          ))}
        </nav>
      )}
    </header>
  );
};

export default AdminTopBar;
