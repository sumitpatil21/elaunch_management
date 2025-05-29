class SystemModal {
  String? id;
  String systemName;
  String? version;
  String? operatingSystem;
  String? status;
  String? employeeName;

  String? adminId;

  String? employeeId;

  SystemModal({
    this.id,
    required this.systemName,
    this.version,
    this.operatingSystem,
    this.status,
    this.employeeName,
    this.adminId,

    this.employeeId,
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
    };
  }
}
