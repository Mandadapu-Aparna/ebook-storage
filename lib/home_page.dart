import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_screen.dart';
import 'profile_page.dart';
import 'books_grid_page.dart';
import 'favorites_page.dart';
import 'settings_page.dart';
import 'tasks_page.dart';
import 'feedback_page.dart';


class HomePage extends StatelessWidget {
  final ValueNotifier<bool> darkModeNotifier;

  const HomePage({super.key, required this.darkModeNotifier});

  Future<String> _getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("name") ?? "User";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: const Text("Home"),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AuthScreen(darkModeNotifier: darkModeNotifier),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<String>(
        future: _getUserName(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome, ${snapshot.data} 🎉",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    children: [
                      _buildHomeIcon(
                        context,
                        title: "Profile",
                        icon: Icons.person,
                        color: Colors.orangeAccent,
                        page: ProfilePage(darkModeNotifier: darkModeNotifier),
                      ),
                      const SizedBox(height: 30),
                      _buildHomeIcon(
                        context,
                        title: "Books",
                        icon: Icons.book,
                        color: Colors.green,
                        page: const BooksGridPage(),
                      ),
                      const SizedBox(height: 30),
                      _buildHomeIcon(
                        context,
                        title: "Favorites",
                        icon: Icons.star,
                        color: Colors.amber,
                        page: const FavoritesPage(),
                      ),
                      const SizedBox(height: 30),
                      _buildHomeIcon(
                        context,
                        title: "Tasks",
                        icon: Icons.task,
                        color: Colors.purple,
                        page: const TasksPage(),
                      ),
                      const SizedBox(height: 30),
                      _buildHomeIcon(
                        context,
                        title: "Feedback",
                        icon: Icons.feedback,
                        color: Colors.teal,
                        page: const FeedbackPage(),
                      ),

                      _buildHomeIcon(
                        context,
                        title: "Settings",
                        icon: Icons.settings,
                        color: Colors.teal,
                        page: SettingsPage(darkModeNotifier: darkModeNotifier),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHomeIcon(
      BuildContext context, {
        required String title,
        required IconData icon,
        required Color color,
        Widget? page,
      }) {
    return GestureDetector(
      onTap: () {
        if (page != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("$title clicked 🚀")),
          );
        }
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: color),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
