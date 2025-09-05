import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../../core/storage/token_secure_storage.dart';


class SourcesPage extends StatefulWidget {
  const SourcesPage({super.key});

  @override
  State<SourcesPage> createState() => _SourcesPageState();
}

class _SourcesPageState extends State<SourcesPage> {
  final _formKey = GlobalKey<FormState>();
  final _slugController = TextEditingController();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _urlController = TextEditingController();
  final _logoUrlController = TextEditingController();
  final _languagesController = TextEditingController();
  final _topicsController = TextEditingController();
  final _reliabilityController = TextEditingController(text: '0');
  bool _isLoading = false;

  final String apiBaseUrl = 'https://news-brief-core-api.onrender.com/api/v1';

  Future<void> _createSource() async {
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

    final topicsList = _topicsController.text.split(',').map((t) => t.trim()).toList();

    final body = jsonEncode({
      "slug": _slugController.text.trim(),
      "name": _nameController.text.trim(),
      "description": _descController.text.trim(),
      "url": _urlController.text.trim(),
      "logo_url": _logoUrlController.text.trim(),
      "languages": _languagesController.text.trim(),
      "topics": topicsList,
      "reliability_score": int.tryParse(_reliabilityController.text) ?? 0,
    });

    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/admin/create-sources'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Source created successfully!')),
        );
        _formKey.currentState!.reset();
      } else if (response.statusCode == 403) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Forbidden: You cannot create sources.')),
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
    _nameController.dispose();
    _descController.dispose();
    _urlController.dispose();
    _logoUrlController.dispose();
    _languagesController.dispose();
    _topicsController.dispose();
    _reliabilityController.dispose();
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
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (val) => val == null || val.isEmpty ? 'Enter name' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _urlController,
              decoration: const InputDecoration(labelText: 'URL'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _logoUrlController,
              decoration: const InputDecoration(labelText: 'Logo URL'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _languagesController,
              decoration: const InputDecoration(labelText: 'Languages (comma-separated)'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _topicsController,
              decoration: const InputDecoration(labelText: 'Topics (comma-separated)'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _reliabilityController,
              decoration: const InputDecoration(labelText: 'Reliability Score'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _createSource,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Create Source'),
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
            ),
          ],
        ),
      ),
    );
  }
}
