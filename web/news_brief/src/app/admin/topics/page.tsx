"use client";

import { useState, useEffect } from "react";
import { apiClient } from "@/lib/api";

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
  const [apiLoading, setApiLoading] = useState(false);
  const [message, setMessage] = useState("");
  const [errors, setErrors] = useState<{ [key: string]: string }>({});

  useEffect(() => {
    const timer = setTimeout(() => setLoading(false), 1000);
    return () => clearTimeout(timer);
  }, []);

  // Handle input changes
  const handleChange = (
    e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>
  ) => {
    const { name, value } = e.target;
    setForm({ ...form, [name]: value });
  };

  // Client-side validation before confirm modal
  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();

    const newErrors: { [key: string]: string } = {};
    if (!form.slug.trim()) newErrors.slug = "Slug is required.";
    if (!form.topicName.trim()) newErrors.topicName = "Topic name is required.";
    if (form.description.split(/[.!?]/).filter(s => s.trim()).length < 2)
      newErrors.description = "Description must be at least two sentences.";

    setErrors(newErrors);

    if (Object.keys(newErrors).length === 0) {
      setShowConfirm(true);
    }
  };

  // Confirm submission after validation passes
  const confirmSubmit = async () => {
    setApiLoading(true);
    setMessage("");
    setErrors({});

    

   try {
  await apiClient.createTopic(form.slug, form.english, form.amharic);

  setMessage("✅ Topic created successfully!");
  setSubmitted(true);
  setForm({
    slug: "",
    topicName: "",
    description: "",
    english: "",
    amharic: "",
    language: "",
    topics: [] as string[],
  });

  // Hide message after 3 seconds
  setTimeout(() => {
    setMessage("");
    setSubmitted(false);
  }, 3000);

} catch (err: unknown) {
  let friendlyMessage = "❌ Something went wrong.";
  let fieldErrors: { [key: string]: string } = {};

  if (err instanceof Error && err.message.includes("topic with slug already exists")) {
    friendlyMessage = "❌ Topic already exists.";
  } else if (err instanceof Error) {
    if (err.message.includes("exists")) {
      friendlyMessage = "❌ Slug or topic already exists.";
      fieldErrors = {
        slug: "Slug already exists.",
        topicName: "Topic name already exists.",
      };
    } else {
      friendlyMessage = `❌ ${err.message}`;
    }
  } else {
    friendlyMessage = "❌ Failed to create topic. Please try again.";
  }

  setErrors(fieldErrors);
  setMessage(friendlyMessage);

  // Hide error message after 3 seconds
  setTimeout(() => setMessage(""), 3000);
} finally {
  setApiLoading(false);
  setShowConfirm(false);
}
  };

  return (
    <div className="min-h-screen bg-gray-50 flex items-start justify-center p-4 relative">
      <div className="w-full max-w-4xl bg-white rounded-2xl shadow-lg p-8 sm:p-12">
        <h2 className="text-2xl font-bold text-gray-800 mb-8 text-center sm:text-left">
          Add New Topic
        </h2>

        {loading ? (
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
                className="w-full border border-gray-300 rounded-lg px-4 py-2"
              />
              {errors.slug && <p className="text-red-500 text-sm">{errors.slug}</p>}
            </div>

            {/* Topic Name */}
            <div>
              <label className="block text-sm font-medium text-gray-600 mb-2">Topic Name</label>
              <input
                type="text"
                name="topicName"
                value={form.topicName}
                onChange={handleChange}
                className="w-full border border-gray-300 rounded-lg px-4 py-2"
              />
              {errors.topicName && <p className="text-red-500 text-sm">{errors.topicName}</p>}
            </div>

            {/* Description */}
            <div className="md:col-span-2">
              <label className="block text-sm font-medium text-gray-600 mb-2">Description</label>
              <textarea
                name="description"
                value={form.description}
                onChange={handleChange}
                className="w-full border border-gray-300 rounded-lg px-4 py-2 h-28 resize-none"
              />
              {errors.description && <p className="text-red-500 text-sm">{errors.description}</p>}
            </div>

            {/* English */}
            <div>
              <label className="block text-sm font-medium text-gray-600 mb-2">English</label>
              <input
                type="text"
                name="english"
                value={form.english}
                onChange={handleChange}
                className="w-full border border-gray-300 rounded-lg px-4 py-2"
              />
            </div>

            {/* Amharic */}
            <div>
              <label className="block text-sm font-medium text-gray-600 mb-2">Amharic</label>
              <input
                type="text"
                name="amharic"
                value={form.amharic}
                onChange={handleChange}
                className="w-full border border-gray-300 rounded-lg px-4 py-2"
              />
            </div>

            {/* Submit */}
            <div className="md:col-span-2 flex justify-end mt-4">
              <button
                type="submit"
                className="bg-gray-900 hover:bg-gray-800 text-white font-semibold px-6 py-2 rounded-lg shadow-md transition"
                disabled={apiLoading}
              >
                {apiLoading ? "Submitting..." : "Submit"}
              </button>
            </div>
          </form>
        )}
      </div>

      {/* Confirm Modal */}
      {showConfirm && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg p-6 w-96 shadow-lg text-center">
            <h3 className="text-lg font-semibold mb-4">Confirm Submission</h3>
            <p className="mb-6">Are you sure you want to submit this topic?</p>
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

      {/* Success/Error Toast */}
      {/* Success/Error Toast */}
{message && (
  <div
    className={`absolute top-8 right-8 px-5 py-3 rounded-lg shadow-lg text-white ${
      message === "✅ Topic created successfully!" ? "bg-black" : "bg-red-600"
    }`}
  >
    {message}
  </div>
)}

    </div>
  );
}
