import 'package:flutter/material.dart';
class DownloadWidgetWithTabs extends StatefulWidget {
  final String title;
  final String hint;

  const DownloadWidgetWithTabs({
    Key? key,
    required this.title,
    required this.hint,
  }) : super(key: key);

  @override
  State<DownloadWidgetWithTabs> createState() => _DownloadWidgetWithTabsState();
}

class _DownloadWidgetWithTabsState extends State<DownloadWidgetWithTabs>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TabBar
            Row(
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width:  30),
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

            // Title


           Divider(
             thickness: 0.3,
           ),
            // Row with TextField and Download Icon
            Row(
              children: [
                // TextField for link input
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
                // Download Icon
                Container(
                  height: 40,
                  width: 40,
                  color: Colors.black,
                  child: Center(
                    child: IconButton(
                      onPressed: () {
                        // Action for download
                        print("Download button pressed");
                      },
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