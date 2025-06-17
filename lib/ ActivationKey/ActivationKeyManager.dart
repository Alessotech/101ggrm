import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nanoid/async.dart';

/// Represents properties for different types of activation keys
class KeyProperties {
  final int downloadLimit;
  final int validityDays;
  final int subscriptionMonths;
  final bool envatoSubscription;
  final bool freepikSubscription;

  KeyProperties({
    required this.downloadLimit,
    required this.validityDays,
    required this.subscriptionMonths,
    this.envatoSubscription = false,
    this.freepikSubscription = false,
  });
}

/// Manages activation keys for subscription-based downloads
class ActivationKeyManager {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  /// Predefined key types with their properties
  final Map<String, KeyProperties> keyTypes = {
    'standard': KeyProperties(
      downloadLimit: 25,
      validityDays: 30,
      subscriptionMonths: 1,
    ),
    'premium': KeyProperties(
      downloadLimit: 45,
      validityDays: 30,
      subscriptionMonths: 2,
      envatoSubscription: true,
      freepikSubscription: true,
    ),
  };

  /// Generates a single activation key
  Future<String> generateActivationKey({
    required String type,
    String? customKey,
    bool envatoSubscription = false,
    bool freepikSubscription = false,
  }) async {
    try {
      final properties = keyTypes[type];
      if (properties == null) {
        throw Exception('Invalid key type');
      }

      final keyString = customKey ?? await generateUniqueKey();
      final now = DateTime.now();
      final expiryDate = now.add(Duration(days: properties.validityDays));
      final nextReset = DateTime(now.year, now.month, now.day + 1);

      await firestore.collection('activationKeys').add({
        'key': keyString,
        'downloadLimit': properties.downloadLimit,
        'downloadsUsed': 0,
        'isActive': true,
        'type': type,
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(expiryDate),
        'subscriptionMonths': properties.subscriptionMonths,
        'nextDownloadReset': Timestamp.fromDate(nextReset),
        'usedBy': null,
        'envatoSubscription': envatoSubscription || properties.envatoSubscription,
        'freepikSubscription': freepikSubscription || properties.freepikSubscription,
      });

      return keyString;
    } catch (e) {
      throw Exception('Failed to generate activation key: $e');
    }
  }

  /// Generates a unique key
  Future<String> generateUniqueKey() async {
    String part1 = await customAlphabet('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', 4);
    String part2 = await customAlphabet('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', 4);
    String part3 = await customAlphabet('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', 4);
    return '$part1-$part2-$part3';
  }

  /// Uses an activation key
  ///
  ///
  bool isclickeddown() {
    return false; // or implement logic as needed
  }

  Future<bool> useKey(String key, String userId) async {
    try {
      final querySnapshot = await firestore
          .collection('activationKeys')
          .where('key', isEqualTo: key)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return false;
      }

      final keyDoc = querySnapshot.docs.first;
      final keyData = keyDoc.data();
      final now = DateTime.now();

      if (!keyData['isActive'] ||
          keyData['expiresAt'].toDate().isBefore(now) ||
          (keyData['usedBy'] != null && keyData['usedBy'] != userId)) {
        return false;
      }

      if (keyData['downloadsUsed'] >= keyData['downloadLimit']) {
        return false;
      }

      await keyDoc.reference.update({
        'downloadsUsed': FieldValue.increment(1),
        'usedBy': userId,
      });

      return true;
    } catch (e) {
      throw Exception('Failed to use activation key: $e');
    }
  }

  /// Retrieves subscription status
  Future<Map<String, dynamic>> getSubscriptionStatus(String email) async {
    try {
      final activationStatus = await firestore
          .collection('activationKeys')
          .where('usedBy', isEqualTo: email)
          .where('isActive', isEqualTo: true)
          .get();

      if (activationStatus.docs.isEmpty) {
        return {
          'hasActiveSubscription': false,
          'message': 'No active subscription found',
        };
      }

      final keyInfo = activationStatus.docs.first.data();
      final remainingDownloads = keyInfo['downloadLimit'] - keyInfo['downloadsUsed'];
      final bool hasReachedLimit = remainingDownloads <= 0;

      return {
        'hasActiveSubscription': true,
        'remainingDownloads': remainingDownloads,
        'subscriptionType': keyInfo['type'],
        'expiresAt': keyInfo['expiresAt'],
        'downloadLimit': keyInfo['downloadLimit'],
        'downloadsUsed': keyInfo['downloadsUsed'],
        'limitReached': hasReachedLimit,
        'message': hasReachedLimit ? 'Daily download limit reached' : 'Subscription active',
      };
    } catch (e) {
      throw Exception('Failed to get subscription status: $e');
    }
  }

  /// Increments download count
  Future<Map<String, dynamic>> incrementDownload(String email) async {
    try {
      final status = await getSubscriptionStatus(email);

      if (!status['hasActiveSubscription']) {
        return {
          'success': false,
          'message': 'No active subscription found',
          'remainingDownloads': 0
        };
      }

      if (status['limitReached']) {
        return {
          'success': false,
          'message': 'Daily download limit reached',
          'remainingDownloads': 0
        };
      }

      final querySnapshot = await firestore
          .collection('activationKeys')
          .where('usedBy', isEqualTo: email)
          .where('isActive', isEqualTo: true)
          .get();

      final doc = querySnapshot.docs.first;
      await doc.reference.update({'downloadsUsed': FieldValue.increment(1)});

      return {
        'success': true,
        'message': 'Download counted successfully',
        'remainingDownloads': status['downloadLimit'] - (status['downloadsUsed'] + 1),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
        'remainingDownloads': 0
      };
    }
  }
}
