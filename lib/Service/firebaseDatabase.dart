import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elaunch_management/Service/device_modal.dart';
import 'package:elaunch_management/Service/system_modal.dart';
import 'admin_modal.dart';
import 'department_modal.dart';
import 'employee_modal.dart';
import 'leave_modal.dart';

class FirebaseDbHelper {
  FirebaseDbHelper._();
  static final firebase = FirebaseDbHelper._();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  CollectionReference get admins => firestore.collection('admins');
  CollectionReference get departments => firestore.collection('departments');
  CollectionReference get employees => firestore.collection('employees');
  CollectionReference get systems => firestore.collection('systems');
  CollectionReference get devices => firestore.collection('devices');
  CollectionReference get leaves => firestore.collection('leaves');

  Future<void> createAdmin(AdminModal admin) async {
    final doc = await admins.add(admin.toJson());
    log("Admin created with ID: ${doc.id}");

  }

  Future<void> updateAdminStatus(String email, String status) async {
    final query = await admins.where('email', isEqualTo: email).get();
    for (final doc in query.docs) {
      await doc.reference.update({'status': status});
    }
  }

  Future<List<AdminModal>> getAdminByEmail(String email) async {
    final query = await admins.where('email', isEqualTo: email).get();
    return query.docs
        .map(
          (doc) => AdminModal.fromJson({
            ...doc.data() as Map<String, dynamic>,
            'id': doc.id,
          }),
        )
        .toList();
  }

  Future<List<AdminModal>> getAllAdmins() async {
    final snapshot = await admins.get();
    return snapshot.docs
        .map(
          (doc) => AdminModal.fromJson({
            ...doc.data() as Map<String, dynamic>,
            'id': doc.id,
          }),
        )
        .toList();
  }

