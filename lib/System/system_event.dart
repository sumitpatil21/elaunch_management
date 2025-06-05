

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

    const RequestSystem({
      required this.system,
    });

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

    const ApproveRequest({

      required this.system,

    });

    @override
    List<Object> get props => [system];
  }

  class RejectRequest extends SystemEvent {

    final SystemModal system;

    const RejectRequest({

      required this.system,
    });

    @override
    List<Object> get props => [ system];
  }

  class CancelRequest extends SystemEvent {
    final String requestId;
    final String systemId;

    const CancelRequest({
      required this.requestId,
      required this.systemId,
    });

    @override
    List<Object> get props => [requestId, systemId];
  }