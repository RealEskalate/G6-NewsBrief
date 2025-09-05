import 'package:flutter/material.dart';
import '../../datasource/datasources/local_admin_data.dart';
import '../../domain/entities/source.dart';

class SourcesPage extends StatefulWidget {
  const SourcesPage({super.key});

  @override
  State<SourcesPage> createState() => _SourcesPageState();
}

class _SourcesPageState extends State<SourcesPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _slugController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _logoUrlController = TextEditingController();
  final TextEditingController _reliabilityController = TextEditingController();

  String _selectedLanguage = 'English';

  void _saveSource() async {
    if (_formKey.currentState!.validate()) {
      final source = Source(
        slug: _slugController.text.trim(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        url: _urlController.text.trim(),
        logoUrl: _logoUrlController.text.trim(),
        languages: _selectedLanguage,
        topics: [],
        reliabilityScore: int.tryParse(_reliabilityController.text.trim()) ?? 0,
      );

      await LocalAdminData.addSource(source);

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Source saved!')));

      _formKey.currentState!.reset();
      setState(() => _selectedLanguage = 'English');
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
            _buildTextField(_nameController, 'Source Name'),
            const SizedBox(height: 12),
            _buildTextField(_descriptionController, 'Description', maxLines: 3),
            const SizedBox(height: 12),
            _buildTextField(_urlController, 'Source URL'),
            const SizedBox(height: 12),
            _buildTextField(_logoUrlController, 'Logo URL'),
            const SizedBox(height: 12),
            _buildDropdown(),
            const SizedBox(height: 12),
            _buildTextField(_reliabilityController, 'Reliability Score', keyboardType: TextInputType.number),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveSource,
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

  Widget _buildTextField(TextEditingController controller, String label,
      {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      validator: (value) => value == null || value.isEmpty ? '$label is required' : null,
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedLanguage,
      items: const [
        DropdownMenuItem(value: 'English', child: Text('English')),
        DropdownMenuItem(value: 'Amharic', child: Text('Amharic')),
      ],
      onChanged: (value) => setState(() => _selectedLanguage = value!),
      decoration: InputDecoration(
        labelText: 'Language',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
