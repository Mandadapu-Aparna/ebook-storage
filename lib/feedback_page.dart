import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final TextEditingController _controller = TextEditingController();
  List<String> _feedbackList = [];

  @override
  void initState() {
    super.initState();
    _loadFeedback();
  }

  // Load saved feedback from SharedPreferences
  Future<void> _loadFeedback() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _feedbackList = prefs.getStringList('feedback') ?? [];
    });
  }

  // Save feedback to SharedPreferences
  Future<void> _saveFeedback(String feedback) async {
    final prefs = await SharedPreferences.getInstance();
    _feedbackList.add(feedback);
    await prefs.setStringList('feedback', _feedbackList);
  }

  void _submitFeedback() {
    final feedback = _controller.text.trim();
    if (feedback.isEmpty) return;

    _saveFeedback(feedback);
    setState(() {}); // refresh the UI
    _controller.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Feedback submitted! 🎉")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Feedback"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "We value your feedback! 💬",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: "Enter your feedback here...",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              onPressed: _submitFeedback,
              child: const Text("Submit"),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),
            const Text(
              "Previous Feedback:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _feedbackList.isEmpty
                  ? const Center(child: Text("No feedback yet."))
                  : ListView.builder(
                itemCount: _feedbackList.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      leading: const Icon(Icons.feedback, color: Colors.teal),
                      title: Text(_feedbackList[index]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
