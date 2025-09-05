import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../../core/storage/token_secure_storage.dart';


class TopicsPage extends StatefulWidget {
  const TopicsPage({super.key});

  @override
  State<TopicsPage> createState() => _TopicsPageState();
}

class _TopicsPageState extends State<TopicsPage> {
  final _formKey = GlobalKey<FormState>();
  final _slugController = TextEditingController();
  final _labelEnController = TextEditingController();
  final _labelAmController = TextEditingController();
  bool _isLoading = false;

  final String apiBaseUrl = 'https://news-brief-core-api.onrender.com/api/v1';

  Future<void> _createTopic() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final token = await TokenSecureStorage().readAccessToken();
    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Authorization token missing.')),
      );
      setState(() => _isLoading = false);
      return;
    }

    final body = jsonEncode({
      "slug": _slugController.text.trim(),
      "label": {
        "en": _labelEnController.text.trim(),
        "am": _labelAmController.text.trim(),
      },
    });

    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/admin/create-topics'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Topic created successfully!')),
        );
        _formKey.currentState!.reset();
      } else if (response.statusCode == 403) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Forbidden: You cannot create topics.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _slugController.dispose();
    _labelEnController.dispose();
    _labelAmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _slugController,
              decoration: const InputDecoration(labelText: 'Slug'),
              validator: (val) => val == null || val.isEmpty ? 'Enter slug' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _labelEnController,
              decoration: const InputDecoration(labelText: 'Label (EN)'),
              validator: (val) => val == null || val.isEmpty ? 'Enter label in English' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _labelAmController,
              decoration: const InputDecoration(labelText: 'Label (AM)'),
              validator: (val) => val == null || val.isEmpty ? 'Enter label in Amharic' : null,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _createTopic,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Create Topic'),
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
            ),
          ],
        ),
      ),
    );
  }
}
