"use client";

import { useState, useEffect } from "react";
import { apiClient } from "@/lib/api"; 
 // 👈 make sure you import your API client
import Button from "@/components/reusable_components/Button";

export default function AddSourcePage() {
  const [form, setForm] = useState({
    slug: "",
    name: "",
    description: "",
    url: "",
    logoUrl: "",
    language: "En",
    topics: [] as string[], // topics as array
    reliability: 5.7,
  });

  const [showConfirm, setShowConfirm] = useState(false);
  const [submitted, setSubmitted] = useState(false);
  const [loading, setLoading] = useState(true);
  const [apiLoading, setApiLoading] = useState(false);
  const [message, setMessage] = useState("");

  useEffect(() => {
    const timer = setTimeout(() => setLoading(false), 1000);
    return () => clearTimeout(timer);
  }, []);

  const handleChange = (
    e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>
  ) => {
    const { name, value } = e.target;
    setForm({ ...form, [name]: value });
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setShowConfirm(true);
  };

  const confirmSubmit = async () => {
    setApiLoading(true);
    try {
      const payload = {
        slug: form.slug,
        name: form.name,
        description: form.description,
        url: form.url,
        logo_url: form.logoUrl,
        languages: form.language,
        topics: form.topics,
        reliability_score: form.reliability,
      };

      const res = await apiClient.createSource(payload);
      setMessage(res.message || "Source created successfully ✅");
      setSubmitted(true);

      // reset form
      setForm({
        slug: "",
        name: "",
        description: "",
        url: "",
        logoUrl: "",
        language: "En",
        topics: [],
        reliability: 5.7,
      });

      setTimeout(() => setSubmitted(false), 3000);
    } catch (err: unknown) {
      if (err instanceof Error){
      setMessage(err.message || "Failed to create source ❌");}
    } finally {
      setApiLoading(false);
      setShowConfirm(false);
    }
  };

  return (
    <div className="min-h-screen bg-gray-50 flex items-start justify-center p-4 relative">
      <div className="w-full max-w-4xl bg-white rounded-2xl shadow-lg p-8 sm:p-12">
        <h2 className="text-2xl font-bold text-gray-800 mb-8 text-center sm:text-left">
          Add New Source
        </h2>

        {loading ? (
          // Skeleton loader
          <div className="animate-pulse space-y-6">
            <div className="h-10 bg-gray-200 rounded w-1/3"></div>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div className="h-10 bg-gray-200 rounded"></div>
              <div className="h-10 bg-gray-200 rounded"></div>
            </div>
            <div className="h-24 bg-gray-200 rounded"></div>
          </div>
        ) : (
          <form onSubmit={handleSubmit} className="grid grid-cols-1 md:grid-cols-2 gap-6">
            {/* Slug */}
            <div>
              <label className="block text-sm font-medium text-gray-600 mb-2">Slug</label>
              <input
                type="text"
                name="slug"
                value={form.slug}
                onChange={handleChange}
                required
                placeholder="Enter slug"
                className="w-full border border-gray-300 rounded-lg px-4 py-2"
              />
            </div>

            {/* Name */}
            <div>
              <label className="block text-sm font-medium text-gray-600 mb-2">Name</label>
              <input
                type="text"
                name="name"
                value={form.name}
                onChange={handleChange}
                required
                placeholder="Enter source name"
                className="w-full border border-gray-300 rounded-lg px-4 py-2"
              />
            </div>

            {/* Description */}
            <div className="md:col-span-2">
              <label className="block text-sm font-medium text-gray-600 mb-2">Description</label>
              <textarea
                name="description"
                value={form.description}
                onChange={handleChange}
                required
                placeholder="Enter description"
                className="w-full border border-gray-300 rounded-lg px-4 py-2 h-28 resize-none"
              />
            </div>

            {/* URL */}
            <div>
              <label className="block text-sm font-medium text-gray-600 mb-2">URL</label>
              <input
                type="url"
                name="url"
                value={form.url}
                onChange={handleChange}
                required
                placeholder="https://example.com"
                className="w-full border border-gray-300 rounded-lg px-4 py-2"
              />
            </div>

            {/* Logo URL */}
            <div>
              <label className="block text-sm font-medium text-gray-600 mb-2">Logo URL</label>
              <input
                type="url"
                name="logoUrl"
                value={form.logoUrl}
                onChange={handleChange}
                required
                placeholder="https://logo.png"
                className="w-full border border-gray-300 rounded-lg px-4 py-2"
              />
            </div>

            {/* Language */}
            <div>
              <label className="block text-sm font-medium text-gray-600 mb-2">Language</label>
              <select
                name="language"
                value={form.language}
                onChange={handleChange}
                required
                className="w-full border border-gray-300 rounded-lg px-4 py-2"
              >
                <option value="">Select Language</option>
                <option value="En">English</option>
                <option value="Am">Amharic</option>
              </select>
            </div>

            {/* Reliability */}
            <div>
              <label className="block text-sm font-medium text-gray-600 mb-2">
                Reliability Score
              </label>
              <input
                type="number"
                step="0.1"
                name="reliability"
                value={form.reliability}
                onChange={handleChange}
                required
                className="border border-gray-300 rounded-lg px-4 py-2 w-28"
              />
            </div>

            {/* Submit */}
            <div className="md:col-span-2 flex justify-end mt-4">
              <Button
                
                type="submit"
                className="bg-gray-900 hover:bg-gray-800 text-white font-semibold px-6 py-2 rounded-lg shadow-md transition"
                disabled={apiLoading}
              >
                {apiLoading ? "Submitting..." : "Submit"}
              </Button>
            </div>
          </form>
        )}
      </div>

      {/* Confirm Modal */}
      {showConfirm && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg p-6 w-96 shadow-lg text-center">
            <h3 className="text-lg font-semibold mb-4">Confirm Submission</h3>
            <p className="mb-6"> you want to submit this source?</p>
            <div className="flex justify-center gap-4">
              <button
                className="px-4 py-2 bg-gray-300 rounded hover:bg-gray-400"
                onClick={() => setShowConfirm(false)}
              >
                Cancel
              </button>
              <button
                className="bg-gray-900 hover:bg-gray-800 text-white font-semibold px-6 py-2 rounded-lg shadow-md transition"
                onClick={confirmSubmit}
              >
                Submit
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Success Toast */}
      {submitted && (
        <div className="absolute top-8 right-8 bg-black text-white px-5 py-3 rounded-lg shadow-lg">
          {message}
        </div>
      )}..
    </div>
  );
}
