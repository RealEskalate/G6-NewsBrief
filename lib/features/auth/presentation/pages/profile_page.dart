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
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            "Add New Topic",
            style: TextStyle(color: Colors.black),
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
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.black54),
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
              child: const Text("Add", style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        String? fullName;
        String? email;
        if (state is AuthAuthenticated) {
          fullName = state.user.fullName;
          email = state.user.email;
        }
        return Scaffold(
          backgroundColor: Colors.white,
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
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
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
                            icon: const Icon(Icons.edit),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/setting');
                            },
                            icon: const Icon(
                              Icons.settings,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey.shade300,
                    child: const Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    fullName ?? "John Doe",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),
                  Text(
                    email ?? "johndoe@gmail.com",
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IndicatorCard(
                        title: "Subscribed",
                        count: 12,
                        color: Colors.grey.shade100,
                        onTap: () {
                          Navigator.pushNamed(context, '/following');
                        },
                      ),
                      IndicatorCard(
                        title: "Saved News",
                        count: 34,
                        color: Colors.grey.shade400,
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
                      const Text(
                        "Your Interests",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
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
                              label: const Text(
                                "Add",
                                style: TextStyle(color: Colors.white),
                              ),
                              avatar: const Icon(
                                Icons.add,
                                color: Colors.white,
                              ),
                              backgroundColor: Colors.black,
                              onPressed: _showAddTopicDialog,
                            ),
                          if (isManagingTopics)
                            ActionChip(
                              label: const Text(
                                "Done",
                                style: TextStyle(color: Colors.black),
                              ),
                              backgroundColor: Colors.white,
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
