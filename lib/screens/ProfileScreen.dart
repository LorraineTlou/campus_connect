import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../widgets/post_card.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),

          /// Profile Info
          CircleAvatar(
            radius: 40,
            child: Text(user.name[0]),
          ),
          const SizedBox(height: 10),
          Text(user.name, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 5),
          Text(user.bio, style: const TextStyle(color: Colors.grey)),

          const Divider(height: 30),

          /// Posts
          const Text("Posts", style: TextStyle(fontSize: 18)),
          Expanded(
            child: ListView.builder(
              itemCount: user.posts.length,
              itemBuilder: (context, index) {
                return PostCard(content: user.posts[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}