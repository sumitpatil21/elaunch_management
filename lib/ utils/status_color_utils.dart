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
// Modern Color Scheme
const Color primaryDark = Color(0xFF1F2C34);
const Color primaryLight = Color(0xFF00A884);

const Color backgroundDark = Color(0xFF121B22);

const Color textDark = Colors.green;
const Color bubbleMe = Color(0xFFDCF8C6);
const Color bubbleOther = Color(0xFF1F2C34);
const Color onlineIndicator = Color(0xFF4ADB84);
const Color unreadIndicator = Color(0xFFF55353);
