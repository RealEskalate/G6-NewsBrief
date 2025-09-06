import type { Metadata } from "next";
import "./globals.css";
import ThemeProvider from "./contexts/ThemeContext";
import { I18nProvider } from "@/components/I18nProvider";
import Footer from "@/components/Footer/Footer";
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
      <body className="flex flex-col min-h-screen">
        <I18nProvider>
          <ThemeProvider>
            <main className="flex-1 w-full">{children}</main>
            <Footer/>
          </ThemeProvider>
        </I18nProvider>
      </body>
    </html>
  );
}
