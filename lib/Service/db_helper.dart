import 'dart:developer';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'admin_modal.dart';
import 'department_modal.dart';
import 'employee_modal.dart';
import 'manger_modal.dart';

class DbHelper {
  DbHelper._();

  static final DbHelper dbHelper = DbHelper._();

  Database? _database;

  Future<Database> get database async {
    _database ??= await createDatabase();
    return _database!;
  }

  Future<Database> createDatabase() async {
    final path = await getDatabasesPath();
    var dbPath = join(path, "management.db");

    return await openDatabase(
      dbPath,
      version: 1,
      onConfigure: (db) async {
        await db.execute("PRAGMA foreign_keys = ON;");
      },
      onCreate: (db, version) async {
        await db.execute(''' 
    CREATE TABLE admin(
    id INTEGER PRIMARY KEY AUTOINCREMENT, 
    adminName TEXT, 
    email TEXT, 
    pass TEXT, 
    isChecked TEXT, 
    companyName TEXT, 
    field TEXT
  ) ''');

        await db.execute('''
         CREATE TABLE department(
         id INTEGER PRIMARY KEY AUTOINCREMENT,
         departmentName TEXT UNIQUE,
         field TEXT,
         id_admin INTEGER,
         FOREIGN KEY (id_admin) REFERENCES admin (id) ON DELETE CASCADE
         )
          ''');

        await db.execute('''
         CREATE TABLE manager(
         id INTEGER PRIMARY KEY AUTOINCREMENT,
         managerName TEXT,
         email TEXT,
         address TEXT,
         dob TEXT,
         id_department INTEGER,
         FOREIGN KEY (id_department) REFERENCES department (id) ON DELETE CASCADE
         )
          ''');

        await db.execute('''
         CREATE TABLE employee(
         emp_id INTEGER PRIMARY KEY AUTOINCREMENT,
         name TEXT,
         email TEXT,
         address TEXT,
         dob TEXT,
         id_manager INTEGER,
         manager_name TEXT,  
         department_name TEXT, 
         FOREIGN KEY (id_manager) REFERENCES manager (id) ON DELETE CASCADE
         )
          ''');
      },
    );
  }

  Future<void> insertIntoAdmin({
    required String name,
    required String email,
    required String pass,
    required String check,
    required String companyName,
    required String field,
  }) async {
    final db = await database;
    String query = """
    INSERT INTO admin
    (adminName, email, pass, isChecked, companyName, field)
    VALUES (?, ?, ?, ?, ?, ?)
  """;
    List args = [name, email, pass, check, companyName, field];
    await db.rawInsert(query, args);
    log("Admin inserted successfully");
  }

  Future<void> insertIntoDepartment({
    required String departmentName,
    required String dob,
    required int id,
  }) async {
    final db = await database;
    String query = """
      INSERT INTO department
      (departmentName, field, id_admin)
      VALUES(?, ?, ?)
      """;
    List args = [departmentName, dob, id];

    await db.rawInsert(query, args);
    log("Department added successfully");
  }

  Future<void> updateDepartment({
    required int id,
    required String departmentName,
    required String dob,
  }) async {
    final db = await database;
    String query = """
      UPDATE department 
      SET departmentName = ?, field = ?
      WHERE id = ?
      """;
    List args = [departmentName, dob, id];

    await db.rawUpdate(query, args);
    log("Department updated successfully");
  }

  // Updated method with additional parameters
  Future<void> insertIntoEmployee({
    required String name,
    required String email,
    required String address,
    required String dob,
    required int managerId,
    required String manager,
    required String department,
  }) async {
    final db = await database;
    String query = '''
      INSERT INTO employee
      (name, email, address, dob, id_manager, manager_name, department_name)
      VALUES(?, ?, ?, ?, ?, ?, ?)
      ''';

    var args = [name, email, address, dob, managerId, manager, department];

    await db.rawInsert(query, args);

    log("Employee inserted successfully");
  }

  Future<void> insertIntoManager({
    required String name,
    required String email,
    required String address,
    required String dob,
    required int id,
  }) async {
    final db = await database;
    String query = """
    INSERT INTO manager (managerName, email, address, dob, id_department)
    VALUES(?, ?, ?, ?, ?)
  """;
    List args = [name, email, address, dob, id];
    await db.rawInsert(query, args);
    log("Manager added successfully");
  }


