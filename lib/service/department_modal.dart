class DepartmentModal {
  late String id;
  late String name, date, id_admin;

  DepartmentModal({
    required this.name,
    required this.date,
    required this.id,
    required this.id_admin,
  });

  factory DepartmentModal.fromJson(Map m1) {
    return DepartmentModal(
      name: m1['departmentName'] ?? "",
      date: m1['date'] ?? "",
      id: m1['id'] ?? "0",
      id_admin: m1['id_admin'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'departmentName': name,
      'date': date,
      'id_admin': id_admin,
    };
  }
}
