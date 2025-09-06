import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'package:newsbrief/core/storage/token_secure_storage.dart';


import 'login.dart'; // make sure this path is correct

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _isLoading = true;
  int totalNews = 0;
  int totalTopics = 0;
  int totalSources = 0;
  int totalUsers = 0;

  final String apiBaseUrl = 'https://news-brief-core-api.onrender.com/api/v1';

  @override
  void initState() {
    super.initState();
    _fetchAnalytics();
  }

  Future<void> _fetchAnalytics() async {
    setState(() => _isLoading = true);

    try {
      final token = await TokenSecureStorage().readAccessToken();

      final response = await http.get(
        Uri.parse('$apiBaseUrl/admin/analytics'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          totalUsers = data['total_users'] ?? 0;
          totalNews = data['total_news'] ?? 0;
          totalSources = data['total_sources'] ?? 0;
          totalTopics = data['total_topics'] ?? 0;
          _isLoading = false;
        });
      } else {
        _showError("Error: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      _showError("Network error: $e");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate back to LoginPage
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const Login()),
                  (route) => false,
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ✅ Stats cards row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatCard(title: "News", value: totalNews.toString()),
                _StatCard(title: "Topics", value: totalTopics.toString()),
                _StatCard(title: "Sources", value: totalSources.toString()),
                _StatCard(title: "Users", value: totalUsers.toString()),
              ],
            ),
            const SizedBox(height: 24),

            // ✅ Pie chart
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: SizedBox(
                height: 250,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text("Platform Composition"),
                      const SizedBox(height: 16),
                      Expanded(
                        child: PieChart(
                          PieChartData(
                            sections: [
                              PieChartSectionData(
                                value: totalNews.toDouble(),
                                title: "News",
                                color: Colors.blue,
                                radius: 50,
                              ),
                              PieChartSectionData(
                                value: totalTopics.toDouble(),
                                title: "Topics",
                                color: Colors.green,
                                radius: 50,
                              ),
                              PieChartSectionData(
                                value: totalSources.toDouble(),
                                title: "Sources",
                                color: Colors.orange,
                                radius: 50,
                              ),
                              PieChartSectionData(
                                value: totalUsers.toDouble(),
                                title: "Users",
                                color: Colors.purple,
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

            // ✅ Bar chart
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: SizedBox(
                height: 300,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: BarChart(
                    BarChartData(
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              const labels = ["News", "Topics", "Sources", "Users"];
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
                          BarChartRodData(toY: totalNews.toDouble(), color: Colors.blue),
                        ]),
                        BarChartGroupData(x: 1, barRods: [
                          BarChartRodData(toY: totalTopics.toDouble(), color: Colors.green),
                        ]),
                        BarChartGroupData(x: 2, barRods: [
                          BarChartRodData(toY: totalSources.toDouble(), color: Colors.orange),
                        ]),
                        BarChartGroupData(x: 3, barRods: [
                          BarChartRodData(toY: totalUsers.toDouble(), color: Colors.purple),
                        ]),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
