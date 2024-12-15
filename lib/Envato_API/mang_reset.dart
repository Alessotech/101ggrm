// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:timezone/timezone.dart' as tz;
// import 'package:timezone/data/latest.dart' as tz;
//
// class DownloadManager {
//   final FirebaseFirestore firestore;
//
//   DownloadManager({required this.firestore});
//
//   Future<void> checkAndResetUserDownloads(String userEmail, String timezone) async {
//     try {
//       // Ensure timezone data is initialized
//       await _initializeTimezone();
//
//       // Get user's active key
//       final querySnapshot = await firestore
//           .collection('activationKeys')
//           .where('usedBy', isEqualTo: userEmail)
//           .where('isActive', isEqualTo: true)
//           .get();
//
//       if (querySnapshot.docs.isEmpty) return;
//
//       // Get current time and convert to user's timezone
//       final now = DateTime.now().toUtc();
//       final userTimezone = tz.getLocation(timezone);
//       final userLocalTime = tz.TZDateTime.from(now, userTimezone);
//
//       for (var doc in querySnapshot.docs) {
//         final data = doc.data() as Map<String, dynamic>;
//         final nextReset = (data['nextDownloadReset'] as Timestamp).toDate();
//
//         // Convert nextReset to user's timezone for comparison
//         final userNextReset = tz.TZDateTime.from(nextReset, userTimezone);
//
//         if (userLocalTime.isAfter(userNextReset)) {
//           // Calculate next reset time (next day at midnight in user's timezone)
//           final userNextMidnight = tz.TZDateTime(
//             userTimezone,
//             userLocalTime.year,
//             userLocalTime.month,
//             userLocalTime.day + 1,
//           );
//
//           // Convert back to UTC for Firestore storage
//           final nextResetUTC = userNextMidnight.toUtc();
//
//           await doc.reference.update({
//             'downloadsUsed': 0,
//             'nextDownloadReset': Timestamp.fromDate(nextResetUTC),
//           });
//
//           print('Reset downloads for user: $userEmail. Next reset at: $userNextMidnight');
//         }
//       }
//     } catch (e) {
//       print('Error in checkAndResetUserDownloads: $e');
//       // Consider the specific error cases
//       if (e.toString().contains('TimeZone')) {
//         throw Exception('Invalid timezone provided: $timezone');
//       } else if (e is FirebaseException) {
//         throw Exception('Firestore error: ${e.message}');
//       } else {
//         throw Exception('Failed to check/reset downloads: $e');
//       }
//     }
//   }
//
//   Future<void> _initializeTimezone() async {
//     try {
//       // Initialize timezone database if not already initialized
//       if (!tz.isInitialized) {
//         tz.initializeTimeZones();
//       }
//     } catch (e) {
//       print('Error initializing timezones: $e');
//       throw Exception('Failed to initialize timezone data');
//     }
//   }
// }
//
// // Example usage:
// void main() async {
//   // Initialize Firebase
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//
//
// }