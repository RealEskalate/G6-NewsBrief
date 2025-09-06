import type { Metadata } from "next";
import "./globals.css";
import ThemeProvider from "./contexts/ThemeContext";
import { I18nProvider } from "@/components/I18nProvider";
// adjust path if needed

export const metadata: Metadata = {
  title: "News Brief",
  description: "AI summarized App",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body>
        <I18nProvider>
          <ThemeProvider>
            {children}
          </ThemeProvider>
        </I18nProvider>
      </body>
    </html>
  );
}
