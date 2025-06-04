
import 'package:cloud_firestore/cloud_firestore.dart';

class LeaveModal {
  final String id;
  final String employeeId;
  final String reason;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final String approverName;
  final int duration;
  final String employeeName;
  final String? leaveType;


  LeaveModal({
    required this.id,
    required this.employeeId,
    required this.reason,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.approverName,
    required this.duration,
    required this.employeeName,
    required this.leaveType,

  });

  Map<String, dynamic> toMap() {
    return {
      'employeeId': employeeId,
      'reason': reason,
      'startDate': startDate,
      'endDate': endDate,
      'status': status,
      'approverName': approverName,
      'duration': duration,
      'employeeName': employeeName,
      'leaveType': leaveType,

    };
  }

  factory LeaveModal.fromMap( Map<String, dynamic> map) {
    return LeaveModal(
      id: map['id'],
      employeeId: map['employeeId'],
      reason: map['reason'],
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: (map['endDate'] as Timestamp).toDate(),
      status: map['status'],
      approverName: map['approverName'],
      duration: map['duration'],
      employeeName: map['employeeName'],
      leaveType: map['leaveType'],

    );
  }
}