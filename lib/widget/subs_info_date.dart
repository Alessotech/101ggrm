import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../ ActivationKey/ActivationKeyManager.dart';


class SubscriptionStatusWidget extends StatelessWidget {
  final String email;
  final ActivationKeyManager activationKeyManager;

  const SubscriptionStatusWidget({Key? key, required this.email, required this.activationKeyManager}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: activationKeyManager.getSubscriptionStatus(email),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text('Error: ${snapshot.error}'),
              ],
            ),
          );
        }

        final data = snapshot.data!;
        final hasActiveSubscription = data['hasActiveSubscription'];
        final message = data['message'] ?? '';

        DateTime? expiresAt;
        if (data['expiresAt'] != null) {
          if (data['expiresAt'] is Timestamp) {
            expiresAt = data['expiresAt'].toDate();
          } else if (data['expiresAt'] is DateTime) {
            expiresAt = data['expiresAt'];
          }
        }

        if (!hasActiveSubscription || expiresAt == null) {
          return _NoActiveSubscriptionCard(message: message);
        }

        final now = DateTime.now();
        final daysLeft = expiresAt.difference(now).inDays;
        final totalDays = data['subscriptionMonths'] != null
            ? data['subscriptionMonths'] * 30
            : 30;
        final progress = (daysLeft / totalDays).clamp(0.0, 1.0);

        return _ActiveSubscriptionCard(
          expirationDate: expiresAt,
          daysLeft: daysLeft,
          progress: progress,
        );
      },
    );
  }
}

class _ActiveSubscriptionCard extends StatelessWidget {
  final DateTime expirationDate;
  final int daysLeft;
  final double progress;

  const _ActiveSubscriptionCard({
    Key? key,
    required this.expirationDate,
    required this.daysLeft,
    required this.progress,
  }) : super(key: key);

  Color _getStatusColor() {
    if (daysLeft <= 5) return Colors.red;
    if (daysLeft <= 15) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.verified, color: _getStatusColor(), size: 28),
                const SizedBox(width: 8),
                Text(
                  'Active Subscription',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Expires on: ${DateFormat('MMM dd, yyyy').format(expirationDate)}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.timer,
                  size: 20,
                  color: _getStatusColor(),
                ),
                const SizedBox(width: 4),
                Text(
                  'Days left: $daysLeft',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: _getStatusColor(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              padding: const EdgeInsets.all(2),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoActiveSubscriptionCard extends StatelessWidget {
  final String message;

  const _NoActiveSubscriptionCard({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline, color: Colors.red),
                SizedBox(width: 8),
                Text(
                  'Inactive Subscription',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}