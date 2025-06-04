class SystemModal {
  String? id;
  String systemName;
  String? version;
  String? operatingSystem;
  String? status;
  String? employeeName;
  String? adminId;
  String? employeeId;
  bool? isRequested;
  String? requestedBy;
  String? requestedByName;
  DateTime? requestedAt;
  String? requestStatus;
  String? requestId;

  SystemModal({
    this.id,
    required this.systemName,
    this.version,
    this.operatingSystem,
    this.status,
    this.employeeName,
    this.adminId,
    this.employeeId,
    this.isRequested,
    this.requestedBy,
    this.requestedByName,
    this.requestedAt,
    this.requestStatus,
    this.requestId,
  });

  factory SystemModal.fromJson(Map<String, dynamic> json) {
    return SystemModal(
      id: json['id'],
      systemName: json['systemName'] ?? '',
      version: json['version'],
      operatingSystem: json['operatingSystem'],
      status: json['status'],
      employeeName: json['employee_name'],
      adminId: json['id_admin'],
      employeeId: json['id_employee'],
      isRequested: json['is_requested'],
      requestedBy: json['requested_by'],
      requestedByName: json['requested_by_name'],
      requestedAt: json['requested_at'] != null
          ? DateTime.parse(json['requested_at'])
          : null,
      requestStatus: json['request_status'],
      requestId: json['request_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'systemName': systemName,
      'version': version,
      'operatingSystem': operatingSystem,
      'status': status,
      'employee_name': employeeName,
      'id_admin': adminId,
      'id_employee': employeeId,
      'is_requested': isRequested,
      'requested_by': requestedBy,
      'requested_by_name': requestedByName,
      'requested_at': requestedAt?.toIso8601String(),
      'request_status': requestStatus,
      'request_id': requestId,
    };
  }
}
