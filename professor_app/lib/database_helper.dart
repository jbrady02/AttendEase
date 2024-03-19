import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:postgres/postgres.dart';
import 'package:professor_app/student.dart';

class DatabaseHelper {
  Future<Connection> connectToDatabase() async {
    final conn = await Connection.open(
      Endpoint(
        host: kIsWeb ||
                Platform.isWindows ||
                Platform.isLinux ||
                Platform.isMacOS ||
                Platform.isFuchsia
            ? 'localhost'
            : '10.0.2.2', // Android localhost
        database: 'postgres',
        port: 5432,
        username: 'postgres',
        password: '5a&G4s3?=r?soj)C', // Insert password here
      ),
      // The postgres server hosted locally doesn't have SSL by default. If you're
      // accessing a postgres server over the Internet, the server should support
      // SSL and you should swap out the mode with `SslMode.verifyFull`.
      settings: const ConnectionSettings(sslMode: SslMode.disable),
    );
    return conn;
  }

  // Get the password from a file
  String getPassword() {
    File file = File('${Directory.current.path}\\lib\\password.txt');
    if (file.existsSync()) {
      return file.readAsStringSync();
    } else {
      return 'Password not found';
    }
  }

  // Create Classes table if it does not exist, then return the table
  Future<Result> getClasses() async {
    Connection conn = await connectToDatabase();
    await conn.execute('CREATE TABLE IF NOT EXISTS classes ('
        'class_id SERIAL PRIMARY KEY,'
        'class_name VARCHAR NOT NULL'
        ');');

    final results = await conn.execute('SELECT * FROM classes ORDER BY class_name ASC');
    conn.close();
    return results;
  }

  // Add a class to the Classes table
  void addClass(String className) async {
    Connection conn = await connectToDatabase();
    await conn.execute(
      'INSERT INTO classes (class_name) VALUES (\$1)',
      parameters: [className],
    );
  }

  // Create Students table if it does not exist, then return the table
  Future<List<Student>> getStudents() async {
    Connection conn = await connectToDatabase();
    await conn.execute('CREATE TABLE IF NOT EXISTS students ('
        'student_id SERIAL PRIMARY KEY,'
        'given_name VARCHAR,'
        'Surname VARCHAR,'
        'custom_field_1 VARCHAR,'
        'custom_field_2 VARCHAR,'
        'custom_field_3 VARCHAR,'
        'custom_field_4 VARCHAR'
        ');');

    // Insert student that is used only for the custom field names
    await conn.execute('''INSERT INTO students (student_id, given_name, 
      surname, custom_field_1, custom_field_2, custom_field_3, 
      custom_field_4) VALUES (0, 'Given name', 'Surname', 'Custom field 1', 
      'Custom field 2', 'Custom field 3', 'Custom field 4') 
      ON CONFLICT (student_id) DO NOTHING;''');

    final results =
        await conn.execute('SELECT * FROM students ORDER BY surname ASC');
    conn.close();
    return results
        .map((row) => Student(
            row[0] as int,
            row[1] as String,
            row[2] as String,
            row[3] as String,
            row[4] as String,
            row[5] as String,
            row[6] as String))
        .toList();
  }

  // Add a student to the Students table
  void addStudent(String givenName, String surname, String customField1,
      String customField2, String customField3, String customField4) async {
    Connection conn = await connectToDatabase();
    await conn.execute(
      'INSERT INTO students (given_name, surname, custom_field_1, custom_field_2, custom_field_3, custom_field_4) VALUES (\$1, \$2, \$3, \$4, \$5, \$6)',
      parameters: [
        givenName,
        surname,
        customField1,
        customField2,
        customField3,
        customField4
      ],
    );
  }

  // Remove a student from the Students table
  void removeStudent(int studentId) async {
    Connection conn = await connectToDatabase();
    await conn.execute(
      'DELETE FROM students WHERE student_id = \$1',
      parameters: [studentId],
    );
  }

  // Update a student in the Students table
  void editStudent(String field, String value, int studentId) async {
    Connection conn = await connectToDatabase();
    await conn.execute(
      'UPDATE students SET $field = \$1 WHERE student_id = \$2',
      parameters: [value, studentId],
    );
  }
}
