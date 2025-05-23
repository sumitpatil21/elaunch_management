part of 'system_bloc.dart';

abstract class SystemEvent extends Equatable {
  const SystemEvent();

  @override
  List<Object?> get props => [];
}

class FetchSystem extends SystemEvent {
  final int? employeeId;
  final int? adminId;

  const FetchSystem({this.employeeId, this.adminId});

  @override
  List<Object?> get props => [employeeId, adminId];
}

class AddSystem extends SystemEvent {
  final String systemName;
  final String? version;
  final String? operatingSystem;
  final String? status;
  final int? adminId;
  final int? managerId;
  final int? employeeId;
  final String? employeeName;

  const AddSystem({
    required this.systemName,
    this.version,
    this.operatingSystem,
    this.status,
    this.adminId,
    this.managerId,
    this.employeeId,
    this.employeeName,
  });

  @override
  List<Object?> get props => [
    systemName,
    version,
    operatingSystem,
    status,
    adminId,
    managerId,
    employeeId,
    employeeName,
  ];
}

class UpdateSystem extends SystemEvent {
  final int id;
  final String systemName;
  final String? version;
  final String? operatingSystem;
  final String? status;
  final int? adminId;
  final int? managerId;
  final int? employeeId;

  const UpdateSystem({
    required this.id,
    required this.systemName,
    this.version,
    this.operatingSystem,
    this.status,
    this.adminId,
    this.managerId,
    this.employeeId,
  });

  @override
  List<Object?> get props => [
    id,
    systemName,
    version,
    operatingSystem,
    status,
    adminId,
    managerId,
    employeeId,
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
  List<Object?> get props => [id, adminId, employeeId];
}