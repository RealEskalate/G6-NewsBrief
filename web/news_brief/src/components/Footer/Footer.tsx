"use client";
import Link from "next/link";
import { FaGooglePlay } from "react-icons/fa";

export default function Footer() {
  return (
    <footer className="bg-[#0f172a] text-gray-300 py-6 px-4 md:px-8 lg:px-12 text-xs md:text-sm">
      <div className="max-w-7xl mx-auto grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
        {/* Logo + About */}
        <div className="flex flex-col gap-2">
          <div className="flex items-center gap-2">
            <img src="/logo.png" className="w-6 h-6" alt="logo" />
            <h2 className="text-lg font-bold text-white">NewsBrief</h2>
          </div>
          <p className="text-[12px] md:text-[11px] text-gray-400 leading-relaxed">
            Stay updated with the latest news from around the world.
          </p>
        </div>

        {/* Support */}
        <div>
          <h3 className="text-white font-semibold mb-2 text-sm">SUPPORT</h3>
          <ul className="space-y-1">
            <li>
              <Link
                href="/help"
                className="hover:text-blue-600 transition-colors duration-200"
              >
                Help / FAQ
              </Link>
            </li>
            <li>
              <Link
                href="/feedback"
                className="hover:text-blue-600 transition-colors duration-200"
              >
                Feedback
              </Link>
            </li>
          </ul>
        </div>

        {/* About */}
        <div>
          <h3 className="text-white font-semibold mb-2 text-sm">ABOUT</h3>
          <ul className="space-y-1">
            <li>
              <Link
                href="/contact"
                className="hover:text-blue-600 transition-colors duration-200"
              >
                Contact Us
              </Link>
            </li>
            <li>
              <Link
                href="/terms"
                className="hover:text-blue-600 transition-colors duration-200"
              >
                Terms of Use
              </Link>
            </li>
            <li>
              <Link
                href="/privacy"
                className="hover:text-blue-600 transition-colors duration-200"
              >
                Privacy Policy
              </Link>
            </li>
          </ul>
        </div>

        {/* Stay Updated + Google Play */}
        <div>
          <h3 className="text-white font-semibold mb-2 text-sm">STAY UPDATED</h3>
          <p className="text-[12px] md:text-[11px] text-gray-400 mb-2">
            Want to stay updated on the go? Download our app:
          </p>
          <a
            href="#"
            className="flex items-center gap-2 bg-gray-800 px-3 py-2 rounded-lg hover:bg-gray-700 transition w-max text-xs md:text-sm"
          >
            <FaGooglePlay className="text-base md:text-lg" />{" "}
            <span>Google Play</span>
          </a>
        </div>
      </div>

      {/* Bottom */}
      <div className="mt-6 border-t border-gray-700 pt-3 text-center text-[11px] text-gray-400">
        © {new Date().getFullYear()} NewsBrief. All rights reserved.
      </div>
    </footer>
  );
}
