class EmployeeModal {
  final String? id;
  final String name;
  final String email;
  final String password; // Store password for employee login
  final String role;
  final String departmentId;
  final String adminId;
  final String? phone;
  final String? address;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  EmployeeModal({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    required this.departmentId,
    required this.adminId,
    this.phone,
    this.address,
    this.status = 'active',
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'role': role,
      'departmentId': departmentId,
      'adminId': adminId,
      'phone': phone,
      'address': address,
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory EmployeeModal.fromJson(Map<String, dynamic> json) {
    return EmployeeModal(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      role: json['role'] ?? '',
      departmentId: json['departmentId'] ?? '',
      adminId: json['adminId'] ?? '',
      phone: json['phone'],
      address: json['address'],
      status: json['status'] ?? 'active',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  EmployeeModal copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
    String? role,
    String? departmentId,
    String? adminId,
    String? phone,
    String? address,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EmployeeModal(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
      departmentId: departmentId ?? this.departmentId,
      adminId: adminId ?? this.adminId,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}