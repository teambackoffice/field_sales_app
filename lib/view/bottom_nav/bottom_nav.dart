import 'package:flutter/material.dart';

class ModernBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;
  final Color? backgroundColor;

  const ModernBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        5,
        0,
        10,
        2,
      ), // Increased bottom margin to lift it up
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(0, Icons.check_circle, 'Attendance'),
          _buildNavItem(1, Icons.business_center_rounded, 'Sales'),
          _buildNavItem(2, Icons.receipt, 'Invoice'),
          _buildNavItem(3, Icons.person_outline, 'Profile'),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (selectedItemColor ?? const Color(0xFF667EEA)).withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? (selectedItemColor ?? const Color(0xFF667EEA))
                  : (unselectedItemColor ?? Colors.grey[600]),
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: selectedItemColor ?? const Color(0xFF667EEA),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
