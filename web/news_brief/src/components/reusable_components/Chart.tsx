"use client";

import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  PieChart,
  Pie,
  Cell,
  Tooltip,
  ResponsiveContainer,
} from "recharts";

const pieData = [
  { name: "Conservative", value: 31.8 },
  { name: "Liberal", value: 43.2 },
  { name: "Bloc", value: 17.5 },
  { name: "NDP", value: 6.2 },
];

const PIE_COLORS = ["#1E3A8A", "#2563EB", "#3B82F6", "#93C5FD"];

const barData = [
  { name: "A", value: 500, fill: "#000000" },
  { name: "B", value: 380, fill: "#1C1C1C" },
  { name: "C", value: 900, fill: "#2F2F2F" },
  { name: "D", value: 750, fill: "#4B4B4B" },
  { name: "E", value: 620, fill: "#6B6B6B" },
  { name: "F", value: 460, fill: "#8C8C8C" },
];

export function Charts() {
  return (
    <div className="flex flex-col md:flex-row justify-center items-center gap-6 w-full">
      {/* Pie Chart */}
      <div className="rounded-xl bg-white p-4 border border-gray-100 w-full md:w-[500px]">
        <h3 className="text-sm font-medium mb-2">News by Topic</h3>
        <ResponsiveContainer width="100%" height={300}>
          <PieChart>
            <Pie
              data={pieData}
              cx="50%"
              cy="50%"
              outerRadius={100}
              label
              dataKey="value"
            >
              {pieData.map((entry, index) => (
                <Cell
                  key={`cell-${index}`}
                  fill={PIE_COLORS[index % PIE_COLORS.length]}
                />
              ))}
            </Pie>
            <Tooltip />
          </PieChart>
        </ResponsiveContainer>
      </div>

      {/* Bar Chart */}
      <div className="rounded-xl bg-white p-4 border border-gray-100 w-full md:w-[500px]">
        <h3 className="text-sm font-medium mb-2">News by Source</h3>
        <ResponsiveContainer width="100%" height={300}>
          <BarChart data={barData} barCategoryGap="30%">
            <XAxis dataKey="name" />
            <YAxis />
            <Tooltip />
            <Bar dataKey="value">
              {barData.map((entry, index) => (
                <Cell key={`bar-${index}`} fill={entry.fill} />
              ))}
            </Bar>
          </BarChart>
        </ResponsiveContainer>
      </div>
    </div>
  );
}
