import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elaunch_management/Department/department_bloc.dart';

import 'admin_modal.dart';
import 'department_modal.dart';
import 'employee_modal.dart';
import 'manger_modal.dart';

class FirebaseDbHelper {
  FirebaseDbHelper._();

  static final FirebaseDbHelper firebaseDbHelper = FirebaseDbHelper._();

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> insertAdmin(AdminModal admin) async {
    await _firestore
        .collection('/admins')
        .add(admin.toJson())
        .then((value) => log("Data Added done"));
  }

  Future<void> updateAdmin({
    required String email,
    required String check,
  }) async {
    var query =
        await _firestore
            .collection('/admins')
            .where('email', isEqualTo: email)
            .get();
    for (var doc in query.docs) {
      await doc.reference.update({'isChecked': check});
    }
  }

  Future<List<AdminModal>> fetchAdmins() async {
    var snapshot = await _firestore.collection('/admins').get();
    return snapshot.docs.map((doc) => AdminModal.fromJson(doc.data())).toList();
  }

  // Department
  Future<void> insertDepartment(DepartmentModal department) async {

      _firestore.collection('/departments').add(department.toJson());
    log("Added....");
  }

  Future<List<DepartmentModal>> fetchDepartments(int adminId) async {
    var snapshot = await _firestore
        .collection('/departments')
        .where('id_admin', isEqualTo: adminId)
        .get();

    return snapshot.docs
        .map((doc) => DepartmentModal.fromJson(doc.data(),))
        .toList();
  }Future<void> updateDepartment({required DepartmentModal department}) async {
    if (department.id == null) return;
    await _firestore
        .collection('/departments')
        .doc("${department.id}")
        .update(department.toJson());
  }

  Future<void> deleteDepartment(String docId) async {
    await _firestore.collection('/departments').doc(docId).delete();
  }


  // Manager
  // Future<void> insertManager(MangerModal manager) async {
  //   await _firestore.collection('managers').add(manager.toJson());
  // }
  //
  // Future<void> updateManager(String docId, MangerModal manager) async {
  //   await _firestore.collection('managers').doc(docId).update(manager.toJson());
  // }
  //
  // Future<void> deleteManager(String docId) async {
  //   await _firestore.collection('managers').doc(docId).delete();
  // }
  //
  // Future<List<MangerModal>> fetchManagers({String? adminId, String? departmentId}) async {
  //   Query<Map<String, dynamic>> query = _firestore.collection('managers');
  //   if (departmentId != null) {
  //     query = query.where('id_department', isEqualTo: departmentId);
  //   }
  //   var snapshot = await query.get();
  //   return snapshot.docs.map((doc) => MangerModal.fromJson(doc.data())).toList();
  // }
  //
  // // Employee
  // Future<void> insertEmployee(EmployeeModal employee) async {
  //   await _firestore.collection('employees').add(employee.toJson());
  // }
  //
  // Future<void> updateEmployee(String docId, EmployeeModal employee) async {
  //   await _firestore.collection('employees').doc(docId).update(employee.toJson());
  // }
  //
  // Future<void> deleteEmployee(String docId) async {
  //   await _firestore.collection('employees').doc(docId).delete();
  // }
  //
  // Future<List<EmployeeModal>> fetchEmployees({String? adminId, String? managerName, String? departmentName}) async {
  //   Query<Map<String, dynamic>> query = _firestore.collection('employees');
  //   if (managerName != null) {
  //     query = query.where('manager_name', isEqualTo: managerName);
  //   }
  //   if (departmentName != null) {
  //     query = query.where('department_name', isEqualTo: departmentName);
  //   }
  //   var snapshot = await query.get();
  //   return snapshot.docs.map((doc) => EmployeeModal.fromJson(doc.data())).toList();
  // }
  //
  // Future<List<EmployeeModal>> fetchAllEmployees() async {
  //   var snapshot = await _firestore.collection('employees').get();
  //   return snapshot.docs.map((doc) => EmployeeModal.fromJson(doc.data())).toList();
  // }
}
