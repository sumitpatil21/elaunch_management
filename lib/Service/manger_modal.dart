class MangerModal {
  final int id, departmentId, adminId;
  final String managerName;
  final String email;
  final String address;
  final String dob;
   final String? departmentName;

  MangerModal({
    required this.id,
    required this.departmentId,
    required this.adminId,
    required this.managerName,
    required this.email,
    required this.address,
    required this.dob,
    this.departmentName,
  });

  factory MangerModal.fromJson(Map<String, dynamic> json) {
    return MangerModal(
      id: json['id'],
      departmentId: json['departmentId'] ?? 1,
      adminId: json['adminId'] ?? 1,
      managerName: json['managerName'] ?? '',
      email: json['email'] ?? '',
      address: json['address'] ?? '',
      dob: json['dob'] ?? '',
      departmentName: json['departmentName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'managerName': managerName,
      'email': email,
      'address': address,
      'dob': dob,
      'departmentName': departmentName,
      'departmentId': departmentId,
      'adminId': adminId,
    };
  }
}
