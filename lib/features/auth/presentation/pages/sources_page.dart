import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:easy_localization/easy_localization.dart';
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
        SnackBar(content: Text('authorization_token_missing'.tr())),
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
          SnackBar(content: Text('source_created_successfully'.tr())),
        );
        _formKey.currentState!.reset();
      } else if (response.statusCode == 403) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('forbidden_create_sources'.tr())),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${'error'.tr()}: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${'network_error'.tr()}: $e')),
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
              decoration: InputDecoration(labelText: 'slug'.tr()),
              validator: (val) => val == null || val.isEmpty ? 'enter_slug'.tr() : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'name'.tr()),
              validator: (val) => val == null || val.isEmpty ? 'enter_name'.tr() : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descController,
              decoration: InputDecoration(labelText: 'description'.tr()),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _urlController,
              decoration: InputDecoration(labelText: 'url'.tr()),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _logoUrlController,
              decoration: InputDecoration(labelText: 'logo_url'.tr()),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _languagesController,
              decoration: InputDecoration(labelText: 'languages'.tr()),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _topicsController,
              decoration: InputDecoration(labelText: 'topics'.tr()),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _reliabilityController,
              decoration: InputDecoration(labelText: 'reliability_score'.tr()),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _createSource,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text('create_source'.tr()),
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
            ),
          ],
        ),
      ),
    );
  }
}