  Future<void> updateAdmin({
    required String email,
    required String check,
  }) async {
    final db = await database;
    String query = '''UPDATE admin SET isChecked = ? WHERE email = ?''';
    List args = [check, email];
    await db.rawUpdate(query, args);
    await adminFetch();
  }

  Future<void> updateManager({
    required int id,
    required String name,
    required String email,
    required String address,
    required String dob,
    required int departmentId,
  }) async {
    final db = await database;
    String query = '''
    UPDATE manager
    SET managerName = ?, email = ?, address = ?, dob = ?, id_department = ?
    WHERE id = ?
  ''';
    List args = [name, email, address, dob, departmentId, id];
    await db.rawUpdate(query, args);
  }


  Future<void> updateEmployee({
    required int id,
    required String name,
    required String email,
    required String address,
    required String dob,
    required int managerId,
  }) async {
    final db = await database;

    String query = '''UPDATE employee SET
     name = ?,
     email = ?,
     address = ?,
     dob = ?,
     id_manager = ?
     WHERE emp_id = ?''';

    var args = [name, email, address, dob, managerId, id];

    await db.rawUpdate(query, args);
  }

  Future<List<MangerModal>> fetchAllManager({int? adminId, int? departmentId}) async {
    final db = await database;
    String query = ''' 
    SELECT manager.*, department.departmentName 
    FROM manager 
    INNER JOIN department ON manager.id_department = department.id 
  ''';

    List<dynamic> args = [];

    if (departmentId != null && departmentId > 0) {
      query += ' AND manager.id_department = ?';
      args.add(departmentId);
    } else if (adminId != null && adminId > 0) {
      query += ' AND department.id_admin = ?';
      args.add(adminId);
    }

    List<Map<String, dynamic>> data = await db.rawQuery(query, args);
    return data.map((e) => MangerModal.fromJson(e)).toList();
  }


  Future<List<EmployeeModal>> employeeFetchFilter({int? departmentId, String? managerName}) async {
    final db = await database;
    String query = '''
    SELECT employee.*, manager.managerName, department.departmentName 
    FROM employee 
    INNER JOIN manager ON employee.id_manager = manager.id 
    INNER JOIN department ON manager.id_department = department.id
  ''';
    List<dynamic> args = [];

    if (departmentId != null || managerName != null) {
      query += ' WHERE ';
    }

    if (departmentId != null) {
      query += 'department.id = ?';
      args.add(departmentId);
    }

    if (departmentId != null && managerName != null) {
      query += ' AND ';
    }

    if (managerName != null) {
      query += 'manager.managerName = ?';
      args.add(managerName);
    }

    List<Map<String, dynamic>> data = await db.rawQuery(query, args);
    return data.map((e) => EmployeeModal.fromJson(e)).toList();
  }



  Future<List<DepartmentModal>> departmentFetch(int adminId) async {
    final db = await database;
    String query = '''
    SELECT department.*, admin.adminName
    FROM department
    INNER JOIN admin ON department.id_admin = admin.id
    WHERE department.id_admin = ?
  ''';
    List<Map<String, dynamic>> data = await db.rawQuery(query, [adminId]);
    return data.map((e) => DepartmentModal.fromJson(e)).toList();
  }

  Future<void> deleteEmp(int id) async {
    final db = await database;
    String query = "DELETE FROM employee WHERE emp_id = ?";
    await db.rawDelete(query, [id]);
    log("Employee deleted successfully");
  }

  Future<void> deleteManager(int id) async {
    final db = await database;
    String query = "DELETE FROM manager WHERE id = ?";

    await db.rawDelete(query, [id]);
    log("Manager deleted successfully");
  }

  Future<void> deleteDepartment(int id) async {
    final db = await database;
    String query = "DELETE FROM department WHERE id = ?";

    await db.rawDelete(query, [id]);
    log("Department deleted successfully");
  }

  Future<List<EmployeeModal>> employeeFetch() async {
    final db = await database;
    List<EmployeeModal> userData = [];

    List<Map<String, dynamic>> data = await db.rawQuery(
      "SELECT * FROM employee",
    );
    log("Fetched All Employees: $data");
    userData = data.map((e) => EmployeeModal.fromJson(e)).toList();

    return userData;
  }

  Future<List<AdminModal>> adminFetch() async {
    final db = await database;
    List<AdminModal> userData = [];

    List<Map<String, dynamic>> data = await db.rawQuery("SELECT * FROM admin");
    log("Fetched Admin Data: $data");
    userData = data.map((e) => AdminModal.fromJson(e)).toList();
    return userData;
  }
}