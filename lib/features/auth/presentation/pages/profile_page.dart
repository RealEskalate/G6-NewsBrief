import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newsbrief/core/widgets/custom_dropdown_button.dart';
import 'package:newsbrief/core/widgets/topic_chip.dart';
import 'package:newsbrief/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:newsbrief/features/auth/presentation/cubit/auth_state.dart';
import 'package:newsbrief/features/auth/presentation/pages/manage_subscription.dart';
import 'package:newsbrief/features/auth/presentation/widgets/indicator_card.dart';
import 'package:newsbrief/features/auth/presentation/cubit/user_cubit.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  bool isManagingTopics = false;

  List<Map<String, dynamic>> userTopics =
      []; // full topic objects with id + slug

  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 100),
      vsync: this,
    )..repeat(reverse: true);


    // Load subscribed topics from UserCubit

    context.read<UserCubit>().loadSubscribedTopics();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showAddTopicDialog() {
    final theme = Theme.of(context);

    // Ask the cubit to load all topics (if not already loaded)
    context.read<UserCubit>().loadAllTopics();

    showDialog(
      context: context,
      builder: (context) {

        return BlocBuilder<UserCubit, UserState>(
          builder: (context, state) {
            if (state is UserLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is AllTopicsLoaded) {
              final topics = state.topics;
              // print(topics); // this should be List<Map<String, dynamic>>
              return AlertDialog(
                backgroundColor: theme.scaffoldBackgroundColor,
                title: Text(
                  "add_new_topic".tr(),
                  style: TextStyle(color: theme.colorScheme.onBackground),
                ),
                content: SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: topics.length,
                    itemBuilder: (context, index) {
                      final topic = topics[index];
                      print(topic);
                      final label = topic['label']['en'];
                      return ListTile(
                        title: Text(
                          label,
                          style: TextStyle(
                            color: theme.colorScheme.onBackground,
                          ),
                        ),
                        onTap: () {
                          // Subscribe with the topic's ID
                          context.read<UserCubit>().subscribe([topic['id']]);
                          Navigator.pop(context);
                        },
                      );
                    },
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
                ],
              );
            } else if (state is UserError) {
              return AlertDialog(
                title: Text("error".tr()),
                content: Text(state.message),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("ok".tr()),
                  ),
                ],
              );
            } else {
              return const SizedBox.shrink();
            }
          },

        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = theme.brightness == Brightness.dark
        ? Colors.grey.shade900
        : Colors.grey.shade50;

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        String? fullName;
        String? email;
        if (authState is AuthAuthenticated) {
          fullName = authState.user.fullName;
          email = authState.user.email;
        }

        return Scaffold(
          backgroundColor: backgroundColor,
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

                        icon: Icon(
                          Icons.arrow_back,
                          color: theme.colorScheme.onBackground,
                        ),
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
                                    builder: (context) =>

                                        const ManageSubscriptionPage(),
                                  ),
                                );
                              }
                            },
                            icon: Icon(
                              Icons.edit,
                              color: theme.colorScheme.onBackground,
                            ),

                          ),
                          IconButton(
                            onPressed: () =>
                                Navigator.pushNamed(context, '/setting'),
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
                    fullName ?? "john_doe",
                    style: TextStyle(

                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onBackground,
                    ),

                  ),
                  const SizedBox(height: 8),
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

                        count: userTopics.length,
                        color: theme.colorScheme.surfaceVariant,

                        onTap: () => Navigator.pushNamed(context, '/following'),
                      ),
                      IndicatorCard(
                        title: "saved_news".tr(),
                        count: 34,
                        color: theme.brightness == Brightness.dark
                            ? Colors.blueGrey.shade800
                            : Colors.blueGrey.shade100,
                        onTap: () => Navigator.pushNamed(context, '/saved'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Your Interests
                  BlocConsumer<UserCubit, UserState>(
                    listener: (context, state) {
                      if (state is TopicActionSuccess) {
                        // Refresh topics after subscribe/unsubscribe
                        context.read<UserCubit>().loadSubscribedTopics();
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
                    builder: (context, state) {
                      bool isLoading = state is UserLoading;
                      if (state is SubscribedTopicsLoaded) {
                        userTopics = state.topics;
                        print(userTopics); // full topic objects
                      }

                      return Column(
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
                          if (isLoading)
                            const Center(child: CircularProgressIndicator())
                          else

                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                ...userTopics.map(
                                  (topic) => isManagingTopics
                                      ? RotationTransition(
                                          turns:
                                              Tween(
                                                begin: -0.001,
                                                end: 0.002,
                                              ).animate(
                                                CurvedAnimation(
                                                  parent: _animationController,
                                                  curve: const FlippedCurve(
                                                    Curves.easeOutCubic,
                                                  ),
                                                ),
                                              ),
                                          child: TopicChip(
                                            title: topic['label']['en'],
                                            onDeleted: () => context
                                                .read<UserCubit>()
                                                .unsubscribe(topic['id']),
                                          ),
                                        )
                                      : TopicChip(
                                          title: topic['label']['en'],
                                          onDeleted: null,
                                        ),
                                ),
                                if (isManagingTopics)
                                  ActionChip(
                                    label: Text(
                                      "Add".tr(),
                                      style: TextStyle(
                                        color: theme.colorScheme.onPrimary,
                                      ),
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
                                      style: TextStyle(
                                        color: theme.colorScheme.onBackground,
                                      ),
                                    ),
                                    backgroundColor:
                                        theme.colorScheme.surfaceVariant,
                                    onPressed: () => setState(
                                      () => isManagingTopics = false,
                                    ),

                                  ),
                                ],
                              ),
                        ],
                      );
                    },
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
