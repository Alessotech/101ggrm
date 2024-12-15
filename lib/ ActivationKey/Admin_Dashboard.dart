// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// import 'ActivationKeyManager.dart';
//
// class KeyDashboard extends StatefulWidget {
//   @override
//   _KeyDashboardState createState() => _KeyDashboardState();
// }
//
// class _KeyDashboardState extends State<KeyDashboard> {
//   final ActivationKeyManager keyManager = ActivationKeyManager();
//   String selectedKeyType = 'standard';
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Key Management'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.refresh),
//             onPressed: () => keyManager.resetDailyDownloads(),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _showGenerateKeyDialog,
//         child: Icon(Icons.add),
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('activationKeys')
//             .orderBy('createdAt', descending: true)
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
//
//           final keys = snapshot.data!.docs;
//
//           return Column(
//             children: [
//               _buildStatCards(keys),
//               Expanded(
//                 child: _buildKeyList(keys),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildStatCards(List<QueryDocumentSnapshot> keys) {
//     final activeKeys = keys.where((k) => k['isActive'] == true).length;
//     final totalDownloads = keys.fold<int>(
//       0,
//           (sum, key) => sum + (key['downloadsUsed'] as int),
//     );
//
//     return Padding(
//       padding: EdgeInsets.all(16),
//       child: Row(
//         children: [
//           _buildStatCard('Total Keys', keys.length),
//           SizedBox(width: 16),
//           _buildStatCard('Active Keys', activeKeys),
//           SizedBox(width: 16),
//           _buildStatCard('Downloads Today', totalDownloads),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildStatCard(String title, int value) {
//     return Expanded(
//       child: Card(
//         child: Padding(
//           padding: EdgeInsets.all(16),
//           child: Column(
//             children: [
//               Text(title, style: TextStyle(fontSize: 16)),
//               SizedBox(height: 8),
//               Text(
//                 value.toString(),
//                 style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildKeyList(List<QueryDocumentSnapshot> keys) {
//     return ListView.builder(
//       itemCount: keys.length,
//       itemBuilder: (context, index) {
//         final key = keys[index];
//         return Card(
//           margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           child: ListTile(
//             title: Text(key['key'], style: TextStyle(fontFamily: 'monospace')),
//             subtitle: Text('Type: ${key['type']} • Downloads: ${key['downloadsUsed']}/${key['downloadLimit']}'),
//             trailing: key['isActive']
//                 ? IconButton(
//               icon: Icon(Icons.delete_outline),
//               onPressed: () => _deactivateKey(key['key']),
//             )
//                 : Chip(label: Text('Inactive')),
//           ),
//         );
//       },
//     );
//   }
//
//   Future<void> _showGenerateKeyDialog() async {
//     return showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Generate New Key'),
//         content: StatefulBuilder(
//           builder: (context, setState) => Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               DropdownButton<String>(
//                 value: selectedKeyType,
//                 items: ['standard', 'premium'].map((type) {
//                   return DropdownMenuItem(
//                     value: type,
//                     child: Text(type.toUpperCase()),
//                   );
//                 }).toList(),
//                 onChanged: (value) {
//                   setState(() => selectedKeyType = value!);
//                 },
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               await keyManager.generateActivationKey(type: selectedKeyType);
//               Navigator.pop(context);
//             },
//             child: Text('Generate'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Future<void> _deactivateKey(String key) async {
//     await keyManager.deactivateKey(key);
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'ActivationKeyManager.dart';

class KeyDashboard extends StatefulWidget {
  @override
  _KeyDashboardState createState() => _KeyDashboardState();
}

class _KeyDashboardState extends State<KeyDashboard> {
  final ActivationKeyManager keyManager = ActivationKeyManager();
  String selectedKeyType = 'standard';

