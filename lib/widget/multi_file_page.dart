import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stoc_one_2/Envato_API/powershellAPI.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Envato_API/powershellAPI.dart';

class MultiFileDownloadPage extends StatefulWidget {
  final String? userId;
  final dynamic activationManager;

  const MultiFileDownloadPage({
    Key? key,
    required this.userId,
    required this.activationManager,
  }) : super(key: key);

  @override
  State<MultiFileDownloadPage> createState() => _MultiFileDownloadPageState();
}

class _MultiFileDownloadPageState extends State<MultiFileDownloadPage> {
  final TextEditingController _urlController = TextEditingController();
  bool isLoading = false;
  List<Map<String, dynamic>> results = [];

  Future<void> _handleBatchDownload() async {
    setState(() {
      isLoading = true;
      results.clear();
    });

    final urls = _urlController.text
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (urls.length > 5) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Max 5 links allowed")),
      );
      return;
    }

    try {
      final batchResults = await StocipDownloader.batchDownload(urls);

      for (var result in batchResults) {
        if (result['success'] == true) {
          await widget.activationManager.incrementDownload(widget.userId);
        }
      }

      setState(() {
        results = batchResults;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> _downloadAllSuccessLinks() async {
    for (var result in results) {
      if (result['success'] == true && result['generatedText'] != null) {
        final uri = Uri.parse(result['generatedText']);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        }
      }
    }
  }

  Widget _buildResultsList() {
    if (results.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: results.map((item) {
        return ListTile(
          title: Text(item['url']),
          subtitle: item['success']
              ? GestureDetector(
            onTap: () async {
              final uri = Uri.parse(item['generatedText']);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              }
            },
            child: Text(
              item['generatedText'],
              style: const TextStyle(color: Colors.blue),
            ),
          )
              : const Text("❌ Failed to download", style: TextStyle(color: Colors.red)),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Multi File Downloader'),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Paste up to 5 links (one per line):',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _urlController,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: 'https://example.com/link1\nhttps://example.com/link2\n...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: isLoading ? null : _handleBatchDownload,
              icon: const Icon(Icons.file_download),
              label: isLoading
                  ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Start Download'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
            ),
            const SizedBox(height: 10),
            if (results.any((r) => r['success'] == true))
              ElevatedButton.icon(
                onPressed: _downloadAllSuccessLinks,
                icon: const Icon(Icons.open_in_browser),
                label: const Text('DOWNLOAD ALL'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
              ),
            const SizedBox(height: 20),
            if (results.isNotEmpty)
              const Text("Results:", style: TextStyle(fontWeight: FontWeight.bold)),
            Expanded(
              child: SingleChildScrollView(
                child: _buildResultsList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
