import 'package:easy_localization/easy_localization.dart';
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
  // Use raw keys and translate dynamically
  List<String> topicKeys = ["Technology", "Sports", "Business", "Entertainment", "Health"];
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

  void _removeTopic(String topicKey) {
    setState(() {
      topicKeys.remove(topicKey);
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
            "add_new_topic".tr(),
            style: TextStyle(color: theme.colorScheme.onBackground),
          ),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: "enter_topic_name".tr(),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "cancel".tr(),
                style: TextStyle(
                  color: theme.colorScheme.onBackground.withOpacity(0.6),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  setState(() {
                    topicKeys.add(controller.text);
                  });
                  Navigator.pop(context);
                }
              },
              child: Text(
                "add".tr(),
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

    // Translate topics dynamically
    final topics = topicKeys.map((key) => key.tr()).toList();

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
                  // Top Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pushNamed(context, '/root'),
                        icon: Icon(Icons.arrow_back, color: theme.colorScheme.onBackground),
                      ),
                      Row(
                        children: [
                          CustomDropdownButton(
                            menuItems: [
                              "edit_profile".tr(),
                              if (!isManagingTopics) "manage_topic".tr(),
                              "manage_subscription".tr(),
                              if (isManagingTopics) "done".tr(),
                            ],
                            onSelected: (String result) {
                              if (result == "edit_profile".tr()) {
                                Navigator.pushNamed(context, '/edit');
                              } else if (result == "manage_topic".tr()) {
                                setState(() => isManagingTopics = true);
                              } else if (result == "done".tr()) {
                                setState(() => isManagingTopics = false);
                              } else if (result == "manage_subscription".tr()) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ManageSubscriptionPage(),
                                  ),
                                );
                              }
                            },
                            icon: Icon(Icons.edit, color: theme.colorScheme.onBackground),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pushNamed(context, '/setting'),
                            icon: Icon(Icons.settings, color: theme.colorScheme.onBackground),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Avatar
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

                  // Full Name
                  Text(
                    fullName ?? "john_doe",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onBackground,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Email
                  Text(
                    email ?? "johndoe_email",
                    style: TextStyle(
                      fontSize: 16,
                      color: theme.colorScheme.onBackground.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Indicator Cards
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IndicatorCard(
                        title: "subscribed".tr(),
                        count: 12,
                        color: theme.colorScheme.surfaceVariant,
                        onTap: () => Navigator.pushNamed(context, '/following'),
                      ),
                      IndicatorCard(
                        title: "saved_news".tr(),
                        count: 34,
                        color: theme.colorScheme.surfaceVariant,
                        onTap: () => Navigator.pushNamed(context, '/saved'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Topics
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "your_interests".tr(),
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
                          ...List.generate(topics.length, (index) {
                            final topic = topics[index];
                            final key = topicKeys[index];
                            return isManagingTopics
                                ? RotationTransition(
                              turns: Tween(begin: -0.001, end: 0.002)
                                  .animate(CurvedAnimation(
                                parent: _animationController,
                                curve: const FlippedCurve(Curves.easeOutCubic),
                              )),
                              child: TopicChip(
                                title: topic,
                                onDeleted: () => _removeTopic(key),
                              ),
                            )
                                : TopicChip(title: topic, onDeleted: null);
                          }),
                          if (isManagingTopics)
                            ActionChip(
                              label: Text(

                                "Add".tr(),
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
                                "done".tr(),
                                style: TextStyle(color: theme.colorScheme.onBackground),
                              ),
                              backgroundColor: theme.colorScheme.surfaceVariant,
                              onPressed: () => setState(() => isManagingTopics = false),
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
