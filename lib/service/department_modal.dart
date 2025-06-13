class DepartmentModal {
  late String id;
  late String name, field;

  DepartmentModal({
    required this.name,
    required this.field,
    required this.id,

  });

  factory DepartmentModal.fromJson(Map m1) {
    return DepartmentModal(
      name: m1['departmentName'] ?? "",
      field: m1['field'] ?? "",
      id: m1['id'] ?? "0",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'departmentName': name,
      'field': field,

    };
  }
}
