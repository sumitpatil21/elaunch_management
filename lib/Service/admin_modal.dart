

class AdminModal {
  final String id;
  final String email;
  final String name;
  final String companyName;
  final String field;
  final String phone;

  AdminModal({
    required this.id,
    required this.email,
    required this.name,
    required this.companyName,
    required this.field,
    this.phone = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'companyName': companyName,
      'field': field,
      'phone': phone,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    };
  }

  // Create from Map (Firestore document)
  factory AdminModal.fromJson(Map<String, dynamic> map) {
    return AdminModal(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      companyName: map['companyName'] ?? '',
      field: map['field'] ?? '',
      phone: map['phone'] ?? '',
    );
  }

  // Copy with method for updates
  AdminModal copyWith({
    String? id,
    String? email,
    String? name,
    String? companyName,
    String? field,
    String? phone,
  }) {
    return AdminModal(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      companyName: companyName ?? this.companyName,
      field: field ?? this.field,
      phone: phone ?? this.phone,
    );
  }

  @override
  String toString() {
    return 'AdminModal(id: $id, email: $email, name: $name, companyName: $companyName, field: $field, phone: $phone)';
  }
}