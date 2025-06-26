class EmployeeModal {
  final String id;
  final String name;
  final String email;
  final String password;
  final String address;
  final String role;
  final String adminId;
  final String departmentId;
  final String departmentName;
  final String managerName;
  final String managerId;
  final String? fcmToken;
  final DateTime? fcmTokenUpdatedAt;

  EmployeeModal({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.address,
    required this.role,
    required this.adminId,
    required this.departmentId,
    required this.departmentName,
    required this.managerName,
    required this.managerId,
    this.fcmToken,
    this.fcmTokenUpdatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'address': address,
      'role': role,
      'adminId': adminId,
      'departmentId': departmentId,
      'departmentName': departmentName,
      'managerName': managerName,
      'managerId': managerId,
      'fcmToken': fcmToken,
      'fcmTokenUpdatedAt': fcmTokenUpdatedAt?.toIso8601String(),
    };
  }

  factory EmployeeModal.fromJson(Map<String, dynamic> json) {

    return EmployeeModal(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      address: json['address'] ?? '',
      role: json['role'] ?? '',
      adminId: json['adminId'] ?? '',
      departmentId: json['departmentId'] ?? '',
      departmentName: json['departmentName']??"",
      managerName: json['managerName']??"",
      managerId: json['managerId']??"",
      fcmToken: json['fcmToken'],
      fcmTokenUpdatedAt: json['fcmTokenUpdatedAt'] != null
          ? DateTime.parse(json['fcmTokenUpdatedAt'])
          : null,
    );
  }
}