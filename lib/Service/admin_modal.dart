class AdminModal {
  final String? id;
  final String name;
  final String email;
  final String companyName;
  final String field;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AdminModal({
    this.id,
    required this.name,
    required this.email,
    required this.companyName,
    required this.field,
    this.status = 'active',
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'companyName': companyName,
      'field': field,
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }


  factory AdminModal.fromJson(Map<String, dynamic> json) {
    return AdminModal(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      companyName: json['companyName'] ?? '',
      field: json['field'] ?? '',
      status: json['status'] ?? 'active',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  AdminModal copyWith({
    String? id,
    String? name,
    String? email,
    String? companyName,
    String? field,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AdminModal(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      companyName: companyName ?? this.companyName,
      field: field ?? this.field,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
