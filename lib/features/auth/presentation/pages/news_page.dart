import 'package:flutter/material.dart';
import 'package:newsbrief/core/network_info/api_service.dart';
import 'package:newsbrief/core/storage/token_secure_storage.dart';
import '../../domain/entities/topic.dart';
import '../../domain/entities/source.dart';

class AddNewsPage extends StatefulWidget {
  const AddNewsPage({super.key});

  @override
  State<AddNewsPage> createState() => _AddNewsPageState();
}

class _AddNewsPageState extends State<AddNewsPage> {
  final _formKey = GlobalKey<FormState>();

  final _titleEnController = TextEditingController();
  final _titleAmController = TextEditingController();
  final _descEnController = TextEditingController();
  final _descAmController = TextEditingController();

  String _selectedLanguage = 'en';

  List<Source> _sources = [];
  List<String> _selectedSourceIds = [];

  List<Topic> _topics = [];
  List<String> _selectedTopicIds = [];

  late final ApiService _apiService;
  late final TokenSecureStorage _tokenStorage;

  @override
  void initState() {
    super.initState();
    _tokenStorage = TokenSecureStorage();
    _apiService = ApiService(
      baseUrl: 'https://news-brief-core-api.onrender.com/api/v1',
      tokenStorage: _tokenStorage,
    );
    _fetchSources();
    _fetchTopics();
  }

  Future<void> _fetchSources() async {
    try {
      final response = await _apiService.get('/sources');
      final List<dynamic> data = response.data['sources'];
      final fetchedSources = data.map((json) => Source.fromJson(json)).toList();

      setState(() {
        _sources = fetchedSources;
      });
    } catch (e, stacktrace) {
      debugPrint("Error fetching sources: $e\n$stacktrace");
    }
  }

  Future<void> _fetchTopics() async {
    try {
      final response = await _apiService.get('/topics');
      final List<dynamic> data = response.data['topics'];
      final fetchedTopics = data.map((json) => Topic.fromJson(json)).toList();

      setState(() {
        _topics = fetchedTopics;
      });
    } catch (e, stacktrace) {
      debugPrint("Error fetching topics: $e\n$stacktrace");
    }
  }

  Future<void> _saveNews() async {
    // Validate form fields
    if (!_formKey.currentState!.validate()) return;

    if (_selectedSourceIds.isEmpty || _selectedTopicIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select at least one source and one topic.")),
      );
      return;
    }

    try {
      // Read the access token
      final token = await _tokenStorage.readAccessToken();
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("You must be logged in.")),
        );
        return;
      }

      // Prepare the request payload
      final body = {
        "title": _selectedLanguage == 'en'
            ? _titleEnController.text.trim()
            : _titleAmController.text.trim(),
        "body": _selectedLanguage == 'en'
            ? _descEnController.text.trim()
            : _descAmController.text.trim(),
        "language": _selectedLanguage,
        "source_id": _selectedSourceIds.first, // Single source ID
        "topics_id": _selectedTopicIds,        // List of topic IDs
      };

      debugPrint("POST payload: $body"); // Optional: debug print

      // Send POST request
      final response = await _apiService.post('/admin/news', data: body);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("News created successfully!")),
      );


    } catch (e) {
      // Handle different error types more gracefully
      String errorMessage = e.toString();

      if (e.toString().contains("401")) {
        errorMessage = "Unauthorized: Please check your login credentials.";
      } else if (e.toString().contains("403")) {
        errorMessage = "Forbidden: You don't have permission to create news.";
      } else if (e.toString().contains("SocketException")) {
        errorMessage = "No internet connection. Please try again.";
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $errorMessage")),
      );
    }
  }


  Future<void> _showMultiSelect<T>({
    required String title,
    required List<T> items,
    required List<String> selectedValues,
    required String Function(T) getId,
    required String Function(T) getLabel,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setStateBottom) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  ...items.map((item) {
                    final id = getId(item);
                    final isSelected = selectedValues.contains(id);
                    return CheckboxListTile(
                      value: isSelected,
                      title: Text(getLabel(item)),
                      onChanged: (val) {
                        setStateBottom(() {
                          setState(() {
                            if (val == true) {
                              selectedValues.add(id);
                            } else {
                              selectedValues.remove(id);
                            }
                          });
                        });
                      },
                    );
                  }).toList(),
                  const SizedBox(height: 8),
                  ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text("Done")),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
    setState(() {});
  }

  Future<void> _showTopicSelect() async {
    await _showMultiSelect<Topic>(
      title: "Select Topics",
      items: _topics,
      selectedValues: _selectedTopicIds,
      getId: (t) => t.id!, // backend expects id
      getLabel: (t) => t.getLabel('en'),
    );
  }

  Future<void> _showSourceSelect() async {
    await _showMultiSelect<Source>(
      title: "Select Sources",
      items: _sources,
      selectedValues: _selectedSourceIds,
      getId: (s) => s.id!, // backend expects id
      getLabel: (s) => s.name,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add News")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: _selectedLanguage,
                decoration: const InputDecoration(labelText: "Language"),
                items: const [
                  DropdownMenuItem(value: 'en', child: Text("English")),
                  DropdownMenuItem(value: 'am', child: Text("Amharic")),
                ],
                onChanged: (val) => setState(() => _selectedLanguage = val!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleEnController,
                decoration: const InputDecoration(labelText: "Title (English)"),
                validator: (val) => val!.isEmpty ? "Required" : null,
              ),
              TextFormField(
                controller: _titleAmController,
                decoration: const InputDecoration(labelText: "Title (Amharic)"),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descEnController,
                decoration:
                const InputDecoration(labelText: "Description (English)"),
                maxLines: 3,
                validator: (val) => val!.isEmpty ? "Required" : null,
              ),
              TextFormField(
                controller: _descAmController,
                decoration:
                const InputDecoration(labelText: "Description (Amharic)"),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _showSourceSelect,
                child: InputDecorator(
                  decoration:
                  const InputDecoration(labelText: "Sources", filled: true),
                  child: Text(
                    _selectedSourceIds.isEmpty
                        ? "Select sources"
                        : _sources
                        .where((s) => _selectedSourceIds.contains(s.id))
                        .map((s) => s.name)
                        .join(", "),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _showTopicSelect,
                child: InputDecorator(
                  decoration:
                  const InputDecoration(labelText: "Topics", filled: true),
                  child: Text(
                    _selectedTopicIds.isEmpty
                        ? "Select topics"
                        : _topics
                        .where((t) => _selectedTopicIds.contains(t.id))
                        .map((t) => t.getLabel('en'))
                        .join(", "),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _saveNews, child: const Text("Save")),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleEnController.dispose();
    _titleAmController.dispose();
    _descEnController.dispose();
    _descAmController.dispose();
    super.dispose();
  }
}
