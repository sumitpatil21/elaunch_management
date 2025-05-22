import 'dart:developer';
import 'package:elaunch_management/Service/system_modal.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'admin_modal.dart';
import 'department_modal.dart';
import 'device_modal.dart';
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
        await db.execute('''
        CREATE TABLE system(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              systemName TEXT UNIQUE,
              version TEXT,
              id_admin INTEGER,
              id_employee INTEGER,
              employee_name TEXT,
              FOREIGN KEY (id_admin) REFERENCES admin (id) ON DELETE CASCADE,
              FOREIGN KEY (id_employee) REFERENCES employee (emp_id) ON DELETE SET NULL
        )
        ''');

        await db.execute('''
        CREATE TABLE testing_device (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            deviceName TEXT NOT NULL,
            operatingSystem TEXT,
            osVersion TEXT,
            status TEXT DEFAULT 'available',
            assignedTo_employee_id INTEGER,
            lastCheckOutDate TEXT,
            lastCheckInDate TEXT,
            id_admin INTEGER,
            FOREIGN KEY (assignedTo_employee_id) REFERENCES employee (emp_id) ON DELETE SET NULL,
            FOREIGN KEY (id_admin) REFERENCES admin (id) ON DELETE SET NULL
        )
        ''');
        log("System table created.");
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

  Future<List<MangerModal>> fetchAllManager(
    int? adminId,
    int? departmentId,
  ) async {
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

  Future<List<EmployeeModal>> employeeFetchFilter({
    required int? adminId,
    String? managerName,
    String? departmentName,
  }) async {
    final db = await database;
    String query = '''
  SELECT employee.*, manager.managerName, department.departmentName 
  FROM employee 
  INNER JOIN manager ON employee.id_manager = manager.id 
  INNER JOIN department ON manager.id_department = department.id
  WHERE department.id_admin = ?
''';
    List<dynamic> args = [adminId];

    if (departmentName != null) {
      query += ' AND department.departmentName = ?';
      args.add(departmentName);
    }

    if (managerName != null) {
      query += ' AND manager.managerName = ?';
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

  Future<void> insertIntoSystem({
    required String systemName,
    required String version,
    int? adminId,
    int? managerId,
    int? employeeId,
    String? employeeName,
  }) async {
    final db = await database;
    String query = """
    INSERT INTO system
    (systemName, version, id_admin, id_employee, employee_name)
    VALUES (?, ?, ?, ?, ?)
  """;
    List args = [
      systemName,
      version,
      adminId,
      employeeId,
      employeeName,
    ];
    await db.rawInsert(query, args);
    log("System inserted successfully: $systemName");
  }

  Future<void> updateSystem({
    required int id,
    required String systemName,
    required String version,
    int? adminId,
    int? managerId,
    int? employeeId,
    String? employeeName,
  }) async {
    final db = await database;
    String query = '''
    UPDATE system SET
    systemName = ?,
    version = ?,
    id_admin = ?,
    id_employee = ?,
    employee_name = ?
    WHERE id = ?
  ''';
    List args = [
      systemName,
      version,
      adminId,
      managerId,
      employeeId,
      employeeName,
      id,
    ];
    int count = await db.rawUpdate(query, args);
    log(
      count > 0
          ? "System with ID $id updated successfully."
          : "Failed to update system with ID $id.",
    );
  }

  Future<List<SystemModal>> fetchSystems({
    int? employeeId,
    int? adminId,
  }) async {
    final db = await database;

    String query = '''
    SELECT system.*, employee.name AS employeeName
    FROM system
    LEFT JOIN employee ON system.id_employee = employee.emp_id
  ''';

    List<dynamic> args = [];
    bool hasWhereClause = false;

    if (employeeId != null) {
      query += ' WHERE system.id_employee = ?';
      args.add(employeeId);
      hasWhereClause = true;
    }

    if (adminId != null) {
      query += hasWhereClause ? ' AND' : ' WHERE';
      query += ' system.id_admin = ?';
      args.add(adminId);
    }

    query += ' ORDER BY system.systemName ASC';

    List<Map<String, dynamic>> data = await db.rawQuery(query, args);

    log("Fetched systems: $data");

    return data.map((e) => SystemModal.fromJson(e)).toList();
  }

  Future<void> deleteSystem(int id) async {
    final db = await database;
    String query = "DELETE FROM system WHERE id = ?";
    int count = await db.rawDelete(query, [id]);
    if (count > 0) {
      log("System with ID $id deleted successfully");
    } else {
      log("Failed to delete system with ID $id or system not found.");
    }
  }

  // --- Testing Device Table CRUD Operations ---

  Future<int> insertIntoTestingDevice({
    required String deviceName,
    String? operatingSystem,
    String? osVersion,
    String status = 'available', // Default value
    int? assignedToEmployeeId,
    String? lastCheckOutDate,
    String? lastCheckInDate,
    int? adminId,
  }) async {
    final db = await database;
    String query = """
    INSERT INTO testing_device
    (deviceName, operatingSystem, osVersion, status, assignedTo_employee_id, lastCheckOutDate, lastCheckInDate, id_admin)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?)
  """;
    List args = [
      deviceName,
      operatingSystem,
      osVersion,
      status,
      assignedToEmployeeId,
      lastCheckOutDate,
      lastCheckInDate,
      adminId,
    ];
    final id = await db.rawInsert(query, args);
    log("Testing Device inserted successfully: $deviceName with ID: $id");
    return id;
  }

  Future<List<TestingDeviceModal>> fetchAllTestingDevices({
    int? adminId,
    String? statusFilter,
  }) async {
    final db = await database;
    String query =
        "SELECT td.*, e.name as assigned_employee_name FROM testing_device td LEFT JOIN employee e ON td.assignedTo_employee_id = e.emp_id";
    List<dynamic> args = [];
    bool hasWhereClause = false;

    if (adminId != null) {
      query += " WHERE td.id_admin = ?";
      args.add(adminId);
      hasWhereClause = true;
    }

    if (statusFilter != null && statusFilter.isNotEmpty) {
      if (hasWhereClause) {
        query += " AND td.status = ?";
      } else {
        query += " WHERE td.status = ?";
      }
      args.add(statusFilter);
    }

    query +=
        " ORDER BY td.deviceName ASC"; // Added ASC for ascending order, you can change to DESC if needed

    List<Map<String, dynamic>> data = await db.rawQuery(query, args);
    log("Fetched Testing Devices: $data");
    return data.map((e) => TestingDeviceModal.fromJson(e)).toList();
  }
}
