part of 'system_bloc.dart';

sealed class SystemEvent extends Equatable {
  const SystemEvent();
}

class FetchSystem extends SystemEvent {
  final String? adminId;

  const FetchSystem({required this.adminId});

  @override
  List<Object> get props => [adminId ?? "0"];
}

class AddSystem extends SystemEvent {
  final String systemName;
  final String? version;
  final String? operatingSystem;
  final String? status;
  final String? employeeName;
  final String? adminId;
  final String? employeeId;

  const AddSystem({
    required this.systemName,
    this.version,
    this.operatingSystem,
    this.status,
    this.employeeName,
    this.adminId,

    this.employeeId,
  });

  @override
  List<Object> get props => [
    systemName,
    version ?? "",
    operatingSystem ?? "",
    status ?? "",
    employeeName ?? "",
    adminId ?? 0,
    employeeId ?? 0,
  ];
}

class UpdateSystem extends SystemEvent {
  final String id;
  final String systemName;
  final String? version;
  final String? operatingSystem;
  final String? status;
  final String? employeeName;
  final String? adminId;

  final String? employeeId;

  const UpdateSystem({
    required this.id,
    required this.systemName,
    this.version,
    this.operatingSystem,
    this.status,
    this.employeeName,
    this.adminId,

    this.employeeId,
  });

  @override
  List<Object> get props => [
    id,
    systemName,
    version ?? "",
    employeeName ?? "",
    adminId ?? '',
    operatingSystem ?? "",
    status ?? "",
    employeeId ?? 0,
  ];
}

class DeleteSystem extends SystemEvent {
  final String id;
  final String? adminId;

  final String? employeeId;

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
