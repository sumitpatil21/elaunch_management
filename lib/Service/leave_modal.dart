import 'package:cloud_firestore/cloud_firestore.dart';

class LeaveModal {
  final String id;
  final String employeeName;
  final String employeeId;
  final String? leaveType;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;
  final String status;
  final int duration;
  final String? approverName;
  final String? notify;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  LeaveModal({
    required this.id,
    required this.employeeName,
    required this.employeeId,
    this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.status,
    required this.duration,
    this.approverName,
    this.notify,
    this.createdAt,
    this.updatedAt,
  });

  // Convert LeaveModal to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'employeeName': employeeName,
      'employeeId': employeeId,
      'leaveType': leaveType ?? '',
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'reason': reason,
      'status': status,
      'duration': duration,
      'approverName': approverName ?? '',
      'notify': notify ?? '',
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }

  factory LeaveModal.fromMap(Map<String, dynamic> map) {
    return LeaveModal(
      id: map['id'] ?? '',
      employeeName: map['employeeName'] ?? '',
      employeeId: map['employeeId'] ?? '',
      leaveType: map['leaveType'],
      startDate: map['startDate'] is Timestamp
          ? (map['startDate'] as Timestamp).toDate()
          : DateTime.now(),
      endDate: map['endDate'] is Timestamp
          ? (map['endDate'] as Timestamp).toDate()
          : DateTime.now(),
      reason: map['reason'] ?? '',
      status: map['status'] ?? 'pending',
      duration: map['duration'] ?? 0,
      approverName: map['approverName'],
      notify: map['notify'],
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: map['updatedAt'] is Timestamp
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  LeaveModal copyWith({
    String? id,
    String? employeeName,
    String? employeeId,
    String? leaveType,
    DateTime? startDate,
    DateTime? endDate,
    String? reason,
    String? status,
    int? duration,
    String? approverName,
    String? notify,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LeaveModal(
      id: id ?? this.id,
      employeeName: employeeName ?? this.employeeName,
      employeeId: employeeId ?? this.employeeId,
      leaveType: leaveType ?? this.leaveType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      duration: duration ?? this.duration,
      approverName: approverName ?? this.approverName,
      notify: notify ?? this.notify,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

}