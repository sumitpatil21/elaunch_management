
import 'package:cloud_firestore/cloud_firestore.dart';

class Leave {
  final String id;
  final String employeeId;
  final String reason;
  final DateTime startDate;
  final DateTime endDate;
  final String status;

  Leave({
    required this.id,
    required this.employeeId,
    required this.reason,
    required this.startDate,
    required this.endDate,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'employeeId': employeeId,
      'reason': reason,
      'startDate': startDate,
      'endDate': endDate,
      'status': status,
    };
  }

  factory Leave.fromMap( Map<String, dynamic> map) {
    return Leave(
      id: map['id'],
      employeeId: map['employeeId'],
      reason: map['reason'],
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: (map['endDate'] as Timestamp).toDate(),
      status: map['status'],
    );
  }
}