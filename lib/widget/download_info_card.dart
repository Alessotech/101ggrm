import 'package:flutter/material.dart';
import 'package:stoc_one_2/widget/status_card.dart';

import '../ ActivationKey/ActivationKeyManager.dart';

class SubscriptionDownloadCard extends StatefulWidget {
  final String email;
  final activationManager ;

  const SubscriptionDownloadCard(
      {
    Key? key,
    required this.email,
        required this.activationManager
  }) : super(key: key);

  @override
  State<SubscriptionDownloadCard> createState() => SubscriptionDownloadCardState();
}

class SubscriptionDownloadCardState extends State<SubscriptionDownloadCard> {
  final ActivationKeyManager _keyManager = ActivationKeyManager();
  Map<String, dynamic>? subscriptionStatus;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSubscriptionStatus();
   print(widget.activationManager.isclickeddown);
    if(widget.activationManager.isclickeddown==true){
      _loadSubscriptionStatus();
      setState(() {
        isLoading=true;
      });
    }


  }

  Future<void> handleDownload() async {
    final result = await _keyManager.incrementDownload(widget.email);
    _loadSubscriptionStatus();
    // if (mounted) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       content: Text(result['message']),
    //       backgroundColor: result['success'] ? Colors.green : Colors.red,
    //     ),
    //   );
    //
    //   if (result['success']== true) {
    //     // Refresh the card to show updated download count
    //     _loadSubscriptionStatus();
    //   }
    // }
  }

  Future<void> _loadSubscriptionStatus() async {
    try {
      final status = await _keyManager.getSubscriptionStatus(widget.email);
      setState(() {
        subscriptionStatus = status;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading subscription: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (subscriptionStatus == null || !subscriptionStatus!['hasActiveSubscription']) {
      return const DownloadCard(
        icon: Icons.error_outline,
        iconBackgroundColor: Colors.grey,
        downloadLimit: 'No active subscription',
        todayDownload: 'Please activate your subscription',
        progress: 0.0,
      );
    }

    // Calculate progress
    final downloadsUsed = subscriptionStatus!['downloadsUsed'] as int;
    final downloadLimit = subscriptionStatus!['downloadLimit'] as int;
    final progress = downloadLimit > 0 ? downloadsUsed / downloadLimit : 0.0;

    return DownloadCard(
      icon: Icons.download,
      iconBackgroundColor: Colors.blue,
      downloadLimit: 'Limit: $downloadLimit downloads',
      todayDownload: 'Used today: $downloadsUsed',
      progress: progress,
    );
  }
  void refreshStatus() {
    setState(() {
      isLoading = true;
    });
    _loadSubscriptionStatus();
  }
}



//
// // Add this method to _SubscriptionDownloadCardState
// void refreshStatus() {
//   setState(() {
//     isLoading = true;
//   });
//   _loadSubscriptionStatus();
// }
//
// // You can call refreshStatus() whenever you need to update the card
// // For example, after a successful download:
// cardKey.currentState?.refreshStatus();