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
  bool envatoSubscription = false;
  bool freepikSubscription = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Key Management'),
        actions: [
          // IconButton(
          //   icon: Icon(Icons.refresh),
          //   onPressed: () => keyManager.resetDailyDownloads(),
          // ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showGenerateKeyDialog,
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
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          _buildStatCard('Active Keys', activeKeys),
          _buildStatCard('Total Keys', keys.length),
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
            children: [
              Text(title, style: TextStyle(fontSize: 16)),
              SizedBox(height: 8),
              Text(value.toString(), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(key['key'], style: TextStyle(fontFamily: 'monospace')),
            subtitle: Text('Type: ${key['type']} • Downloads: ${key['downloadsUsed']}/${key['downloadLimit']}'),
            trailing: key['isActive']
                ? IconButton(
              icon: Icon(Icons.delete_outline),
              onPressed: () => (),
            )
                : Chip(label: Text('Inactive')),
          ),
        );
      },
    );
  }

  Future<void> _showGenerateKeyDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Generate New Key'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                value: selectedKeyType,
                items: ['standard', 'premium'].map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => selectedKeyType = value!);
                },
              ),
              CheckboxListTile(
                title: Text('Enable Envato Subscription'),
                value: envatoSubscription,
                onChanged: (value) => setState(() => envatoSubscription = value!),
              ),
              CheckboxListTile(
                title: Text('Enable Freepik Subscription'),
                value: freepikSubscription,
                onChanged: (value) => setState(() => freepikSubscription = value!),
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
              await keyManager.generateActivationKey(
                type: selectedKeyType,
                envatoSubscription: envatoSubscription,
                freepikSubscription: freepikSubscription,
              );
              Navigator.pop(context);
            },
            child: Text('Generate'),
          ),
        ],
      ),
    );
  }
}
