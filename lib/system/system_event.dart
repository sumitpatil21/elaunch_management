import 'dart:ui';

import 'package:equatable/equatable.dart';

import '../Service/system_modal.dart';

class SystemEvent extends Equatable {
  const SystemEvent();

  @override
  List<Object?> get props => [];
}

class FetchSystem extends SystemEvent {
  const FetchSystem();

  @override
  List<Object> get props => [];
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
  List<Object?> get props => [
    systemName,
    version,
    operatingSystem,
    status,
    employeeName,
    adminId,
    employeeId,
  ];
}

class UpdateSystem extends SystemEvent {
  final SystemModal system;

  const UpdateSystem({required this.system});

  @override
  List<Object> get props => [system];
}

class DeleteSystem extends SystemEvent {
  final String id;
  final String? adminId;
  final String? employeeId;

  const DeleteSystem({required this.id, this.adminId, this.employeeId});

  @override
  List<Object?> get props => [id, adminId, employeeId];
}

class RequestSystem extends SystemEvent {
  final SystemModal system;

  const RequestSystem({required this.system});

  @override
  List<Object> get props => [system];
}

class FetchRequests extends SystemEvent {
  const FetchRequests();

  @override
  List<Object> get props => [];
}

class ApproveRequest extends SystemEvent {
  final SystemModal system;

  const ApproveRequest({required this.system});

  @override
  List<Object> get props => [system];
}

class RejectRequest extends SystemEvent {
  final SystemModal system;

  const RejectRequest({required this.system});

  @override
  List<Object> get props => [system];
}

class CancelRequest extends SystemEvent {
  final String requestId;
  final String systemId;

  const CancelRequest({required this.requestId, required this.systemId});

  @override
  List<Object> get props => [requestId, systemId];
}

class LoadStatusColors extends SystemEvent {
  const LoadStatusColors();
}

class UpdateStatusColor extends SystemEvent {
  final String status;
  final Color color;

  const UpdateStatusColor(this.status, this.color);

  @override
  List<Object> get props => [status, color];
}

class FilterSystems extends SystemEvent {
  final String statusFilter;

  const FilterSystems({required this.statusFilter});

  @override
  List<Object> get props => [statusFilter];
}

class SearchSystems extends SystemEvent {
  final String searchQuery;

  const SearchSystems({required this.searchQuery});

  @override
  List<Object> get props => [searchQuery];
}


class ClearSearch extends SystemEvent {
  const ClearSearch();
  @override
  List<Object> get props => [];

}