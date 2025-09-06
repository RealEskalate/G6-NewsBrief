import 'package:flutter/material.dart';
import 'package:newsbrief/features/news/domain/entities/news.dart';
import '../../../news/datasource/models/news_model.dart';
import '../../datasource/repositories/local_news_repository.dart';
import '../../datasource/datasources/local_admin_data.dart';
import '../../domain/entities/source.dart';
import '../../domain/entities/topic.dart';

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

  String? _selectedSource;
  List<String> _selectedTopics = [];
  String _selectedLanguage = 'en';

  final LocalNewsRepository _localNewsRepo = LocalNewsRepository();

  List<Source> _sources = [];
  List<Topic> _topics = [];

  @override
  void initState() {
    super.initState();
    _loadAdminData();
  }

  Future<void> _loadAdminData() async {
    final sources = await LocalAdminData.getSources();
    final topics = await LocalAdminData.getTopics();
    setState(() {
      _sources = sources;
      _topics = topics;
    });
  }

  void _saveNews() async {
    if (_formKey.currentState!.validate()) {
      // final news = News(
      //   id: DateTime.now().millisecondsSinceEpoch.toString(),
      //   titleEn: _titleEnController.text.trim(),
      //   titleAm: _titleAmController.text.trim(),
      //   descriptionEn: _descEnController.text.trim(),
      //   descriptionAm: _descAmController.text.trim(),
      //   source: _selectedSource!,
      //   imageUrl: '',
        // topics: _selectedTopics,
      // );

      // await _localNewsRepo.addNews(news);

      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('News saved locally!')),
      // );

      _formKey.currentState!.reset();
      setState(() {
        _selectedSource = null;
        _selectedTopics = [];
        _selectedLanguage = 'en';
      });
    }
  }

  @override
  void dispose() {
    _titleEnController.dispose();
    _titleAmController.dispose();
    _descEnController.dispose();
    _descAmController.dispose();
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
            DropdownButtonFormField<String>(
              value: _selectedLanguage,
              items: const [
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'am', child: Text('Amharic')),
              ],
              onChanged: (val) => setState(() => _selectedLanguage = val!),
              decoration: const InputDecoration(labelText: 'Language'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleEnController,
              decoration: const InputDecoration(labelText: 'Title (EN)'),
              validator: (val) => val == null || val.isEmpty ? 'Enter title in English' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleAmController,
              decoration: const InputDecoration(labelText: 'Title (AM)'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descEnController,
              decoration: const InputDecoration(labelText: 'Description (EN)'),
              maxLines: 4,
              validator: (val) => val == null || val.isEmpty ? 'Enter description in English' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descAmController,
              decoration: const InputDecoration(labelText: 'Description (AM)'),
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedSource,
              items: _sources.map((s) => DropdownMenuItem(value: s.slug, child: Text(s.name))).toList(),
              onChanged: (val) => setState(() => _selectedSource = val),
              validator: (val) => val == null ? 'Select a source' : null,
              decoration: const InputDecoration(labelText: 'Source'),
            ),
            const SizedBox(height: 16),
            InputDecorator(
              decoration: const InputDecoration(labelText: 'Topics'),
              child: Wrap(
                spacing: 8,
                children: _topics.map((t) {
                  final label = t.label['en'] ?? t.slug;
                  final selected = _selectedTopics.contains(label);
                  return FilterChip(
                    label: Text(label),
                    selected: selected,
                    onSelected: (val) {
                      setState(() {
                        if (val) {
                          _selectedTopics.add(label);
                        } else {
                          _selectedTopics.remove(label);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saveNews,
              child: const Text('Save News Locally'),
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
            ),
          ],
        ),
      ),
    );
  }
}
