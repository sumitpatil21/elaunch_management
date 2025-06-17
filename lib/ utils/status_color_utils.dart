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