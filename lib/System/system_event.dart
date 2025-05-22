part of 'system_bloc.dart';

sealed class SystemEvent extends Equatable {
  const SystemEvent();
}

class FetchSystem extends SystemEvent {
  final int? adminId;
  final int? employeeId; // Added for consistency if needed for filtering

  const FetchSystem({required this.adminId, this.employeeId});

  @override
  List<Object> get props => [adminId ?? 0, employeeId ?? ""];
}

class AddSystem extends SystemEvent {
  final String systemName;
  final String? version;
  final String? employeeName;
  final int? adminId;
  final int? managerId;
  final int? employeeId;

  const AddSystem({
    required this.systemName,
    this.version,
    this.employeeName,
    this.adminId,
    this.managerId,
    this.employeeId,
  });

  @override
  List<Object> get props => [
    systemName,
    version ?? "",
    employeeName ?? "",
    adminId ?? 0,
    managerId ?? 0,
    employeeId ?? 0,
  ];
}

class UpdateSystem extends SystemEvent {
  final int id;
  final String systemName;
  final String? version;
  final String? employeeName;
  final int? adminId;
  final int? managerId;
  final int? employeeId;

  const UpdateSystem({
    required this.id,
    required this.systemName,
    this.version,
    this.employeeName,
    this.adminId,
    this.managerId,
    this.employeeId,
  });

  @override
  List<Object> get props => [
    id,
    systemName,
    version ?? "",
    employeeName ?? "",
    adminId ?? 0,
    managerId ?? 0,
    employeeId ?? 0,
  ];
}

class DeleteSystem extends SystemEvent {
  final int id;
  final int? adminId;

  final int? employeeId;

  const DeleteSystem({
    required this.id,
    this.adminId,

    this.employeeId,
  });

  @override
  List<Object> get props => [
    id,
    adminId ?? 0,

    employeeId ?? "",
  ];
}
