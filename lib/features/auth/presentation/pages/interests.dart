import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newsbrief/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:newsbrief/features/auth/presentation/cubit/auth_state.dart';

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
    context.read<AuthCubit>().loadInterests();
  }

  bool get canContinue => selectedInterests.values.where((v) => v).length >= 3;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider.value(
      value: context.read<AuthCubit>(),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: BlocConsumer<AuthCubit, AuthState>(
              listener: (context, state) {
                if (state is InterestsLoaded) {
                  availableInterests = state.interests;
                  for (var i in availableInterests) {
                    if (!selectedInterests.containsKey(i)) selectedInterests[i] = false;
                  }
                } else if (state is InterestsSavedSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Interests saved!'.tr()),
                      backgroundColor: theme.colorScheme.primary,
                    ),
                  );
                } else if (state is AuthError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: theme.colorScheme.error,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is AuthLoading && availableInterests.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    const SizedBox(height: 16),
                    Expanded(
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 2.5,
                        ),
                        itemCount: availableInterests.length,
                        itemBuilder: (context, index) {
                          final category = availableInterests[index];
                          final isSelected = selectedInterests[category]!;
                          return FilterChip(
                            label: Text(category),
                            selected: isSelected,
                            onSelected: (bool selected) {
                              setState(() {
                                selectedInterests[category] = selected;
                              });
                            },
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
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: canContinue
                            ? () {
                          final selected = selectedInterests.entries
                              .where((e) => e.value)
                              .map((e) => e.key)
                              .toList();
                          context.read<AuthCubit>().saveInterests(selected);
                          Navigator.pushNamed(context, '/root');
                        }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: canContinue
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
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
