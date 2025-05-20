class MangerModal {
  final int id, departmentId;
  final String managerName;
  final String email;
  final String address;
  final String dob;
  late final String? departmentName;

  MangerModal({
    required this.id,
    required this.departmentId,
    required this.managerName,
    required this.email,
    required this.address,
    required this.dob,
    this.departmentName,
  });

  factory MangerModal.fromJson(Map<String, dynamic> json) {
    return MangerModal(
      id: json['id'],
      departmentId: json['id_department'] ?? 0,
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
    };
  }
}
