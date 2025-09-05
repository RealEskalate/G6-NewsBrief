import 'package:flutter/material.dart';
import '../../datasource/datasources/local_admin_data.dart';
import '../../domain/entities/topic.dart';

class TopicsPage extends StatefulWidget {
  const TopicsPage({super.key});

  @override
  State<TopicsPage> createState() => _TopicsPageState();
}

class _TopicsPageState extends State<TopicsPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _slugController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _englishLabelController = TextEditingController();
  final TextEditingController _amharicLabelController = TextEditingController();

  void _saveTopic() async {
    if (_formKey.currentState!.validate()) {
      final topic = Topic(
        slug: _slugController.text.trim(),
        label: {
          'en': _englishLabelController.text.trim(),
          'am': _amharicLabelController.text.trim(),
        },
        description: _descriptionController.text.isNotEmpty
            ? {'en': _descriptionController.text.trim()}
            : null,
      );

      await LocalAdminData.addTopic(topic);

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Topic saved!')));

      _formKey.currentState!.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildTextField(_slugController, 'Slug'),
            const SizedBox(height: 12),
            _buildTextField(_nameController, 'Topic Name'),
            const SizedBox(height: 12),
            _buildTextField(_descriptionController, 'Description', maxLines: 3),
            const SizedBox(height: 12),
            _buildTextField(_englishLabelController, 'English Label'),
            const SizedBox(height: 12),
            _buildTextField(_amharicLabelController, 'Amharic Label'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveTopic,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text("Submit"),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      validator: (value) => value == null || value.isEmpty ? '$label is required' : null,
    );
  }
}
