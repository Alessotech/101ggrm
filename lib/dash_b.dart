import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:stoc_one_2/profile_page.dart';
import 'package:stoc_one_2/widget/download_file_sec.dart';
import 'package:stoc_one_2/widget/service_name.dart';
import 'package:stoc_one_2/widget/service_statues.dart';
import 'package:stoc_one_2/widget/status_card.dart';

import ' ActivationKey/ActivationKeyManager.dart';


class pages1 extends StatefulWidget {
  const pages1({super.key});

  @override
  State<pages1> createState() => _pages1State();
}

class _pages1State extends State<pages1> {



  @override
  void initState() {
    FirebaseAuth.instance
        .authStateChanges()
        .listen((User? user) {
      if (user == null) {
        print('User is currently signed out!');
      } else {
        print('User is signed in!');
      }
    });

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: Icon(Icons.download_for_offline_rounded),
        actions: [
          IconButton(onPressed: () async {
            final keyManager = ActivationKeyManager();

// Generate a key
            String key = await keyManager.generateActivationKey(type: 'standard');

// Check key info
            Map<String, dynamic>? info = await keyManager.getKeyInfo(key);
          }, icon: Icon(Icons.generating_tokens)),
          // PopupMenuButton inside the AppBar
          PopupMenuButton<String>(
            child: Icon(Icons.person,
            color: Colors.white,
              size: 40,
            ),
            color: Colors.blue,
            offset: Offset(-50, 2),
            onSelected: (value) {
              // Handle selection
              if (value == 'edit') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              } else if (value == 'logout') {
               //logout
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                // Account Edit Option
                PopupMenuItem<String>(
                  value: 'edit',
                  child: Row(
                    children: const [
                      Icon(Icons.edit, color: Colors.black),
                      SizedBox(width: 8),
                      Text('Account Edit'),
                    ],
                  ),
                ),
                // Logout Option
                PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: const [
                      Icon(Icons.exit_to_app, color: Colors.black),
                      SizedBox(width: 8),
                      Text('Logout'),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],

      ),

      body: Expanded(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  height: 120,
                  width: 250,
                  child: ServiceNameWidget(
                    serviceName: "Envato",
                    icon: Icons.cloud,
                    backgroundColor: Colors.white,
                    iconColor: Colors.green,
                    onTap: () {
                      print("Web Hosting tapped");
                    },
                  ),
                ),
                SizedBox(width: 20,),
                SizedBox(
                  height: 100,
                  width: 250,
                  child: ServiceStatusWidget(
                    isActive: false,
                    serviceName: "API Service",
                  ),
                ),
              ],
            ),
            Row(
              children: [
                SizedBox(
                  height: 200,
                  width: 300,
                  child: DownloadCard(
                    icon: Icons.download,
                    iconBackgroundColor: Colors.blueGrey,
                    downloadLimit: "290/300 Daily Download Limit",
                    todayDownload: "Today Download",
                    progress: 0.96,
                  ),
                ) ,
                SizedBox(
                  height: 200,
                  width: 300,
                  child: DownloadCard(
                    icon: Icons.download,
                    iconBackgroundColor: Colors.blueGrey,
                    downloadLimit: "290/300 Daily Download Limit",
                    todayDownload: "Today Download",
                    progress: 0.96,
                  ),
                )

              ],
            ),
            DownloadWidgetWithTabs(
              title: "Download File",
              hint: "https://elements.envato.com/rastel-colorful-pop-art-powerpoint-template-TZSXSU2",
            )

          ],
        ),
      ),
    );
  }
}
