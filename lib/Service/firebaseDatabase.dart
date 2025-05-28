import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elaunch_management/Service/device_modal.dart';
import 'package:elaunch_management/Service/system_modal.dart';
import 'admin_modal.dart';
import 'department_modal.dart';
import 'employee_modal.dart';

class FirebaseDbHelper {
  FirebaseDbHelper._();
  static final firebase = FirebaseDbHelper._();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get admins => _firestore.collection('admins');
  CollectionReference get departments => _firestore.collection('departments');
  CollectionReference get employees => _firestore.collection('employees');
  CollectionReference get systems => _firestore.collection('systems');
  CollectionReference get devices => _firestore.collection('devices');

  // Admin Operations
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

  // Department Operations
  Future<String> createDepartment(DepartmentModal department) async {
    if (!(await admins.doc(department.id_admin.toString()).get()).exists) {
      throw Exception('Admin does not exist');
    }

    final doc = await departments.add({
      ...department.toJson(),
      'adminRef': admins.doc(department.id_admin.toString()),
    });
    return doc.id;
  }

  Future<List<DepartmentModal>> getDepartments(String adminId) async {
    final snapshot =
        await departments
            .where('adminRef', isEqualTo: admins.doc(adminId))
            .get();

    return snapshot.docs.map((doc) {
      final data = doc.data()! as Map<String, dynamic>;
      return DepartmentModal.fromJson({
        ...data,
        'id': doc.id,
        'id_admin': (data['adminRef'] as DocumentReference).id,
      });
    }).toList();
  }

  Future<void> updateDepartment(DepartmentModal department) async {
    await departments.doc("${department.id}").update({
      ...department.toJson(),
      'adminRef': admins.doc(department.id_admin.toString()),
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

  // Employee Operations
  Future<String> createEmployee(EmployeeModal employee) async {
    if (!(await departments.doc(employee.departmentId).get()).exists) {
      throw Exception('Department does not exist');
    }

    final doc = await employees.add({
      ...employee.toJson(),
      'departmentRef': departments.doc(employee.departmentId),
      'adminRef': admins.doc(employee.adminId),
    });
    return doc.id;
  }

  Future<List<EmployeeModal>> getEmployees({
    String? role,
    String? departmentId,
  }) async {
    Query query = employees;

    if (role != null) query = query.where('role', isEqualTo: role);
    if (departmentId != null) {
      query = query.where(
        'departmentRef',
        isEqualTo: departments.doc(departmentId),
      );
    }

    final snapshot = await query.get();
    log("start: ${snapshot.docs}");
    return snapshot.docs.map((doc) {
      final data = doc.data()! as Map<String, dynamic>;
      log(data.toString());
      return EmployeeModal.fromJson({
        ...data,
        'id': doc.id,
        'departmentId': (data['departmentRef'] as DocumentReference).id,
        'adminId': (data['adminRef'] as DocumentReference).id,
      });
    }).toList();
  }

  Future<void> updateEmployee(EmployeeModal employee) async {
    if (employee.id == null) return;
    await employees.doc("${employee.id}").update({
      ...employee.toJson(),
      'departmentRef': departments.doc(employee.departmentId.toString()),
      'adminRef': admins.doc(employee.adminId.toString()),
    });
  }

  Future<void> deleteEmployee(String id) async {
    await employees.doc(id).delete();
  }

  // System Operations
  Future<void> createSystem(SystemModal system) async {
    await systems.add({
      ...system.toJson(),
      'adminRef': admins.doc(system.adminId.toString()),
      if (system.employeeId != null)
        'employeeRef': employees.doc(system.employeeId.toString()),
    });
  }

  Future<List<SystemModal>> getSystems({
    String? adminId,
    String? employeeId,
  }) async {
    Query query = systems;

    if (adminId != null) {
      query = query.where('adminRef', isEqualTo: admins.doc(adminId));
    }
    if (employeeId != null) {
      query = query.where('employeeRef', isEqualTo: employees.doc(employeeId));
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) {
      final data = doc.data()! as Map<String, dynamic>;
      return SystemModal.fromJson({
        ...data,
        'id': doc.id,
        'adminId': (data['adminRef'] as DocumentReference).id,
        if (data.containsKey('employeeRef'))
          'employeeId': (data['employeeRef'] as DocumentReference).id,
      });
    }).toList();
  }

  Future<void> updateSystem(SystemModal system) async {
    if (system.id == null) return;
    await systems.doc("${system.id}").update({
      ...system.toJson(),
      'adminRef': admins.doc(system.adminId),
      if (system.employeeId != null)
        'employeeRef': employees.doc(system.employeeId),
    });
  }

  Future<void> deleteSystem(String id) async {
    await systems.doc(id).delete();
  }

  Future<void> createDevice(TestingDeviceModal device) async {
    await devices.add({
      ...device.toJson(),
      'adminRef': admins.doc(device.adminId),
    });
  }

  Future<List<TestingDeviceModal>> getDevices(String adminId) async {
    final snapshot =
    await devices.where('adminRef', isEqualTo: admins.doc(adminId)).get();

    return snapshot.docs.map((doc) {
      final data = doc.data()! as Map<String, dynamic>;
      return TestingDeviceModal.fromJson({
        ...data,
        'id': doc.id,
        'adminId': (data['adminRef'] as DocumentReference).id,
      });
    }).toList();
  }

  Future<void> updateDevice(TestingDeviceModal device) async {
    if (device.id == null) return;
    await devices.doc("${device.id}").update({
      ...device.toJson(),
      'adminRef': admins.doc(device.adminId),
    });
  }

  Future<void> deleteDevice(String id) async {
    await devices.doc(id).delete();
  }
}
