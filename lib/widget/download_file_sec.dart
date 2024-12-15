import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Envato_API/API.dart';
import 'download_info_card.dart';

class DownloadWidgetWithTabs extends StatefulWidget {
  final String title;
  final String hint;
  final String? userId;
  final String downUrl;
  final activationManager;
  final GlobalKey<SubscriptionDownloadCardState> cardKey;

  const DownloadWidgetWithTabs({
    Key? key,
    required this.title,
    required this.hint,
    required this.userId,
    required this.cardKey,
    required this.activationManager,
    required this.downUrl,
  }) : super(key: key);

  @override
  State<DownloadWidgetWithTabs> createState() => _DownloadWidgetWithTabsState();
}

class _DownloadWidgetWithTabsState extends State<DownloadWidgetWithTabs>
    with SingleTickerProviderStateMixin {
  final GlobalKey<SubscriptionDownloadCardState> cardKey = GlobalKey();
  late TabController _tabController;
  String? downloadUrl;
  bool isLoading = false;
  int currentTabIndex=0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        currentTabIndex = _tabController.index;
      });
      print(currentTabIndex);
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
      // Increment download count and get URL
      await widget.activationManager.incrementDownload(widget.userId!);
      if(currentTabIndex==1){
        final url = await getLicenceLink(widget.downUrl);
        setState(() {
          downloadUrl = url;
          isLoading = false;
        });
      }else{
        final url = await getDownloadLink(widget.downUrl);
        setState(() {
          downloadUrl = url;
          isLoading = false;
        });
      }


      // Show bottom sheet with options
      if (downloadUrl != null) {
        showModalBottomSheet(
          context: context,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder: (context) => DownloadOptionsSheet(
            downloadUrl: downloadUrl!,
            onCopyToClipboard: () {
              Clipboard.setData(ClipboardData(text: downloadUrl!));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('URL copied to clipboard')),
              );
              Navigator.pop(context);
            },
            onDirectDownload: () async {
              final uri = Uri.parse(downloadUrl!);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              }
              Navigator.pop(context);
            },
            onBulkDownload: () {
              Navigator.pop(context);
              _showBulkDownloadDialog();
            },
          ),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _showBulkDownloadDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Bulk Download'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Enter URLs (one per line)',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Implement bulk download logic here
                Navigator.pop(context);
              },
              child: Text('Start Bulk Download'),
            ),
          ],
        ),
      ),
    );
  }

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
                  style: TextStyle(
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
                        Tab(text: "Download"),
                        Tab(text: "License"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(thickness: 0.3),
            Row(
              children: [
                Expanded(
                  child: TextField(
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
                        borderSide: BorderSide(color: Colors.blue),
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
                        ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : IconButton(
                      onPressed: _handleDownloadOptions,
                      icon: Icon(
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

class DownloadOptionsSheet extends StatelessWidget {
  final String downloadUrl;
  final VoidCallback onCopyToClipboard;
  final VoidCallback onDirectDownload;
  final VoidCallback onBulkDownload;

  const DownloadOptionsSheet({
    Key? key,
    required this.downloadUrl,
    required this.onCopyToClipboard,
    required this.onDirectDownload,
    required this.onBulkDownload,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Download Options',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          ListTile(
            leading: Icon(Icons.copy),
            title: Text('Copy to Clipboard'),
            onTap: onCopyToClipboard,
          ),
          ListTile(
            leading: Icon(Icons.download),
            title: Text('Direct Download'),
            onTap: onDirectDownload,
          ),
          ListTile(
            leading: Icon(Icons.file_copy),
            title: Text('Download More Files'),
            onTap: onBulkDownload,
          ),
        ],
      ),
    );
  }
}