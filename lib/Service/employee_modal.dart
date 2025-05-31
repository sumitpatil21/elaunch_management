class EmployeeModal {
  String? id;
  String name;
  String email;
  String address;
  String dob;
  String adminId;
  String departmentId;
  String role;
  String? managerName;
  String? departmentName;
  String password;

  EmployeeModal({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.address,
    required this.dob,
    required this.adminId,
    required this.role,
    required this.departmentId,
    this.managerName,
    this.departmentName,
  });


  factory EmployeeModal.fromJson(Map<String, dynamic> json) {
    return EmployeeModal(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      address: json['address'] ?? '',
      dob: json['dob'] ?? '',
      adminId: json['adminId'] ?? 0,
      departmentId: json['departmentId'] ?? 0,
      role: json['role'] ?? '',

      managerName: json['managerName'],
      departmentName: json['departmentName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'address': address,
      'dob': dob,
      'role': role,
      'adminId': adminId,
      'departmentId': departmentId,
      'managerName': managerName,
      'departmentName': departmentName,
    };
  }


}