import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class InterestsScreen extends StatefulWidget {
  const InterestsScreen({super.key});

  @override
  State<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends State<InterestsScreen> {
  final Map<String, bool> selectedInterests = {};
  List<String> availableInterests = [];

  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(LoadInterestsEvent());
  }

  bool get canContinue => selectedInterests.values.where((v) => v).length >= 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Your Interests')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is InterestsLoaded) {
              availableInterests = state.interests;
              for (var i in availableInterests) {
                if (!selectedInterests.containsKey(i)) selectedInterests[i] = false;
              }
            } else if (state is InterestsSavedSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Interests saved!'), backgroundColor: Colors.green));
            } else if (state is AuthFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.error), backgroundColor: Colors.red));
            }
          },
          builder: (context, state) {
            if (state is AuthLoading && availableInterests.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Choose topics you\'re interested in',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 2.5,
                    ),
                    itemCount: availableInterests.length,
                    itemBuilder: (context, index) {
                      final category = availableInterests[index];
                      return FilterChip(
                        label: Text(category),
                        selected: selectedInterests[category]!,
                        onSelected: (bool selected) {
                          setState(() {
                            selectedInterests[category] = selected;
                          });
                        },
                        selectedColor: Colors.blue.withOpacity(0.2),
                        checkmarkColor: Colors.blue,
                        labelStyle: TextStyle(
                          color: selectedInterests[category]!
                              ? Colors.blue
                              : Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: selectedInterests[category]!
                                ? Colors.blue
                                : Colors.grey[300]!,
                            width: 1,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: canContinue
                        ? () {
                      final selected = selectedInterests.entries
                          .where((e) => e.value)
                          .map((e) => e.key)
                          .toList();
                      context
                          .read<AuthBloc>()
                          .add(SaveInterestsEvent(selected));
                    }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: canContinue
                          ? Colors.blue
                          : Colors.blue.withOpacity(0.5),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Continue',
                      style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            );
          },
        ),
      ),
    );
  }
}