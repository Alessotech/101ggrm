import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nanoid/async.dart';

/// Represents properties for different types of activation keys
class KeyProperties {
  final int downloadLimit;    // Maximum downloads allowed per day
  final int validityDays;     // How many days the key remains valid
  final int subscriptionMonths; // Duration of subscription in months

  KeyProperties({
    required this.downloadLimit,
    required this.validityDays,
    required this.subscriptionMonths,
  });
}

/// Manages activation keys for subscription-based downloads
class ActivationKeyManager {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  /// Predefined key types with their properties
  final Map<String, KeyProperties> keyTypes = {
    'standard': KeyProperties(
      downloadLimit: 25,        // Standard plan: 25 downloads/day
      validityDays: 30,        // Valid for 30 days
      subscriptionMonths: 1,    // 1 month subscription
    ),
    'premium': KeyProperties(
      downloadLimit: 45,        // Premium plan: 45 downloads/day
      validityDays: 30,        // Valid for 30 days
      subscriptionMonths: 2,    // 2 month subscription
    ),
  };

  /// Generates a single activation key
  /// Parameters:
  /// - type: Type of key ('standard' or 'premium')
  /// - customKey: Optional custom key string
  /// Returns: Generated key string
  Future<String> generateActivationKey({
    required String type,
    String? customKey,
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

      // Create new key document in Firestore
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
      });

      return keyString;
    } catch (e) {
      throw Exception('Failed to generate activation key: $e');
    }
  }

  /// Generates multiple activation keys of the same type
  /// Parameters:
  /// - type: Type of keys to generate
  /// - count: Number of keys to generate
  /// Returns: List of generated key strings
  Future<List<String>> generateMultipleKeys({
    required String type,
    required int count,
  }) async {
    List<String> generatedKeys = [];
    for (int i = 0; i < count; i++) {
      String key = await generateActivationKey(type: type);
      generatedKeys.add(key);
    }
    return generatedKeys;
  }

  /// Generates a custom activation key with user-defined properties
  /// Parameters:
  /// - downloadLimit: Custom download limit for the key
  /// - durationMonths: Custom subscription duration in months
  /// Returns: Generated custom key string
  Future<String> generateCustomKey({
    required int downloadLimit,
    required int durationMonths,
  }) async {
    try {
      // Validate input parameters
      if (downloadLimit <= 0 || durationMonths <= 0) {
        throw Exception('Download limit and duration must be positive integers.');
      }

      // Generate a unique key string
      final keyString = await generateUniqueKey();

      // Calculate the validity in days (assuming 30 days per month for simplicity)
      final validityDays = durationMonths * 30;

      final now = DateTime.now();
      final expiryDate = now.add(Duration(days: validityDays));
      final nextReset = DateTime(now.year, now.month, now.day + 1);

      // Create new key document in Firestore with custom attributes
      await firestore.collection('activationKeys').add({
        'key': keyString,
        'downloadLimit': downloadLimit,
        'downloadsUsed': 0,
        'isActive': true,
        'type': 'custom', // Type is 'custom' since it's user-defined
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(expiryDate),
        'subscriptionMonths': durationMonths,
        'nextDownloadReset': Timestamp.fromDate(nextReset),
        'usedBy': null,
      });

      return keyString;
    } catch (e) {
      throw Exception('Failed to generate custom activation key: $e');
    }
  }


  /// Checks if a key exists in the database
  /// Parameters:
  /// - key: Key string to check
  /// Returns: true if key exists, false otherwise
  Future<bool> checkKeyExists(String key) async {
    final querySnapshot = await firestore
        .collection('activationKeys')
        .where('key', isEqualTo: key)
        .get();
    return querySnapshot.docs.isNotEmpty;
  }

  /// Generates a unique key in format: XXXX-XXXX-XXXX
  /// Returns: Generated unique key string
  Future<String> generateUniqueKey() async {
    String part1 = await customAlphabet('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', 4);
    String part2 = await customAlphabet('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', 4);
    String part3 = await customAlphabet('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', 4);
    return '$part1-$part2-$part3';
  }

  /// Deactivates a specific key
  /// Parameters:
  /// - key: Key string to deactivate
  Future<void> deactivateKey(String key) async {
    final querySnapshot = await firestore
        .collection('activationKeys')
        .where('key', isEqualTo: key)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      await querySnapshot.docs.first.reference.update({
        'isActive': false,
      });
    }
  }

  /// Resets download counts for all active keys
  /// Should be called daily at midnight
  Future<void> resetDailyDownloads() async {
    final now = DateTime.now();
    final querySnapshot = await firestore
        .collection('activationKeys')
        .where('nextDownloadReset', isLessThanOrEqualTo: Timestamp.fromDate(now))
        .where('isActive', isEqualTo: true)
        .get();

    final batch = firestore.batch();
    for (var doc in querySnapshot.docs) {
      final nextReset = DateTime(now.year, now.month, now.day + 1);
      batch.update(doc.reference, {
        'downloadsUsed': 0,
        'nextDownloadReset': Timestamp.fromDate(nextReset),
      });
    }
    await batch.commit();
  }

  /// Retrieves information about a specific key
  /// Parameters:
  /// - key: Key string to get information for
  /// Returns: Map containing key information or null if key doesn't exist
  Future<Map<String, dynamic>?> getKeyInfo(String key) async {
    final querySnapshot = await firestore
        .collection('activationKeys')
        .where('key', isEqualTo: key)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.data();
    }
    return null;
  }
}