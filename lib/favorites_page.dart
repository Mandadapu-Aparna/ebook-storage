import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'books_grid_page.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  Set<String> favorites = {};
  List<Map<String, String>> favBooks = [];
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    favorites = prefs.getStringList('favorites')?.toSet() ?? {};
    _updateFavBooks();
  }

  void _updateFavBooks() {
    final allBooks = BooksGridPage().books;
    setState(() {
      favBooks = allBooks
          .where((book) => favorites.contains(book['title']))
          .where((book) => book['title']!.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    });
  }

  Future<void> _removeFavorite(String title) async {
    final prefs = await SharedPreferences.getInstance();
    favorites.remove(title);
    await prefs.setStringList('favorites', favorites.toList());
    _updateFavBooks();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("$title removed from favorites ❌")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Favorites"),
        backgroundColor: Colors.amber,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search favorites...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (val) {
                searchQuery = val;
                _updateFavBooks();
              },
            ),
          ),

          // Grid of favorites
          Expanded(
            child: favBooks.isEmpty
                ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star_border, size: 80, color: Colors.amber.shade200),
                  const SizedBox(height: 12),
                  const Text("No favorite books yet!", style: TextStyle(fontSize: 18)),
                ],
              ),
            )
                : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.65),
              itemCount: favBooks.length,
              itemBuilder: (context, index) {
                final book = favBooks[index];
                return Dismissible(
                  key: Key(book['title']!),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    color: Colors.red,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) => _removeFavorite(book['title']!),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: Image.asset(book["image"]!, fit: BoxFit.cover)),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(book["title"]!,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text("by ${book["author"]!}",
                                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
