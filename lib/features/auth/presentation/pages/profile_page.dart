import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newsbrief/core/widgets/custom_dropdown_button.dart';
import 'package:newsbrief/core/widgets/topic_chip.dart';
import 'package:newsbrief/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:newsbrief/features/auth/presentation/cubit/auth_state.dart';
import 'package:newsbrief/features/auth/presentation/pages/manage_subscription.dart';
import 'package:newsbrief/features/auth/presentation/widgets/indicator_card.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  List<String> topics = [
    "Technology",
    "Sports",
    "Business",
    "Entertainment",
    "Health",
  ];
  bool isManagingTopics = false;

  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 100),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _removeTopic(String topic) {
    setState(() {
      topics.remove(topic);
    });
  }

  void _showAddTopicDialog() {
    TextEditingController controller = TextEditingController();
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: theme.scaffoldBackgroundColor,
          title: Text(
            "Add New Topic",
            style: TextStyle(color: theme.colorScheme.onBackground),
          ),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: "Enter topic name",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: TextStyle(color: theme.colorScheme.onBackground.withOpacity(0.6)),
              ),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  setState(() {
                    topics.add(controller.text);
                  });
                  Navigator.pop(context);
                }
              },
              child: Text(
                "Add",
                style: TextStyle(color: theme.colorScheme.primary),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        String? fullName;
        String? email;
        if (state is AuthAuthenticated) {
          fullName = state.user.fullName;
          email = state.user.email;
        }
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/root');
                        },
                        icon: Icon(Icons.arrow_back, color: theme.colorScheme.onBackground),
                      ),
                      Row(
                        children: [
                          CustomDropdownButton(
                            menuItems: [
                              "Edit profile",
                              if (!isManagingTopics) "Manage topic",
                              "Manage Subscription",
                              if (isManagingTopics) "Done",
                            ],
                            onSelected: (String result) {
                              switch (result) {
                                case "Edit profile":
                                  Navigator.pushNamed(context, '/edit');
                                  break;
                                case "Manage topic":
                                  setState(() {
                                    isManagingTopics = true;
                                  });
                                  break;
                                case "Done":
                                  setState(() {
                                    isManagingTopics = false;
                                  });
                                  break;
                                case "Manage Subscription":
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                      const ManageSubscriptionPage(),
                                    ),
                                  );
                                  break;
                              }
                            },
                            icon: Icon(Icons.edit, color: theme.colorScheme.onBackground),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/setting');
                            },
                            icon: Icon(
                              Icons.settings,
                              color: theme.colorScheme.onBackground,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: theme.colorScheme.surfaceVariant,
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    fullName ?? "John Doe",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onBackground,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    email ?? "johndoe@gmail.com",
                    style: TextStyle(
                      fontSize: 16,
                      color: theme.colorScheme.onBackground.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IndicatorCard(
                        title: "Subscribed",
                        count: 12,
                        color: theme.colorScheme.surfaceVariant,
                        onTap: () {
                          Navigator.pushNamed(context, '/following');
                        },
                      ),
                      IndicatorCard(
                        title: "Saved News",
                        count: 34,
                        color: theme.colorScheme.surfaceVariant,
                        onTap: () {
                          Navigator.pushNamed(context, '/saved');
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Your Interests",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onBackground,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          ...topics
                              .map(
                                (topic) => isManagingTopics
                                ? RotationTransition(
                              turns: Tween(begin: -0.001, end: 0.002)
                                  .animate(
                                CurvedAnimation(
                                  parent: _animationController,
                                  curve: const FlippedCurve(
                                    Curves.easeOutCubic,
                                  ),
                                ),
                              ),
                              child: TopicChip(
                                title: topic,
                                onDeleted: () => _removeTopic(topic),
                              ),
                            )
                                : TopicChip(title: topic, onDeleted: null),
                          )
                              .toList(),
                          if (isManagingTopics)
                            ActionChip(
                              label: Text(
                                "Add",
                                style: TextStyle(color: theme.colorScheme.onPrimary),
                              ),
                              avatar: Icon(
                                Icons.add,
                                color: theme.colorScheme.onPrimary,
                              ),
                              backgroundColor: theme.colorScheme.primary,
                              onPressed: _showAddTopicDialog,
                            ),
                          if (isManagingTopics)
                            ActionChip(
                              label: Text(
                                "Done",
                                style: TextStyle(color: theme.colorScheme.onBackground),
                              ),
                              backgroundColor: theme.colorScheme.surfaceVariant,
                              onPressed: () {
                                setState(() {
                                  isManagingTopics = false;
                                });
                              },
                            ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
