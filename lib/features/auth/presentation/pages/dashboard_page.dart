import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Stats cards row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _StatCard(title: "News", value: "120"),
              _StatCard(title: "Topics", value: "15"),
              _StatCard(title: "Sources", value: "8"),
              _StatCard(title: "Users", value: "350"),
            ],
          ),
          const SizedBox(height: 24),

          // Pie chart
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: SizedBox(
              height: 250,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text("Topics Distribution"),
                    const SizedBox(height: 16),
                    Expanded(
                      child: PieChart(
                        PieChartData(
                          sections: [
                            PieChartSectionData(
                              value: 40,
                              title: "Politics",
                              color: Colors.blue,
                              radius: 50,
                            ),
                            PieChartSectionData(
                              value: 30,
                              title: "Sports",
                              color: Colors.green,
                              radius: 50,
                            ),
                            PieChartSectionData(
                              value: 20,
                              title: "Tech",
                              color: Colors.orange,
                              radius: 50,
                            ),
                            PieChartSectionData(
                              value: 10,
                              title: "Other",
                              color: Colors.red,
                              radius: 50,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Bar chart
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: SizedBox(
              height: 300,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: BarChart(
                  BarChartData(
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            const labels = ["CNN", "BBC", "ESPN", "TechCrunch"];
                            if (value.toInt() < labels.length) {
                              return Text(labels[value.toInt()]);
                            }
                            return const Text("");
                          },
                        ),
                      ),
                    ),
                    barGroups: [
                      BarChartGroupData(x: 0, barRods: [
                        BarChartRodData(toY: 50, color: Colors.blue),
                      ]),
                      BarChartGroupData(x: 1, barRods: [
                        BarChartRodData(toY: 30, color: Colors.green),
                      ]),
                      BarChartGroupData(x: 2, barRods: [
                        BarChartRodData(toY: 20, color: Colors.orange),
                      ]),
                      BarChartGroupData(x: 3, barRods: [
                        BarChartRodData(toY: 40, color: Colors.purple),
                      ]),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;

  const _StatCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
