import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Envato_API/API.dart';
import '../Envato_API/WebDAVRoot_API.dart';
import '../Envato_API/powershellAPI.dart';
import 'download_info_card.dart';

class DownloadWidgetWithTabs extends StatefulWidget {
  final String title;
  final String hint;
  final String? userId;
  final dynamic apiFunction;
  final String apiParams;
  final activationManager;
  final GlobalKey<SubscriptionDownloadCardState> cardKey;

  const DownloadWidgetWithTabs({
    Key? key,
    required this.title,
    required this.hint,
    required this.userId,
    required this.apiFunction,
    required this.apiParams,
    required this.cardKey,
    required this.activationManager,
  }) : super(key: key);

  @override
  State<DownloadWidgetWithTabs> createState() => _DownloadWidgetWithTabsState();
}

class _DownloadWidgetWithTabsState extends State<DownloadWidgetWithTabs>
    with SingleTickerProviderStateMixin {
  final GlobalKey<SubscriptionDownloadCardState> cardKey = GlobalKey();
  late TabController _tabController;
  TextEditingController textEditingController = TextEditingController();
  bool isLoading = false;
  int currentTabIndex = 0;
  String? url;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        currentTabIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(() {});
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleDownloadOptions() async {
    setState(() {
      isLoading = true;
    });

    try {
      String inputUrl = textEditingController.text.trim();

      // **Dynamically call API function based on parameters**
      if (widget.apiParams.isEmpty) {
        url = await widget.apiFunction(inputUrl);
      } else {
        url = await widget.apiFunction(widget.apiParams, inputUrl);
      }

      // Ensure that the download URL is valid before incrementing download count
      if (url == null || url!.isEmpty) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Download failed: Invalid URL'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Now increment the download count since we have a valid URL
      final status = await widget.activationManager.incrementDownload(widget.userId!);
      if (!status['success']) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(status['message'] ?? 'Cannot download at this time'), backgroundColor: Colors.red),
        );
        return;
      }

      setState(() {
        isLoading = false;
      });

      // Show download options
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (context) => DownloadOptionsSheet(
          downloadUrl: url!,
          onCopyToClipboard: () {
            Clipboard.setData(ClipboardData(text: url!));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('URL copied to clipboard')),
            );
            Navigator.pop(context);
          },
          onDirectDownload: () async {
            final uri = Uri.parse(url!);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri);
            }
            Navigator.pop(context);
          },
        ),
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: PLease Try again Later >> '),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // void _showBulkDownloadDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Bulk Download'),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           TextField(
  //             decoration: const InputDecoration(
  //               hintText: 'Enter URLs (one per line)',
  //               border: OutlineInputBorder(),
  //             ),
  //             maxLines: 5,
  //           ),
  //           const SizedBox(height: 16),
  //           ElevatedButton(
  //             onPressed: () {
  //               Navigator.pop(context);
  //             },
  //             child: const Text('Start Bulk Download'),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 30),
                Expanded(
                  child: Align(
                    alignment: Alignment.topRight,
                    child: TabBar(
                      controller: _tabController,
                      labelColor: Colors.blue,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Colors.blue,
                      tabs: const [
                        Tab(text: "File"),
                        Tab(text: "License"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(thickness: 0.3),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: textEditingController,
                    decoration: InputDecoration(
                      hintText: widget.hint,
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.blue),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  height: 40,
                  width: 40,
                  color: Colors.black,
                  child: Center(
                    child: isLoading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : IconButton(
                      onPressed: _handleDownloadOptions,
                      icon: const Icon(
                        Icons.download,
                        color: Colors.white,
                      ),
                      iconSize: 20,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Download Options Sheet
class DownloadOptionsSheet extends StatelessWidget {
  final String downloadUrl;
  final VoidCallback onCopyToClipboard;
  final VoidCallback onDirectDownload;
  //final VoidCallback onBulkDownload;

  const DownloadOptionsSheet({
    Key? key,
    required this.downloadUrl,
    required this.onCopyToClipboard,
    required this.onDirectDownload,
   // required this.onBulkDownload,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Download Options', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ListTile(leading: const Icon(Icons.copy), title: const Text('Copy to Clipboard'), onTap: onCopyToClipboard),
          ListTile(leading: const Icon(Icons.download), title: const Text('Direct Download'), onTap: onDirectDownload),
          //ListTile(leading: const Icon(Icons.file_copy), title: const Text('Download More Files'), onTap: onBulkDownload),
        ],
      ),
    );
  }
}