  Future<void> createDepartment(DepartmentModal department) async {
    if (!(await admins.doc(department.id_admin.toString()).get()).exists) {
      throw Exception('Admin does not exist');
    }

    final docRef = departments.doc();
    await docRef.set({
      ...department.toJson(),
      'id': docRef.id,
      'adminRef': admins.doc(department.id_admin.toString()),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<DepartmentModal>> getDepartments([String? adminId]) async {
    Query query = departments;

    if (adminId != null) {
      query = query.where('adminRef', isEqualTo: admins.doc(adminId));
    }

    final snapshot = await query.get();

    return snapshot.docs.map((doc) {
      final data = doc.data()! as Map<String, dynamic>;
      return DepartmentModal.fromJson({
        ...data,
        'id': doc.id,
        'id_admin': (data['adminRef'] as DocumentReference).id,
      });
    }).toList();
  }

  Future<List<DepartmentModal>> getAllDepartments() async {
    return getDepartments();
  }

  Future<void> updateDepartment(DepartmentModal department) async {
    await departments.doc(department.id).update({
      ...department.toJson(),
      'adminRef': admins.doc(department.id_admin.toString()),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteDepartment(String id) async {
    final hasEmployees =
        (await employees
                .where('departmentRef', isEqualTo: departments.doc(id))
                .get())
            .docs
            .isNotEmpty;

    if (hasEmployees) {
      throw Exception('Department has employees and cannot be deleted');
    }
    await departments.doc(id).delete();
  }

  Future<void> createEmployee(EmployeeModal employee) async {
    if (!(await departments.doc(employee.departmentId).get()).exists) {
      throw Exception('Department does not exist');
    }

    final docRef = employees.doc();
    await docRef.set({
      ...employee.toJson(),
      'id': docRef.id,
      'departmentRef': departments.doc(employee.departmentId),
      'adminRef': admins.doc(employee.adminId),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<EmployeeModal?> getEmployeeByEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final snapshot =
        await firestore
            .collection('employees')
            .where('email', isEqualTo: email)
            .where('password', isEqualTo: password)
            .limit(1)
            .get();

    if (snapshot.docs.isNotEmpty) {
      final doc = snapshot.docs.first;
      final data = doc.data();
      return EmployeeModal.fromJson({
        ...data,
        'id': doc.id,
        'departmentId': (data['departmentRef'] as DocumentReference).id,
        'adminId': (data['adminRef'] as DocumentReference).id,
      });
    }
    return null;
  }

  Future<List<EmployeeModal>> getEmployees({
    String? role,
    String? departmentId,
    String? adminId,
  }) async {
    Query query = employees;

    if (role != null) query = query.where('role', isEqualTo: role);
    if (departmentId != null) {
      query = query.where(
        'departmentRef',
        isEqualTo: departments.doc(departmentId),
      );
    }
    if (adminId != null) {
      query = query.where('adminRef', isEqualTo: admins.doc(adminId));
    }

    final snapshot = await query.get();
    log("Employee docs count: ${snapshot.docs.length}");

    return snapshot.docs.map((doc) {
      final data = doc.data()! as Map<String, dynamic>;
      log("Employee data: $data");
      return EmployeeModal.fromJson({
        ...data,
        'id': doc.id,
        'departmentId': (data['departmentRef'] as DocumentReference).id,
        'adminId': (data['adminRef'] as DocumentReference).id,
      });
    }).toList();
  }

  Future<List<EmployeeModal>> getAllEmployees() async {
    return getEmployees();
  }

  Future<void> updateEmployee(EmployeeModal employee) async {
    if (employee.id == null) return;
    await employees.doc(employee.id).update({
      ...employee.toJson(),
      'departmentRef': departments.doc(employee.departmentId.toString()),
      'adminRef': admins.doc(employee.adminId.toString()),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteEmployee(String id) async {
    await employees.doc(id).delete();
  }

  Future<void> createSystem(SystemModal system) async {
    final docRef = systems.doc();

    await docRef.set({
      ...system.toJson(),
      'id': docRef.id,
      'adminRef': admins.doc(system.adminId.toString()),
      if (system.employeeId != null)
        'employeeRef': employees.doc(system.employeeId.toString()),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<SystemModal>> getSystems([String? adminId]) async {
    Query query = systems;

    if (adminId != null) {
      query = query.where('adminRef', isEqualTo: admins.doc(adminId));
    }

    final snapshot = await query.get();
    log("System docs count: ${snapshot.docs.length}");

    return snapshot.docs.map((doc) {
      final data = doc.data()! as Map<String, dynamic>;
      log("System data: $data");
      return SystemModal.fromJson({
        ...data,
        'id': doc.id,
        'adminId': (data['adminRef'] as DocumentReference).id,
        if (data['employeeRef'] != null)
          'employeeId': (data['employeeRef'] as DocumentReference).id,
      });
    }).toList();
  }

  Future<List<SystemModal>> getAllSystems() async {
    return getSystems();
  }

  Future<void> updateSystem(SystemModal system) async {
    if (system.id == null) return;
    await systems.doc(system.id).update({
      ...system.toJson(),
      'adminRef': admins.doc(system.adminId.toString()),
      if (system.employeeId != null)
        'employeeRef': employees.doc(system.employeeId.toString()),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteSystem(String id) async {
    await systems.doc(id).delete();
  }

  Future<void> createDevice(TestingDeviceModal device) async {
    final docRef = devices.doc();
    await docRef.set({
      ...device.toJson(),
      'id': docRef.id,
      'adminRef': admins.doc(device.adminId.toString()),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<TestingDeviceModal>> getDevices([String? adminId]) async {
    Query query = devices;

    if (adminId != null) {
      query = query.where('adminRef', isEqualTo: admins.doc(adminId));
    }

    final snapshot = await query.get();
    log("Device docs count: ${snapshot.docs.length}");

    return snapshot.docs.map((doc) {
      final data = doc.data()! as Map<String, dynamic>;
      log("Device data: $data");
      return TestingDeviceModal.fromJson({
        ...data,
        'id': doc.id,
        'adminId': (data['adminRef'] as DocumentReference).id,
      });
    }).toList();
  }

  Future<List<TestingDeviceModal>> getAllDevices() async {
    return getDevices();
  }

  Future<void> updateDevice(TestingDeviceModal device) async {
    if (device.id == null) return;
    await devices.doc(device.id).update({
      ...device.toJson(),
      'adminRef': admins.doc(device.adminId.toString()),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteDevice(String id) async {
    await devices.doc(id).delete();
  }

  Future<void> createSystemRequests(SystemModal system) async {
    await systems.doc(system.id).update({
      'isRequested': system.isRequested ?? true,
      'requestId': system.requestId,
      'requestedByName': system.requestedByName,
      'requestedAt':
          system.requestedAt != null ? FieldValue.serverTimestamp() : null,
      'requestStatus': system.requestStatus ?? 'pending',
    });
  }

  Future<List<SystemModal>> fetchRequests() async {
    final snapshot =
        await systems
            .where('isRequested', isEqualTo: true)
            .where('requestStatus', isEqualTo: 'pending')
            .get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return SystemModal.fromJson({...data, 'id': doc.id});
    }).toList();
  }

  Future<void> approveSystemRequest(SystemModal system) async {
    await systems.doc(system.id).update({
      'systemName': system.systemName,
      'version': system.version,
      'operatingSystem': system.operatingSystem,
      'status': system.status,
      'employee_name': system.employeeName,
      'id_employee': system.employeeId,
      'id_admin': system.adminId,
      'isRequested': false,
      'requested_by_name': null,
      'requestId': null,
      'request_status': 'approved',
      'approvedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> rejectSystemRequest(SystemModal system) async {
    await systems.doc(system.id).update({
      'systemName': system.systemName,
      'version': system.version,
      'operatingSystem': system.operatingSystem,
      'status': 'available',
      'employee_name': null,
      'id_employee': null,
      'id_admin': system.adminId,
      'isRequested': false,
      'requested_by_name': null,
      'requestId': null,
      'request_status': 'rejected',
      'rejectedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> cancelSystemRequest(String systemId, String requestId) async {
    await systems.doc(systemId).update({
      'isRequested': false,
      'request_status': 'cancelled',
      'requestId': null,
      'requested_by_name': null,
      'requestedAt': null, // Clear the request timestamp
      'cancelledAt': FieldValue.serverTimestamp(),
    });
  }

  Future<String> createLeaves(LeaveModal leave) async {
    final docRef = leaves.doc();
    final leaveData = {
      ...leave.toMap(),
      'id': docRef.id,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await docRef.set(leaveData);
    print('Leave created successfully with ID: ${docRef.id}');
    return docRef.id;
  }

  Future<List<LeaveModal>> getLeaves({
    String? employeeId,
    String? status,
  }) async {
    Query query = leaves.orderBy('createdAt', descending: true);

    if (employeeId != null && employeeId.isNotEmpty) {
      query = query.where('employeeId', isEqualTo: employeeId);
    }

    if (status != null && status.isNotEmpty && status != 'all') {
      query = query.where('status', isEqualTo: status);
    }

    final snapshot = await query.get();
    print('Retrieved ${snapshot.docs.length} leaves from Firestore');

    return snapshot.docs.map((doc) {
      final data = doc.data()! as Map<String, dynamic>;
      return LeaveModal.fromMap({...data, 'id': doc.id});
    }).toList();
  }

  Future<void> updateLeaves(LeaveModal leave) async {
    if (leave.id.isEmpty) {
      throw Exception('Leave ID is required for update');
    }

    final updateData = {
      ...leave.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await leaves.doc(leave.id).update(updateData);
    print('Leave updated successfully: ${leave.id}');
  }

  Future<void> deleteLeave(String id) async {
    await leaves.doc(id).delete();
    print('Leave deleted successfully: $id');
  }

  Future<LeaveModal?> getLeaveById(String id) async {
    if (id.isEmpty) {
      throw Exception('Leave ID is required');
    }

    final doc = await leaves.doc(id).get();
    if (doc.exists) {
      final data = doc.data()! as Map<String, dynamic>;
      return LeaveModal.fromMap({...data, 'id': doc.id});
    }
    return null;
  }
}
