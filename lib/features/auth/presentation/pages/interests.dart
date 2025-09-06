import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newsbrief/features/auth/presentation/cubit/user_cubit.dart';

class InterestsScreen extends StatefulWidget {
  const InterestsScreen({super.key});

  @override
  State<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends State<InterestsScreen> {
  // Store interests by ID instead of label
  final Map<String, bool> selectedInterests = {};

  bool get canContinue => selectedInterests.values.where((v) => v).length >= 2;

  @override
  void initState() {
    super.initState();
    context.read<UserCubit>().loadAllTopics();
  }

  void _toggleInterest(String topicId, bool selected) {
    setState(() {
      selectedInterests[topicId] = selected;
    });
  }

  void _saveAndContinue(BuildContext context, UserState state) {
    if (state is AllTopicsLoaded) {
      final selectedTopicIds = selectedInterests.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key.toString()) // ✅ force to String
          .toList();

      debugPrint("✅ Subscribing to topics: $selectedTopicIds");

      context.read<UserCubit>().subscribe(selectedTopicIds);
      Navigator.pushNamed(context, '/root');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: BlocConsumer<UserCubit, UserState>(
          listener: (context, state) {
            if (state is UserActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Interests saved!'.tr()),
                  backgroundColor: theme.colorScheme.primary,
                ),
              );
            } else if (state is UserError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: theme.colorScheme.error,
                ),
              );
            } else if (state is TopicActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: theme.colorScheme.primary,
                ),
              );
            } else if (state is TopicError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: theme.colorScheme.error,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is UserLoading && selectedInterests.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is AllTopicsLoaded) {
              final topics = state.topics;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(theme: theme),
                  const SizedBox(height: 16),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 2.5,
                          ),
                      itemCount: topics.length,
                      itemBuilder: (context, index) {
                        final topic = topics[index];
                        final topicId = topic['id'].toString();
                        final label = topic['label']['en'] ?? topic['label'];

                        // initialize map with IDs
                        selectedInterests.putIfAbsent(topicId, () => false);
                        final isSelected = selectedInterests[topicId] ?? false;

                        return FilterChip(
                          label: Text(label),
                          selected: isSelected,
                          onSelected: (selected) =>
                              _toggleInterest(topicId, selected),
                          selectedColor: theme.colorScheme.primary,
                          checkmarkColor: theme.colorScheme.onPrimary,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onBackground,
                            fontWeight: FontWeight.w500,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.dividerColor,
                              width: 1,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  _ContinueButton(
                    theme: theme,
                    enabled: canContinue,
                    onPressed: () => _saveAndContinue(context, state),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final ThemeData theme;
  const _Header({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Text(
            'Welcome to NewsBrief'.tr(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onBackground,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.only(left: 24.0),
          child: Text(
            'What are you interested in?'.tr(),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onBackground,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 90.0),
          child: Text(
            'Choose three or more'.tr(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: theme.colorScheme.onBackground.withOpacity(0.6),
            ),
          ),
        ),
      ],
    );
  }
}

class _ContinueButton extends StatelessWidget {
  final ThemeData theme;
  final bool enabled;
  final VoidCallback onPressed;

  const _ContinueButton({
    required this.theme,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: enabled
              ? theme.colorScheme.primary
              : theme.colorScheme.primary.withOpacity(0.5),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          'Continue'.tr(),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }
}