
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


  Future<String> createAdmin(AdminModal admin) async {
    final doc = await admins.add(admin.toJson());
    log("Admin created with ID: ${doc.id}");
    return doc.id;
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

  Future<String> createDepartment(DepartmentModal department) async {
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

    return docRef.id;
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

  Future<String> createEmployee(EmployeeModal employee) async {
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

    return docRef.id;
  }

  Future<EmployeeModal?> getEmployeeByEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
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
    } catch (e) {
      print('Error getting employee by email and password: $e');
      return null;
    }
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

  Future<String> createSystem(SystemModal system) async {
    final docRef = systems.doc();

    await docRef.set({
    ...system.toJson(),
    'id': docRef.id,
    'adminRef': admins.doc(system.adminId.toString()),
    if (system.employeeId != null)
    'employeeRef': employees.doc(system.employeeId.toString()),
    'createdAt': FieldValue.serverTimestamp(),
    });

    return docRef.id;
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

  // Enhanced device creation with auto ID
  Future<String> createDevice(TestingDeviceModal device) async {
    final docRef = devices.doc(); // Generate new document reference
    await docRef.set({
      ...device.toJson(),
      'id': docRef.id, // Store the ID in the document
      'adminRef': admins.doc(device.adminId.toString()),
      'createdAt': FieldValue.serverTimestamp(),
    });

    return docRef.id;
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
      'isRequested': true,
      'requestedBy': system.requestedBy,
      'requestedByName': system.requestedByName,
      'requestedAt': FieldValue.serverTimestamp(),
      'requestStatus': 'pending',
    });
  }

  Future<List<SystemModal>> fetchRequests() async {
    final snapshot = await systems
        .where('isRequested', isEqualTo: true)
        .where('requestStatus', isEqualTo: 'pending')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return SystemModal.fromJson({
        'id': doc.id,
        ...data,
      });
    }).toList();
  }

  Future<void> approveSystemRequest(SystemModal systemId) async {
    await systems.doc(systemId.id).update(systemId.toJson());
  }


  Future<void> rejectSystemRequest(SystemModal systemId) async {
    await systems.doc(systemId.id).update(systemId.toJson());
  }

  Future<void> cancelSystemRequest(String systemId, String requestId) async {
    await systems.doc(systemId).update({
      'isRequested': false,
      'requestStatus': 'cancelled',
      'cancelledAt': FieldValue.serverTimestamp(),
    });
  }
  Future<String> createLeaves(LeaveModal leave) async {
    try {
      final docRef = leaves.doc();
      final leaveData = {
        ...leave.toMap(),
        'id': docRef.id,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await docRef.set(leaveData);
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create leave: $e');
    }
  }

  Future<List<LeaveModal>> getLeaves({String? employeeId, String? status}) async {
    try {
      Query query = leaves.orderBy('createdAt', descending: true);

      if (employeeId != null && employeeId.isNotEmpty) {
        query = query.where('employeeId', isEqualTo: employeeId);
      }

      if (status != null && status.isNotEmpty && status != 'all') {
        query = query.where('status', isEqualTo: status);
      }

      final snapshot = await query.get();

      return snapshot.docs.map((doc) {
        final data = doc.data()! as Map<String, dynamic>;
        return LeaveModal.fromMap({
          ...data,
          'id': doc.id,
        });
      }).toList();
    } catch (e) {
      throw Exception('Failed to get leaves: $e');
    }
  }

  Future<void> updateLeaves(LeaveModal leave) async {
    try {
      final updateData = {
        ...leave.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await leaves.doc(leave.id).update(updateData);
    } catch (e) {
      throw Exception('Failed to update leave: $e');
    }
  }


  Future<void> deleteLeave(String id) async {
    try {
      await leaves.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete leave: $e');
    }
  }

  Future<LeaveModal?> getLeaveById(String id) async {
    try {
      final doc = await leaves.doc(id).get();
      if (doc.exists) {
        final data = doc.data()! as Map<String, dynamic>;
        return LeaveModal.fromMap({
          ...data,
          'id': doc.id,
        });
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get leave by ID: $e');
    }
  }

  Future<List<LeaveModal>> getLeavesByDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? employeeId,
  }) async {
    try {
      Query query = leaves
          .where('startDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('startDate', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('startDate', descending: true);

      if (employeeId != null && employeeId.isNotEmpty) {
        query = query.where('employeeId', isEqualTo: employeeId);
      }

      final snapshot = await query.get();

      return snapshot.docs.map((doc) {
        final data = doc.data()! as Map<String, dynamic>;
        return LeaveModal.fromMap({
          ...data,
          'id': doc.id,
        });
      }).toList();
    } catch (e) {
      throw Exception('Failed to get leaves by date range: $e');
    }
  }

  Future<Map<String, int>> getLeaveStatistics({String? employeeId}) async {
    try {
      Query query = leaves;

      if (employeeId != null && employeeId.isNotEmpty) {
        query = query.where('employeeId', isEqualTo: employeeId);
      }

      final snapshot = await query.get();

      final stats = <String, int>{
        'total': 0,
        'pending': 0,
        'approved': 0,
        'rejected': 0,
        'annual': 0,
        'sick': 0,
        'emergency': 0,
        'excuse': 0,
      };

      for (final doc in snapshot.docs) {
        final data = doc.data()! as Map<String, dynamic>;
        final status = data['status']?.toString().toLowerCase() ?? '';
        final leaveType = data['leaveType']?.toString().toLowerCase() ?? '';

        stats['total'] = stats['total']! + 1;

        // Count by status
        if (stats.containsKey(status)) {
          stats[status] = stats[status]! + 1;
        }

        // Count by leave type
        if (leaveType.contains('annual')) {
          stats['annual'] = stats['annual']! + 1;
        } else if (leaveType.contains('sick')) {
          stats['sick'] = stats['sick']! + 1;
        } else if (leaveType.contains('emergency')) {
          stats['emergency'] = stats['emergency']! + 1;
        } else if (leaveType.contains('excuse')) {
          stats['excuse'] = stats['excuse']! + 1;
        }
      }

      return stats;
    } catch (e) {
      throw Exception('Failed to get leave statistics: $e');
    }
  }
}
