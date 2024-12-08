import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../ ActivationKey/ActivationKeyManager.dart';

class KeyActivationWidget extends StatelessWidget {
  final keyManager = ActivationKeyManager();
  String? userId = FirebaseAuth.instance.currentUser?.email;
  final TextEditingController _keyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Get the screen size
    final Size screenSize = MediaQuery.of(context).size;
    final bool isDesktop = screenSize.width > 600;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive dimensions
        double containerWidth = isDesktop
            ? screenSize.width * 0.3  // 30% of screen width for desktop
            : screenSize.width * 0.9; // 90% of screen width for mobile

        double paddingSize = isDesktop ? 30.0 : 20.0;
        double buttonHeight = isDesktop ? 50.0 : 45.0;
        double fontSize = isDesktop ? 16.0 : 14.0;

        return Center(
          child: Container(
            width: containerWidth,
            constraints: BoxConstraints(
              maxWidth: 600, // Maximum width to prevent too wide containers
              minWidth: 280, // Minimum width to ensure usability
            ),
            padding: EdgeInsets.all(paddingSize),
            margin: EdgeInsets.symmetric(
              horizontal: screenSize.width * 0.05,
              vertical: screenSize.height * 0.02,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _keyController,
                  style: TextStyle(fontSize: fontSize),
                  decoration: InputDecoration(
                    hintText: 'Enter your activation key',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: isDesktop ? 16 : 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
                SizedBox(height: isDesktop ? 25 : 20),
                SizedBox(
                  height: buttonHeight,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (userId != null) {
                        bool success = await keyManager.useKey(_keyController.text.trim(), userId!);
                        print(success);
                        if(success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Activated Successfully',
                                style: TextStyle(fontSize: fontSize),
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Invalid key',
                                style: TextStyle(fontSize: fontSize),
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: isDesktop ? 15 : 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Activate',
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}