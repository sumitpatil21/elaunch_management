class SystemModal {
  int? id;
  String systemName;
  String? version;
  int? adminId;
  int? managerId;
  int? employeeId;
  // You might want to add fields to hold the actual names if you join tables
  // String? adminName;
  // String? managerName;
  // String? employeeName;


  SystemModal({
    this.id,
    required this.systemName,
    this.version,
    this.adminId,
    this.managerId,
    this.employeeId,
  });

  factory SystemModal.fromJson(Map<String, dynamic> json) {
    return SystemModal(
      id: json['id'],
      systemName: json['systemName'] ?? '',
      version: json['version'],
      adminId: json['id_admin'],
      managerId: json['id_manager'],
      employeeId: json['id_employee'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'systemName': systemName,
      'version': version,
      'id_admin': adminId,
      'id_manager': managerId,
      'id_employee': employeeId,
    };
  }
}