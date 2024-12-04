import 'package:flutter/material.dart';

class ServiceNameWidget extends StatelessWidget {
  final String serviceName;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback onTap;

  const ServiceNameWidget({
    Key? key,
    required this.serviceName,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon Container
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Service Name Text
            Expanded(
              child: Text(
                serviceName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            // Forward Arrow
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}