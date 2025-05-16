class DepartmentModal {
  late int id, id_admin;
  late String name, date;

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
      id: m1['id']??0,
      id_admin: m1['id_admin']??0,
    );
  }
}

