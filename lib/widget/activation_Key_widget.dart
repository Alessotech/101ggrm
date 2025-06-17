import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../ ActivationKey/ActivationKeyManager.dart';

final TextEditingController _keyController = TextEditingController();
final keyManager = ActivationKeyManager();
final String? userId = FirebaseAuth.instance.currentUser?.email;

void showKeyActivationWidget(BuildContext context) {
  final Size screenSize = MediaQuery.of(context).size;
  final bool isDesktop = screenSize.width > 600;

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      double containerWidth = isDesktop
          ? screenSize.width * 0.3
          : screenSize.width * 0.9;

      double paddingSize = isDesktop ? 30.0 : 20.0;
      double buttonHeight = isDesktop ? 50.0 : 45.0;
      double fontSize = isDesktop ? 16.0 : 14.0;

      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(20),
        child: Center(
          child: Container(
            width: containerWidth,
            constraints: const BoxConstraints(
              maxWidth: 600,
              minWidth: 280,
            ),
            padding: EdgeInsets.all(paddingSize),
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
                        bool success = await keyManager.useKey(
                          _keyController.text.trim(),
                          userId!,
                        );

                        Navigator.of(context).pop(); // Close popup

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              success ? 'Activated Successfully' : 'Invalid key',
                              style: TextStyle(fontSize: fontSize),
                            ),
                            backgroundColor: success ? Colors.green : Colors.red,
                          ),
                        );
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
        ),
      );
    },
  );
}
