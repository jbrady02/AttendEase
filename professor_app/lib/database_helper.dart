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
            : '10.0.2.2', // Android localhost is different.
        database: 'postgres',
        port: 5432,
        username: 'postgres',
        password: getPassword(), // Insert password here.
      ),
      // The postgres server hosted locally doesn't have SSL by default. If you're
      // accessing a postgres server over the Internet, the server should support
      // SSL and you should swap out the mode with `SslMode.verifyFull`.
      settings: const ConnectionSettings(sslMode: SslMode.disable),
    );
    return conn;
  }

  /// Return the password from a file.
  String getPassword() {
    File file = File('${Directory.current.path}\\lib\\password.txt');
    if (file.existsSync()) {
      return file.readAsStringSync();
    } else {
      return 'Password not found';
    }
  }

  /// Create database tables if they don't exist.
  void verifyDatabaseTables() async {
    Connection conn = await connectToDatabase();
    await conn.execute('CREATE TABLE IF NOT EXISTS classes ('
        'class_id SERIAL PRIMARY KEY,'
        'class_name VARCHAR NOT NULL,'
        'students INT[]'
        ');');
    await conn.execute('CREATE TABLE IF NOT EXISTS students ('
        'student_id SERIAL PRIMARY KEY,'
        'given_name VARCHAR,'
        'Surname VARCHAR,'
        'custom_field_1 VARCHAR,'
        'custom_field_2 VARCHAR,'
        'custom_field_3 VARCHAR,'
        'custom_field_4 VARCHAR'
        ');');
    await conn.execute('''CREATE TABLE IF NOT EXISTS class_meetings (
      meeting_id SERIAL PRIMARY KEY,
      class_id INT REFERENCES classes(class_id) ON DELETE CASCADE,
      date VARCHAR
    );''');
    await conn.execute('''CREATE TABLE IF NOT EXISTS student_attendance (
      attendance_id SERIAL PRIMARY KEY,
      student_id INT REFERENCES students(student_id) ON DELETE CASCADE,
      meeting_id INT REFERENCES class_meetings(meeting_id) ON DELETE CASCADE,
      class_id INT REFERENCES classes(class_id) ON DELETE CASCADE,
      attendance INT
    );''');
    await conn.close();
  }

  /// Create Classes table if it does not exist, then return the table.
  Future<Result> getClasses() async {
    Connection conn = await connectToDatabase();
    await conn.execute('CREATE TABLE IF NOT EXISTS classes ('
        'class_id SERIAL PRIMARY KEY,'
        'class_name VARCHAR NOT NULL,'
        'students INT[]'
        ');');

    final Result results = await conn.execute(
        'SELECT class_id, class_name FROM classes ORDER BY class_name ASC');
    await conn.close();
    return results;
  }

  /// Add a class to the classes table named [className].
  void addClass(String className) async {
    Connection conn = await connectToDatabase();
    await conn.execute(
      'INSERT INTO classes (class_name) VALUES (\$1)',
      parameters: [className],
    );
    await conn.close();
  }

  /// Get a class from the classes table.
  ///
  /// [classID] is the requested class_id.
  /// Return the class information with the matching [class_id].
  Future<Result> getClass(int classID) async {
    Connection conn = await connectToDatabase();
    final Result results = await conn.execute(
      'SELECT * FROM classes WHERE class_id = \$1',
      parameters: [classID],
    );
    await conn.close();
    return results;
  }

  /// Get the students in a class from the classes table.
  ///
  /// [classID] is the requested class_id.
  /// Return the class information with the matching [class_id].
  Future<List<int>> getAllStudentIDsInClass(int classID) async {
    Connection conn = await connectToDatabase();
    final Result results = await conn.execute(
      'SELECT students FROM classes WHERE class_id = \$1',
      parameters: [classID],
    );
    await conn.close();
    // Convert results to int.
    List<int> studentIDs = [];
    for (var row in results) {
      if (row[0] != null) {
        List<int> studentIDsFromRow = row[0] as List<int>;
        studentIDs.addAll(studentIDsFromRow);
      }
    }
    return studentIDs;
  }

  /// Create students table if it does not exist, then return the table.
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

    // Insert student that is used only for the custom field names.
    await conn.execute('''INSERT INTO students (student_id, given_name, 
      surname, custom_field_1, custom_field_2, custom_field_3, 
      custom_field_4) VALUES (0, 'Given name', 'Surname', 'Custom field 1', 
      'Custom field 2', 'Custom field 3', 'Custom field 4') 
      ON CONFLICT (student_id) DO NOTHING;''');

    final Result results =
        await conn.execute('SELECT * FROM students ORDER BY surname ASC');
    await conn.close();
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

  /// Add a student to the students table.
  ///
  /// [givenName] is the student's given name.
  /// [surname] is the student's surname.
  /// [customField1] is the student's custom field 1.
  /// [customField2] is the student's custom field 2.
  /// [customField3] is the student's custom field 3.
  /// [customField4] is the student's custom field 4.
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
    await conn.close();
  }

  /// Remove a student from the students table.
  ///
  /// [studentId] is the student_id of the student to remove.
  void removeStudent(int studentId) async {
    Connection conn = await connectToDatabase();
    await conn.execute(
      'DELETE FROM students WHERE student_id = \$1',
      parameters: [studentId],
    );
    await conn.close();
  }

  /// Remove a class from the classes table.
  ///
  /// [classID] is the class_id of the class to remove.
  void removeClass(int classID) async {
    Connection conn = await connectToDatabase();
    await conn.execute(
      'DELETE FROM classes WHERE class_id = \$1',
      parameters: [classID],
    );
    await conn.close();
  }

  /// Update a student in the students table.
  ///
  /// [field] is the field to update.
  /// [value] is the new value for the field.
  /// [studentId] is the student_id of the student to update.
  void editStudent(String field, String value, int studentId) async {
    Connection conn = await connectToDatabase();
    await conn.execute(
      'UPDATE students SET $field = \$1 WHERE student_id = \$2',
      parameters: [value, studentId],
    );
    await conn.close();
  }

  /// Append a [studentID] to the students list in a classID record.
  void addStudentToClass(int classID, int studentID) async {
    Connection conn = await connectToDatabase();
    await conn.execute(
      '''UPDATE classes SET students = array_append(
        students, \$1) WHERE class_id = \$2''',
      parameters: [studentID, classID],
    );

    // Remove duplcate values from classes.
    await conn.execute(
      '''UPDATE classes SET students = (SELECT array_agg(DISTINCT x) 
        FROM unnest(students) x) WHERE class_id = \$1''',
      parameters: [classID],
    );

    // Set all student attendance records to unknown for the new student.
    await conn.execute(
      '''INSERT INTO student_attendance (student_id, meeting_id, class_id, attendance) 
        SELECT \$1, meeting_id, \$2, 0 FROM class_meetings WHERE class_id = \$2''',
      parameters: [studentID, classID],
    );
    await conn.close();
  }

  /// Remove a [studentID] from the students list in a [classID] record.
  void removeStudentFromClass(int classID, int studentID) async {
    Connection conn = await connectToDatabase();
    // Remove student from class.
    await conn.execute(
      '''UPDATE classes SET students = array_remove(
        students, \$1) WHERE class_id = \$2''',
      parameters: [studentID, classID],
    );
    await conn.close();
  }

  /// Update [class_name] for a [classID] record
  void renameClass(int classID, String className) async {
    Connection conn = await connectToDatabase();
    await conn.execute(
      'UPDATE classes SET class_name = \$1 WHERE class_id = \$2',
      parameters: [className, classID],
    );
    await conn.close();
  }

  /// Add a class meeting to the class_meetings table.
  ///
  /// [classID] is the class_id of the class to add the meeting to.
  /// [date] is the date of the meeting.
  Future<Result> addClassMeeting(int classID, String date) async {
    Connection conn = await connectToDatabase();
    await conn.execute(
      'INSERT INTO class_meetings (class_id, date) VALUES (\$1, \$2)',
      parameters: [classID, date],
    );

    // Return the meeting_id of the new meeting.
    final Result results = await conn.execute(
      'SELECT meeting_id FROM class_meetings WHERE class_id = \$1 AND date = \$2',
      parameters: [classID, date],
    );
    await conn.close();
    return results;
  }

  /// Add a student attendance record to the student_attendance table.
  ///
  /// [studentID] is the student_id of the student.
  /// [meetingID] is the meeting_id of the class meeting.
  /// [classID] is the class_id of the class.
  /// [attendance] is the attendance value for the student.
  void addStudentAttendance(
      int studentID, int meetingID, int classID, int attendance) async {
    Connection conn = await connectToDatabase();
    await conn.execute('''CREATE TABLE IF NOT EXISTS student_attendance (
      attendance_id SERIAL PRIMARY KEY,
      student_id INT REFERENCES students(student_id) ON DELETE CASCADE,
      meeting_id INT REFERENCES class_meetings(meeting_id) ON DELETE CASCADE,
      class_id INT REFERENCES classes(class_id) ON DELETE CASCADE,
      attendance INT
    );''');

    await conn.execute(
      '''INSERT INTO student_attendance (student_id, meeting_id, class_id, attendance) 
        VALUES (\$1, \$2, \$3, \$4)''',
      parameters: [studentID, meetingID, classID, attendance],
    );
  }

  /// Get the attendance records for all students in [classID].
  ///
  /// Get the attendance from student_attendance
  /// where meeting_id is in class_meetings for [classID].
  /// Return a list of lists with the student_id, meeting_id, and attendance.
  Future<List<List<int>>> getAttendance(int classID) async {
    Connection conn = await connectToDatabase();
    final Result results = await conn.execute(
      '''SELECT student_id, meeting_id, attendance FROM student_attendance 
        WHERE meeting_id IN (SELECT meeting_id FROM class_meetings 
        WHERE class_id = \$1) ORDER BY meeting_id ASC, student_id ASC''',
      parameters: [classID],
    );
    await conn.close();
    // Map results to a list.
    return results
        .map((row) => [row[0] as int, row[1] as int, row[2] as int])
        .toList();
  }

  /// Get all students in [classID].
  Future<List<Student>> getAllStudentsInClass(int classID) async {
    Connection conn = await connectToDatabase();
    final Result results = await conn.execute(
      '''SELECT students.* FROM students 
      JOIN classes ON students.student_id = ANY(classes.students) 
      WHERE classes.class_id = \$1 ORDER BY students.surname;''',
      parameters: [classID],
    );
    await conn.close();
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

  /// Modify a student attendance record.
  ///
  /// [studentID] is the student_id of the student.
  /// [meetingID] is the meeting_id of the class meeting.
  /// [attendance] is the new attendance value for the student.
  void editStudentAttendance(
      int studentID, int meetingID, int attendance) async {
    Connection conn = await connectToDatabase();
    await conn.execute(
      '''UPDATE student_attendance SET attendance = \$1 
        WHERE student_id = \$2 AND meeting_id = \$3''',
      parameters: [attendance, studentID, meetingID],
    );
    await conn.close();
  }

  /// Get the class meeting date for a [meetingID].
  Future<String> getMeetingDate(int meetingID) async {
    Connection conn = await connectToDatabase();
    final Result results = await conn.execute(
      'SELECT date FROM class_meetings WHERE meeting_id = \$1',
      parameters: [meetingID],
    );
    await conn.close();
    return results[0][0] as String;
  }

  /// Check if the class meeting date is a duplicate.
  /// 
  /// [classID] is the class_id of the class.
  /// [date] is the date of the class meeting.
  /// Return true if the date is a duplicate, false if unique.
  Future<bool> duplicateClassDate(int classID, String date) async {
    Connection conn = await connectToDatabase();
    final Result results = await conn.execute(
      'SELECT date FROM class_meetings WHERE class_id = \$1 AND date = \$2',
      parameters: [classID, date],
    );
    await conn.close();
    return results.isNotEmpty;
  }

  /// Make all unknown attendance data in [classID] absent unexcused.
  void makeUnknownDataAbsentUnexcused(int classID) async {
    Connection conn = await connectToDatabase();
    await conn.execute(
      '''UPDATE student_attendance SET attendance = 2 
        WHERE class_id = \$1 AND attendance = 0''',
      parameters: [classID],
    );
    await conn.close();
  }
}
