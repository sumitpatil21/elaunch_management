class EmployeeModal {
  int? id;
  String name;
  String email;
  String address;
  String dob;
  String role;
  String? managerName;
  String? departmentName;

  EmployeeModal({
    this.id,
    required this.name,
    required this.email,
    required this.address,
    required this.dob,
    required this.role,

    this.managerName,
    this.departmentName,
  });


  factory EmployeeModal.fromJson(Map<String, dynamic> json) {
    return EmployeeModal(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      address: json['address'] ?? '',
      dob: json['dob'] ?? '',
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
      'address': address,
      'dob': dob,
      'role': role,

      'managerName': managerName,
      'departmentName': departmentName,
    };
  }


}