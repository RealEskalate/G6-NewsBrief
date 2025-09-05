import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../domain/entities/source.dart';
import '../../domain/entities/topic.dart';
import '../../domain/repositories/admin_repository.dart';

class AdminRepositoryImpl implements AdminRepository {
  final String baseUrl;
  final http.Client client;

  AdminRepositoryImpl({
    required this.baseUrl,
    required this.client,
  });

  @override
  Future<void> createTopic(Topic topic) async {
    final body = topic.toJson();

    final response = await client.post(
      Uri.parse('$baseUrl/admin/createtopics'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create topic: ${response.statusCode}');
    }
  }

  @override
  Future<void> createSource(Source source) async {
    final body = source.toJson();

    final response = await client.post(
      Uri.parse('$baseUrl/admin/create-sources'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create source: ${response.statusCode}');
    }
  }
}
