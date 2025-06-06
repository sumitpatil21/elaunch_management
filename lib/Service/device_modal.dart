class TestingDeviceModal {
  String? id;
  String deviceName;
  String? operatingSystem;
  String? osVersion;
  String status;
  String? assignedToEmployeeId;
  String? lastCheckOutDate;
  String? lastCheckInDate;
  String? adminId;
  String? assignedEmployeeName;

  TestingDeviceModal({
    this.id,
    required this.deviceName,
    this.operatingSystem,
    this.osVersion,
    this.status = 'available',
    this.assignedToEmployeeId,
    this.lastCheckOutDate,
    this.lastCheckInDate,
    this.adminId,
    this.assignedEmployeeName,
  });

  factory TestingDeviceModal.fromJson(Map<String, dynamic> json) {
    return TestingDeviceModal(
      id: json['id'],
      deviceName: json['deviceName'] ?? '',
      operatingSystem: json['operatingSystem'],
      osVersion: json['osVersion'],
      status: json['status'] ?? 'available',
      assignedToEmployeeId: json['assignedTo_employee_id'],
      lastCheckOutDate: json['lastCheckOutDate'],
      lastCheckInDate: json['lastCheckInDate'],
      adminId: json['id_admin'],
      assignedEmployeeName: json['assigned_employee_name'], // From JOIN
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deviceName': deviceName,
      'operatingSystem': operatingSystem,
      'osVersion': osVersion,
      'status': status,
      'assignedTo_employee_id': assignedToEmployeeId,
      'lastCheckOutDate': lastCheckOutDate,
      'lastCheckInDate': lastCheckInDate,
      'id_admin': adminId,
    };
  }
}
