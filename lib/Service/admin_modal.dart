class AdminModal {
  final int? id;
  final String name;
  final String email;
  final String pass;
  final String check;
  final String companyName;
  final String field;

  AdminModal({
    this.id,
    required this.name,
    required this.email,
    required this.pass,
    required this.check,
    required this.companyName,
    required this.field,
  });

  factory AdminModal.fromJson(Map<String, dynamic> json) {
    return AdminModal(
      id: json['id'],
      name: json['adminName'],
      email: json['email'],
      pass: json['pass'],
      check: json['isChecked'],
      companyName: json['companyName'],
      field: json['field'],
    );
  }
}