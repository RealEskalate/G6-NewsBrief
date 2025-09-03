import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newsbrief/features/auth/presentation/cubit/user_cubit.dart';

class ManageSubscriptionPage extends StatefulWidget {
  const ManageSubscriptionPage({super.key});

  @override
  State<ManageSubscriptionPage> createState() => _ManageSubscriptionPageState();
}

class _ManageSubscriptionPageState extends State<ManageSubscriptionPage> {
  List<String> allSources = [];
  Set<String> subscribedSources = {};
  List<String> filteredSources = [];

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Fetch all sources and subscribed sources from UserCubit
    context.read<UserCubit>().loadAllSources();
    context.read<UserCubit>().loadSubscribedSources();
  }

  void _onSearchChanged(String query) {
    setState(() {
      filteredSources = allSources
          .where((source) =>
              source.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _toggleSubscription(String source) {
    final userCubit = context.read<UserCubit>();
    if (subscribedSources.contains(source)) {
      userCubit.removeSources(source);
    } else {
      userCubit.addSources(source);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: const Text(
          "Manage Subscriptions",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: BlocConsumer<UserCubit, UserState>(
        listener: (context, state) {
          if (state is AllSourcesLoaded) {
            setState(() {
              allSources = state.sources;
              filteredSources = allSources; // show all initially
            });
          } else if (state is SubscribedSourcesLoaded) {
            setState(() {
              subscribedSources = state.sources.toSet();
            });
          } else if (state is UserActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
            // Refresh subscriptions after action
            context.read<UserCubit>().loadSubscribedSources();
          } else if (state is UserError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is UserLoading && allSources.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // 🔍 Search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: "Search for sources...",
                    prefixIcon: const Icon(Icons.search, color: Colors.black54),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.black26),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.black26),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.black),
                    ),
                  ),
                ),
              ),

              // 📋 List of sources
              Expanded(
                child: ListView.builder(
                  itemCount: filteredSources.length,
                  itemBuilder: (context, index) {
                    final source = filteredSources[index];
                    final isSubscribed = subscribedSources.contains(source);

                    return ListTile(
                      title: Text(
                        source,
                        style: const TextStyle(color: Colors.black),
                      ),
                      trailing: ElevatedButton(
                        onPressed: () => _toggleSubscription(source),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: isSubscribed ? Colors.white : Colors.black,
                          backgroundColor: isSubscribed ? Colors.black : Colors.white,
                          side: const BorderSide(color: Colors.black, width: 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(isSubscribed ? "Subscribed" : "Subscribe"),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
