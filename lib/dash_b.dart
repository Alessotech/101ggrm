import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:stoc_one_2/Envato_API/API.dart';
import 'package:stoc_one_2/profile_page.dart';
import 'package:stoc_one_2/widget/activation_Key_widget.dart';
import 'package:stoc_one_2/widget/download_file_sec.dart';
import 'package:stoc_one_2/widget/download_info_card.dart';
import 'package:stoc_one_2/widget/service_name.dart';
import 'package:stoc_one_2/widget/service_statues.dart';
import 'package:stoc_one_2/widget/status_card.dart';
import 'package:stoc_one_2/widget/subs_info_date.dart';

import ' ActivationKey/ActivationKeyManager.dart';

class pages1 extends StatefulWidget {
  const pages1({super.key});

  @override
  State<pages1> createState() => _pages1State();
}

class _pages1State extends State<pages1> {
  final GlobalKey<SubscriptionDownloadCardState> cardKey = GlobalKey();
  String? userId = FirebaseAuth.instance.currentUser?.email;
  final activationManager = ActivationKeyManager();
  bool IsAlreadyActivated = false;

  Future<void> checkplus() async {
    final activationStatus = await activationManager.checkAccountActivation(userId!);
    if (activationStatus['isActivated']) {
      print('Account is activated!');
      IsAlreadyActivated = true;
      print('Key type: ${activationStatus['keyInfo']['type']}');
    } else {
      print('Account is not activated');
    }
  }

  @override
  void initState() {
    //APi('https://elements.envato.com/stamp-in-retro-style-on-paper-mockup-template-92H7DVA');
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
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
    // Get screen size
    final Size screenSize = MediaQuery.of(context).size;
    final bool isDesktop = screenSize.width > 900;
    final bool isTablet = screenSize.width > 600 && screenSize.width <= 900;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        actions: [
          PopupMenuButton<String>(
            child: Icon(
              Icons.person,
              color: Colors.white,
              size: isDesktop ? 40 : 32,
            ),
            color: Colors.white,
            offset: const Offset(-50, -50),
            onSelected: (value) async {
              if (value == 'edit') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              } else if (value == 'logout') {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, '/login');
                //logout
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: Colors.black),
                      SizedBox(width: 8),
                      Text('Account Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
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
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(isDesktop ? 24.0 : 16.0),
          child: Container(
            color: Colors.white,
            child: Column(
              children: [
                // First Row - Service Widgets
                Container(
                  width: double.infinity,
                  child: Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    alignment: WrapAlignment.center,
                    children: [
                      SizedBox(
                        height: 120,
                        width: isDesktop ? 250 : (screenSize.width - 40) / 2,
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
                      SizedBox(
                        height: 120,
                        width: isDesktop ? 250 : (screenSize.width - 40) / 2,
                        child: const ServiceStatusWidget(
                          isActive: false,
                          serviceName: "API Service",
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Second Row - Download Cards and Activation
                Container(
                  width: double.infinity,
                  child: Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    alignment: WrapAlignment.center,
                    children: [
                      SizedBox(
                        height: 200,
                        width: isDesktop
                            ? 300
                            : isTablet
                            ? (screenSize.width - 60) / 2
                            : screenSize.width - 32,
                        child: SubscriptionDownloadCard(
                          activationManager: activationManager,
                          email: userId!,
                          key: cardKey,
                        ),
                      ),
                      SizedBox(
                        height: 200,
                        width: isDesktop
                            ? 300
                            : isTablet
                            ? (screenSize.width - 60) / 2
                            : screenSize.width - 32,
                        child:SubscriptionStatusWidget(
                          email:   userId!, // Use the user's email here
                          activationKeyManager: activationManager,
                        ),
                      ),
                      FutureBuilder<Map<String, dynamic>>(
                        future: ActivationKeyManager().checkAccountActivation(userId!),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const SizedBox.shrink();
                          }

                          final isActivated = snapshot.data?['isActivated'] ?? false;

                          if (isActivated == false) {
                            return Container(
                              width: isDesktop
                                  ? screenSize.width * 0.4
                                  : screenSize.width - 32,
                              child: KeyActivationWidget(),
                            );
                          }

                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Download Widget with Tabs
                Container(
                  color: Colors.white,
                  width: double.infinity,
                  child: DownloadWidgetWithTabs(
                    activationManager: activationManager,
               userId: userId!,
                    cardKey: cardKey,
                    downUrl:"https://elements.envato.com/zeus-gym-fitness-elementor-template-kit-XDPAJ9N" ,
                    title: "Download File",
                    hint: "https://elements.envato.com/rastel-colorful-pop-art-powerpoint-template-TZSXSU2",
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}