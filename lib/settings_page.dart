import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('darkMode') ?? false;

  runApp(MyApp(isDarkMode: isDarkMode));
}

class MyApp extends StatefulWidget {
  final bool isDarkMode;
  const MyApp({super.key, required this.isDarkMode});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ValueNotifier<bool> darkModeNotifier;

  @override
  void initState() {
    super.initState();
    darkModeNotifier = ValueNotifier(widget.isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: darkModeNotifier,
      builder: (context, isDarkMode, _) {
        return MaterialApp(
          title: 'Settings Demo',
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.teal,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.teal,
          ),
          themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: HomePage(darkModeNotifier: darkModeNotifier),
        );
      },
    );
  }
}

class HomePage extends StatelessWidget {
  final ValueNotifier<bool> darkModeNotifier;
  const HomePage({super.key, required this.darkModeNotifier});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home Page")),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SettingsPage(darkModeNotifier: darkModeNotifier),
              ),
            );
          },
          child: const Text("Go to Settings"),
        ),
      ),
    );
  }
}

class SettingsPage extends StatefulWidget {
  final ValueNotifier<bool> darkModeNotifier;
  const SettingsPage({super.key, required this.darkModeNotifier});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      notificationsEnabled = prefs.getBool('notifications') ?? true;
    });
  }

  Future<void> _updateDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    widget.darkModeNotifier.value = value;
    await prefs.setBool('darkMode', value);
  }

  Future<void> _updateNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => notificationsEnabled = value);
    await prefs.setBool('notifications', value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: SwitchListTile(
              title: const Text("Dark Mode"),
              secondary: const Icon(Icons.dark_mode),
              value: widget.darkModeNotifier.value,
              onChanged: _updateDarkMode,
            ),
          ),
          Card(
            child: SwitchListTile(
              title: const Text("Notifications"),
              secondary: const Icon(Icons.notifications),
              value: notificationsEnabled,
              onChanged: _updateNotifications,
            ),
          ),
        ],
      ),
    );
  }
}
