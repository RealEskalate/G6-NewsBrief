import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newsbrief/features/auth/presentation/cubit/user_cubit.dart' hide AllTopicsLoaded;
import 'package:newsbrief/features/auth/presentation/cubit/admin_cubit.dart';

class InterestsScreen extends StatefulWidget {
  const InterestsScreen({super.key});

  @override
  State<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends State<InterestsScreen> {
  final Map<String, bool> selectedInterests = {};
  final List<String> mergedTopics = [];

  @override
  void initState() {
    super.initState();
    // Load user topics
    context.read<UserCubit>().loadAllTopics();
    // Load admin topics
    context.read<AdminCubit>().loadAllTopics();
  }

  bool get canContinue => selectedInterests.values.where((v) => v).length >= 3;

  void _mergeTopics(List<String> userTopics, List<String> adminTopics) {
    final allTopics = {...userTopics, ...adminTopics}.toList();
    mergedTopics.clear();
    mergedTopics.addAll(allTopics);

    for (var topic in allTopics) {
      selectedInterests.putIfAbsent(topic, () => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MultiBlocListener(
      listeners: [
        BlocListener<UserCubit, UserState>(
          listener: (context, state) {
            if (state is SubscribedTopicsLoaded) {
              _mergeTopics(
                state.topics, // user subscribed topics
                mergedTopics, // keep existing admin topics
              );
              setState(() {});
            } else if (state is UserActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
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
            }
          },
        ),
        BlocListener<AdminCubit, AdminState>(
          listener: (context, state) {
            if (state is AllTopicsLoaded) {
              _mergeTopics(
                mergedTopics, // keep previously merged topics
                state.topics.map((t) => t.label['en'] ?? t.slug).toList(),
              );
              setState(() {});
            } else if (state is AdminActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: theme.colorScheme.primary,
                ),
              );
            } else if (state is AdminError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: theme.colorScheme.error,
                ),
              );
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(title: const Text("Select Interests")),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 3,
                  ),
                  itemCount: selectedInterests.length,
                  itemBuilder: (context, index) {
                    final key = selectedInterests.keys.elementAt(index);
                    final value = selectedInterests[key]!;
                    return FilterChip(
                      label: Text(key),
                      selected: value,
                      onSelected: (bool selected) {
                        setState(() {
                          selectedInterests[key] = selected;
                        });
                      },
                      selectedColor: theme.colorScheme.primary,
                      checkmarkColor: theme.colorScheme.onPrimary,
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: canContinue
                    ? () {
                  final selected = selectedInterests.entries
                      .where((e) => e.value)
                      .map((e) => e.key)
                      .toList();
                  context.read<UserCubit>().saveInterests(selected);
                  Navigator.pushNamed(context, '/root');
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text("Continue"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
