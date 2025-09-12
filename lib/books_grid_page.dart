import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class BooksGridPage extends StatefulWidget {
  const BooksGridPage({super.key});

  final List<Map<String, String>> books = const [
    {
      "title": "The Alchemist",
      "author": "Paulo Coelho",
      "pdf": "assets/books/alchemist.pdf",
      "image": "assets/images/alchemist.jpg"
    },
    {
      "title": "Wings of Fire",
      "author": "A.P.J. Abdul Kalam",
      "pdf": "assets/books/wings_of_fire.pdf",
      "image": "assets/images/wings_of_fire.jpg"
    },
    {
      "title": "Harry Potter",
      "author": "J.K. Rowling",
      "pdf": "assets/books/harry_potter.pdf",
      "image": "assets/images/harry_potter.jpg"
    },
    {
      "title": "Rich Dad Poor Dad",
      "author": "Robert Kiyosaki",
      "pdf": "assets/books/rich_dad.pdf",
      "image": "assets/images/rich_dad.jpg"
    },
  ];

  @override
  State<BooksGridPage> createState() => _BooksGridPageState();
}

class _BooksGridPageState extends State<BooksGridPage> {
  Set<String> favorites = {};

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      favorites = prefs.getStringList('favorites')?.toSet() ?? {};
    });
  }

  Future<void> _toggleFavorite(String title) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (favorites.contains(title)) {
        favorites.remove(title);
      } else {
        favorites.add(title);
      }
    });
    await prefs.setStringList('favorites', favorites.toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Books"), backgroundColor: Colors.green),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.65,
        ),
        itemCount: widget.books.length,
        itemBuilder: (context, index) {
          final book = widget.books[index];
          final isFavorite = favorites.contains(book['title']);
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      PDFViewerPage(title: book["title"]!, pdfPath: book["pdf"]!),
                ),
              );
            },
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                          child: Image.asset(book["image"]!, fit: BoxFit.cover),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(book["title"]!,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            Text("by ${book["author"]!}",
                                style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: Icon(
                        isFavorite ? Icons.star : Icons.star_border,
                        color: isFavorite ? Colors.amber : Colors.grey,
                        size: 28,
                      ),
                      onPressed: () => _toggleFavorite(book['title']!),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class PDFViewerPage extends StatefulWidget {
  final String title;
  final String pdfPath;
  const PDFViewerPage({super.key, required this.title, required this.pdfPath});

  @override
  State<PDFViewerPage> createState() => _PDFViewerPageState();
}

class _PDFViewerPageState extends State<PDFViewerPage> {
  late PdfViewerController _pdfController;
  int _lastPage = 0;

  @override
  void initState() {
    super.initState();
    _pdfController = PdfViewerController();
    _loadLastPage();
  }

  Future<void> _loadLastPage() async {
    final prefs = await SharedPreferences.getInstance();
    final lastPage = prefs.getInt('last_page_${widget.title}') ?? 0;
    setState(() => _lastPage = lastPage);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_lastPage > 0) _pdfController.jumpToPage(_lastPage);
    });
  }

  Future<void> _saveLastPage(int page) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_page_${widget.title}', page);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title), backgroundColor: Colors.green),
      body: SfPdfViewer.asset(
        widget.pdfPath,
        controller: _pdfController,
        onPageChanged: (details) => _saveLastPage(details.newPageNumber),
      ),
    );
  }
}
