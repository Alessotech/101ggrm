import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stoc_one_2/Envato_API/API.dart';
import 'package:stoc_one_2/Envato_API/powershellAPI.dart';
import 'package:stoc_one_2/profile_page.dart';
import 'package:stoc_one_2/widget/activation_Key_widget.dart';
import 'package:stoc_one_2/widget/download_file_sec.dart';
import 'package:stoc_one_2/widget/download_info_card.dart';
import 'package:stoc_one_2/widget/service_name.dart';
import 'package:stoc_one_2/widget/service_statues.dart';
import 'package:stoc_one_2/widget/status_card.dart';
import 'package:stoc_one_2/widget/subs_info_date.dart';
import ' ActivationKey/ActivationKeyManager.dart';
import 'Envato_API/powershellAPI.dart';
import 'Envato_API/powershellAPI.dart';
import 'Login.dart';

class Pages1 extends StatefulWidget {
  const Pages1({super.key});

  @override
  State<Pages1> createState() => _Pages1State();
}

class _Pages1State extends State<Pages1> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<SubscriptionDownloadCardState> cardKey = GlobalKey();
  final GlobalKey<SubscriptionDownloadCardState> cardKey2 = GlobalKey();
  String? userId = FirebaseAuth.instance.currentUser?.email;
  final activationManager = ActivationKeyManager();
  bool IsAlreadyActivated = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (mounted) {
        setState(() {
          userId = user?.email;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final bool isDesktop = screenSize.width > 900;
    final bool isTablet = screenSize.width > 600 && screenSize.width <= 900;
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
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
      body: Column(
        children: [
          // Service Selection
          Container(
            width: double.infinity,
            child: Wrap(
              spacing: 20,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: [
                Row(
                  children: [
                    SizedBox(
                      height: 120,
                      width: isDesktop ? 250 : (screenSize.width - 40) / 2,
                      child: ServiceNameWidget(
                        serviceName: "freepik",
                        icon: Icons.cloud,
                        backgroundColor: Colors.white,
                        iconColor: Colors.blue,
                        onTap: () {
                          _tabController.animateTo(0);
                        },
                      ),
                    ),
                    SizedBox(
                      height: 120,
                      width: isDesktop ? 250 : (screenSize.width - 40) / 2,
                      child: ServiceNameWidget(
                        serviceName: "envato",
                        icon: Icons.cloud,
                        backgroundColor: Colors.white,
                        iconColor: Colors.green,
                        onTap: () {
                          _tabController.animateTo(1);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Subscription Status and Downloads
          Expanded(
            child: Focus(
              onFocusChange: (hasFocus) {
                if (hasFocus) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollToBottom();
                  });
                }
              },
              child: Container(
                color: Colors.white,
                width: double.infinity,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    Column(
                      children: [
                        Row(
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
                                    SizedBox(width: 20,),
                            SizedBox(
                              height: 200,
                              width: isDesktop
                                  ? 300
                                  : isTablet
                                  ? (screenSize.width - 60) / 2
                                  : screenSize.width - 32,
                              child: SubscriptionStatusWidget(
                                email: userId!,
                                activationKeyManager: activationManager,
                              ),
                            ),
                          ],
                        ),

                        DownloadWidgetWithTabs(
                          activationManager: activationManager,
                          userId: userId!,
                          cardKey: cardKey,
                          title: "Freepik Downloads",
                          hint: "https://www.freepik.com/premium-photo/trees-growing-forest_133341099.htm",
                          apiFunction: getDownloadLink,
                          apiParams: '',
                        ),
                      ],
                    ),

                    Column(
                      children: [
                        Row(
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
                                 SizedBox(width:20),
                            SizedBox(
                              height: 200,
                              width: isDesktop
                                  ? 300
                                  : isTablet
                                  ? (screenSize.width - 60) / 2
                                  : screenSize.width - 32,
                              child: SubscriptionStatusWidget(
                                email: userId!,
                                activationKeyManager: activationManager,
                              ),
                            ),
                          ],
                        ),

                        DownloadWidgetWithTabs(
                          activationManager: activationManager,
                          userId: userId!,
                          cardKey: cardKey2,
                          title: "Envato Downloads",
                          hint: "https://elements.envato.com/bright-white-neon-sound-waves-seamless-motion-radi-ZY5YFHR",
                          apiFunction:  SimpleHttpRequest.getDownloadUrl,
                          apiParams: "t4",
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
