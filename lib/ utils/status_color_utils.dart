import 'package:flutter/material.dart';

class StatusColorUtils {
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return Colors.green;
      case 'assigned':
        return Colors.blue;
      case 'maintenance':
        return Colors.orange;
      case 'retired':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
}

  static Color getStatusTextColor(String status) {
    return Colors.white;
  }
}


String selectedStatusFilter = 'all';

final List<String> statusFilters = [
  'all',
  'available',
  'assigned',
  'maintenance',
  'retired',
];


late TabController tabController;
final Color primaryColor = const Color(0xff1a2a4d);
final Color secondaryColor = const Color(0xFF00A884);
final Color backgroundColor = const Color(0xFF111B21);
final Color textColor = Colors.white;
final Color unselectedTextColor = Colors.white70;


final messageBubbleColorMe = const Color(0xFF005C4B);
final messageBubbleColorOther = const Color(0xFF202C33);
final messageInputColor = const Color(0xFF2A3942);
