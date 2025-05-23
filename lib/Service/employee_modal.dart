class EmployeeModal {
  int? id; // Auto-increment ID in local DB
  String name;
  String email;
  String address;
  String dob;
  int managerId;
  int departmentId;
  String? managerName;
  String? departmentName;

  EmployeeModal({
    this.id,
    required this.name,
    required this.email,
    required this.address,
    required this.dob,
    required this.managerId,
    required this.departmentId,
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
      managerId: json['managerId'] ?? 0,
      departmentId: json['departmentId'] ?? 0,
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
      'managerId': managerId,
      'departmentId': departmentId,
      'managerName': managerName,
      'departmentName': departmentName,
    };
  }


}