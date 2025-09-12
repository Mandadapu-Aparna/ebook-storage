import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    setState(() {
      _lastPage = lastPage;
    });

    // Navigate to last page after small delay to ensure PDF loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_lastPage > 0) {
        _pdfController.jumpToPage(_lastPage);
      }
    });
  }

  Future<void> _saveLastPage(int page) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_page_${widget.title}', page);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.green,
      ),
      body: SfPdfViewer.asset(
        widget.pdfPath,
        controller: _pdfController,
        onPageChanged: (details) {
          _saveLastPage(details.newPageNumber);
        },
      ),
    );
  }
}
