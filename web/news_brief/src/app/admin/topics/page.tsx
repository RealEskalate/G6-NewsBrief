"use client";

import { useState, useEffect } from "react";
import { apiClient } from "@/lib/api"; // ✅ make sure this path is correct

export default function AddTopicsPage() {
  const [form, setForm] = useState({
    slug: "",
    topicName: "",
    description: "",
    english: "",
    amharic: "",
    language: "",
    topics: [] as string[],
  });

  const [showConfirm, setShowConfirm] = useState(false);
  const [submitted, setSubmitted] = useState(false);
  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);
  const [message, setMessage] = useState("");

  useEffect(() => {
    // ⏳ simulate loading
    const timer = setTimeout(() => setLoading(false), 1500);
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
    setSubmitting(true);
    setMessage("");

    try {
      // ✅ Call backend API to create topic
      await apiClient.createTopic(form.slug, form.english, form.amharic);

      setSubmitted(true);
      setMessage("Topic created successfully!");
      setForm({
        slug: "",
        topicName: "",
        description: "",
        english: "",
        amharic: "",
        language: "",
        topics: [] as string[],
      });

      setTimeout(() => setSubmitted(false), 3000);
    } catch (err: unknown) {
      if(err instanceof Error){
      setMessage(err.message || "Failed to create topic ❌");}
    } finally {
      setShowConfirm(false);
      setSubmitting(false);
    }
  };

  return (
    <div className="min-h-screen bg-gray-50 flex items-start justify-center p-4 relative">
      <div className="w-full max-w-4xl bg-white rounded-2xl shadow-lg p-8 sm:p-12">
        <h2 className="text-2xl font-bold text-gray-800 mb-8 text-center sm:text-left">
          Add New Topics
        </h2>

        {loading ? (
          // 🔲 Skeleton Loader
          <div className="animate-pulse space-y-6">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div className="h-10 bg-gray-200 rounded"></div>
              <div className="h-10 bg-gray-200 rounded"></div>
            </div>
            <div className="h-24 bg-gray-200 rounded"></div>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div className="h-10 bg-gray-200 rounded"></div>
              <div className="h-10 bg-gray-200 rounded"></div>
            </div>
            <div className="flex justify-end">
              <div className="h-10 w-28 bg-gray-200 rounded"></div>
            </div>
          </div>
        ) : (
          // 📝 Form
          <form onSubmit={handleSubmit} className="grid grid-cols-1 md:grid-cols-2 gap-6">
            {/* Slug */}
            <div>
              <label className="block text-sm font-medium text-gray-600 mb-2">
                Slug
              </label>
              <input
                type="text"
                name="slug"
                value={form.slug}
                onChange={handleChange}
                placeholder="Enter slug"
                required
                className="w-full border border-gray-300 rounded-lg px-4 py-2 focus:border-black focus:ring-0 transition"
              />
            </div>

            {/* Topic Name */}
            <div>
              <label className="block text-sm font-medium text-gray-600 mb-2">
                Topic Name
              </label>
              <input
                type="text"
                name="topicName"
                value={form.topicName}
                onChange={handleChange}
                placeholder="Enter topic name"
                required
                className="w-full border border-gray-300 rounded-lg px-4 py-2 focus:border-black focus:ring-0 transition"
              />
            </div>

            {/* Description */}
            <div className="md:col-span-2">
              <label className="block text-sm font-medium text-gray-600 mb-2">
                Description
              </label>
              <textarea
                name="description"
                value={form.description}
                onChange={handleChange}
                placeholder="Enter description"
                required
                className="w-full border border-gray-300 rounded-lg px-4 py-2 h-28 resize-none focus:border-black focus:ring-0 transition"
              />
            </div>

            {/* English */}
            <div>
              <label className="block text-sm font-medium text-gray-600 mb-2">
                English
              </label>
              <input
                type="text"
                name="english"
                value={form.english}
                onChange={handleChange}
                placeholder="English label"
                required
                className="w-full border border-gray-300 rounded-lg px-4 py-2 focus:border-black focus:ring-0 transition"
              />
            </div>

            {/* Amharic */}
            <div>
              <label className="block text-sm font-medium text-gray-600 mb-2">
                Amharic
              </label>
              <input
                type="text"
                name="amharic"
                value={form.amharic}
                onChange={handleChange}
                placeholder="Amharic label"
                required
                className="w-full border border-gray-300 rounded-lg px-4 py-2 focus:border-black focus:ring-0 transition"
              />
            </div>

            {/* Submit */}
            <div className="md:col-span-2 flex justify-end mt-4">
              <button
                type="submit"
                disabled={submitting}
                className="bg-gray-900 hover:bg-gray-800 text-white font-semibold px-6 py-2 rounded-lg shadow-md transition"
              >
                {submitting ? "Submitting..." : "Submit"}
              </button>
            </div>
          </form>
        )}
      </div>

      {/* Confirmation Modal */}
      {showConfirm && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg p-6 w-96 shadow-lg text-center">
            <h3 className="text-lg font-semibold mb-4">Confirm Submission</h3>
            <p className="mb-6"> you want to submit this topic?</p>
            <div className="flex justify-center gap-4">
              <button
                className="px-4 py-2 bg-gray-300 rounded hover:bg-gray-400"
                onClick={() => setShowConfirm(false)}
              >
                Cancel
              </button>
              <button
                className="px-4 py-2 bg-black text-white rounded hover:bg-gray-800"
                onClick={confirmSubmit}
              >
                Submit
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Success/Error Toast */}
      {message && (
        <div
          className={`absolute top-8 right-8 px-5 py-3 rounded-lg shadow-lg text-white ${
            submitted ? "bg-black" : "bg-red-600"
          }`}
        >
          {message}
        </div>
      )}
    </div>
  );
}
