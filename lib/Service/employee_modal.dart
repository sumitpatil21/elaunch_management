// Example of what the EmployeeModal class should look like
// You should update your actual model file with similar structure

class EmployeeModal {
  int? id;
  String name;
  String email;
  String address;
  String dob;
  String? managerName;
  String? departmentName;

  EmployeeModal({
    this.id,
    required this.name,
    required this.email,
    required this.address,
    required this.dob,
    this.managerName,
    this.departmentName,
  });

  factory EmployeeModal.fromJson(Map<String, dynamic> json) {
    return EmployeeModal(
      id: json['emp_id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      address: json['address'] ?? '',
      dob: json['dob'] ?? '',
      managerName: json['managerName'],
      departmentName: json['departmentName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'emp_id': id,
      'name': name,
      'email': email,
      'address': address,
      'dob': dob,
      'managerName': managerName,
      'departmentName': departmentName,
    };
  }
}