  // Custom key generation fields
  int customDownloadLimit = 100;
  int customDurationDays = 30;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Key Management'),
        actions: [
          IconButton(
            icon: Icon(Icons.download),
            onPressed: () => keyManager.resetDailyDownloads(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showKeyGenerationOptions,
        child: Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('activationKeys')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final keys = snapshot.data!.docs;
          return Column(
            children: [
              _buildStatCards(keys),
              Expanded(
                child: _buildKeyList(keys),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCards(List<QueryDocumentSnapshot> keys) {
    final activeKeys = keys.where((k) => k['isActive'] == true).length;
    final expiredKeys = keys.where((k) =>
    k['expiresAt'] != null &&
        (k['expiresAt'] as Timestamp).toDate().isBefore(DateTime.now())
    ).length;
    final usedKeys = keys.where((k) =>
    k['downloadsUsed'] >= k['downloadLimit']
    ).length;

    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          _buildStatCard('Active Keys', activeKeys),
          SizedBox(width: 8),
          _buildStatCard('Expired Keys', expiredKeys),
          SizedBox(width: 8),
          _buildStatCard('Used Keys', usedKeys),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, int value) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
              Text('$value', style: TextStyle(fontSize: 24)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeyList(List<QueryDocumentSnapshot> keys) {
    return ListView.builder(
      itemCount: keys.length,
      itemBuilder: (context, index) {
        final key = keys[index];
        final expiryDate = key['expiresAt'] != null
            ? (key['expiresAt'] as Timestamp).toDate()
            : null;
        final isExpired = expiryDate?.isBefore(DateTime.now()) ?? false;
        final isUsed = key['downloadsUsed'] >= key['downloadLimit'];

        return Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Row(
              children: [
                Expanded(
                  child: Text(key['key'], style: TextStyle(fontFamily: 'monospace')),
                ),
                IconButton(
                  icon: Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: key['key']));
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Key copied to clipboard'))
                    );
                  },
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Type: ${key['type']} • Downloads: ${key['downloadsUsed']}/${key['downloadLimit']}'),
                if (expiryDate != null)
                  Text('Expires: ${expiryDate.toString().split('.')[0]}'),
                Row(
                  children: [
                    if (isExpired)
                      Chip(label: Text('Expired'), backgroundColor: Colors.red[100]),
                    if (isUsed)
                      Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Chip(label: Text('Used'), backgroundColor: Colors.orange[100]),
                      ),
                  ],
                ),
              ],
            ),
            trailing: key['isActive']
                ? IconButton(
              icon: Icon(Icons.delete_outline),
              onPressed: () => _deactivateKey(key['key']),
            )
                : Chip(label: Text('Inactive')),
          ),
        );
      },
    );
  }

  void _showKeyGenerationOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Generate Key'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Quick Generate'),
              subtitle: Text('Standard or Premium preset'),
              onTap: () {
                Navigator.pop(context);
                _showQuickGenerateDialog();
              },
            ),
            ListTile(
              title: Text('Custom Generate'),
              subtitle: Text('Custom limits and duration'),
              onTap: () {
                Navigator.pop(context);
                _showCustomGenerateDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showQuickGenerateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Quick Generate Key'),
        content: StatefulBuilder(
          builder: (context, setState) => DropdownButton<String>(
            value: selectedKeyType,
            items: ['standard', 'premium'].map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(type.toUpperCase()),
              );
            }).toList(),
            onChanged: (value) => setState(() => selectedKeyType = value!),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await keyManager.generateActivationKey(type: selectedKeyType);
              Navigator.pop(context);
            },
            child: Text('Generate'),
          ),
        ],
      ),
    );
  }

  void _showCustomGenerateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Custom Generate Key'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Download Limit'),
                keyboardType: TextInputType.number,
                onChanged: (value) => setState(() =>
                customDownloadLimit = int.tryParse(value) ?? 100
                ),
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Duration (days)'),
                keyboardType: TextInputType.number,
                onChanged: (value) => setState(() =>
                customDurationDays = int.tryParse(value) ?? 30
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await keyManager.generateCustomKey(
                downloadLimit: customDownloadLimit,
                durationMonths: customDurationDays,
              );
              Navigator.pop(context);
            },
            child: Text('Generate'),
          ),
        ],
      ),
    );
  }

  Future<void> _deactivateKey(String key) async {
    await keyManager.deactivateKey(key);
  }
}