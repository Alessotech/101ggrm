import 'package:flutter/material.dart';

class ServiceStatusWidget extends StatelessWidget {
  final bool isActive; // true for "On", false for "Off"
  final String serviceName;

  const ServiceStatusWidget({
    Key? key,
    required this.isActive,
    required this.serviceName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isActive ? Colors.green : Colors.red,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Status Icon
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(
                isActive ? Icons.check_circle : Icons.cancel,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Service Name and Status Text
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                serviceName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isActive ? "On" : "Off",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}