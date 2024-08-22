import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:attend_ease/attendance.dart';
import 'package:attend_ease/database_helper.dart';
import 'package:attend_ease/student.dart';

class ClassInformation extends StatelessWidget {
  final int classID;
  final String classInfo;

  const ClassInformation(this.classID, this.classInfo, {super.key});

  // Theme
  static const TextStyle bodyText = TextStyle(
    fontSize: 20,
    color: Colors.black,
  );
  static const TextStyle smallBodyText = TextStyle(
    fontSize: 16,
    color: Colors.black,
  );

  static const Color primaryColor = Color.fromARGB(255, 255, 100, 100);

  static const int unknown = 0;
  static const int present = 1;
  static const int absentExcused = 2;
  static const int absentUnexcused = 3;
  static const int tardyExcused = 4;
  static const int tardyUnexcused = 5;

  /// Convert the database integer values to strings.
  ///
  /// [attendanceInt] is the integer value from the database.
  /// Return a string abbreviation of the attendance value.
  String _getAttendance(int attendanceInt) {
    switch (attendanceInt) {
      case present:
        return 'P';
      case absentExcused:
        return 'AE';
      case absentUnexcused:
        return 'AU';
      case tardyExcused:
        return 'TE';
      case tardyUnexcused:
        return 'TU';
      default:
        return '?';
    }
  }

  String _getPercentAttended(List<int> attendance) {
    int presentCount = 0;
    for (int index in attendance) {
      if (index == present) {
        presentCount++;
      }
    }
    if (attendance.isEmpty) {
      return 'N/A';
    } else {
      return '${(presentCount / attendance.length * 100).round()}%';
    }
  }

  /// Get a Color object determined by [attendanceInt].
  ///
  /// [attendanceInt] is the integer value from the database.
  /// Return a Color object determined by attendanceInt.
  Color _getColor(int attendanceInt) {
    switch (attendanceInt) {
      case present:
        return const Color.fromARGB(255, 0, 153, 255); // Blue
      case absentExcused || absentUnexcused:
        return const Color.fromARGB(255, 255, 0, 0); // Red
      case tardyExcused || tardyUnexcused:
        return const Color.fromARGB(255, 127, 255, 0); // Yellow-green
      default:
        return Colors.white;
    }
  }

  /// Get a Color object determined by [attendanceInt].
  ///
  /// [attendanceInt] is the integer value from the database.
  /// Return a Color object determined by attendanceInt.
  Color _getOutlineColor(int attendanceInt) {
    switch (attendanceInt) {
      case absentUnexcused || tardyUnexcused:
        return const Color.fromARGB(255, 127, 0, 0); // Dark red
      case unknown:
        return Colors.black;
      default:
        return Colors.transparent;
    }
  }

  /// Show a dialog to select an attendance value.
  ///
  /// [nameIndex] is the index of the student name in the students map.
  /// [dateIndex] is the index of the class meeting date.
  void _showSelectionDialog(
    BuildContext context,
    int nameIndex,
    int dateIndex,
    Map<Student, List<Attendance>> students,
    List<String> classDates,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text('Edit attendance data for '
              '${students.keys.toList()[nameIndex].givenName} '
              '${students.keys.toList()[nameIndex].surname} '
              'on ${classDates[dateIndex]}'),
          children: [
            Container(
              // Button to record student as present.
              color: const Color.fromARGB(255, 0, 153, 255), // Blue
              child: SimpleDialogOption(
                onPressed: () {
                  DatabaseHelper dbHelper = DatabaseHelper();
                  dbHelper.editStudentAttendance(
                      students.values.toList()[nameIndex][dateIndex].studentID,
                      students.values.toList()[nameIndex][dateIndex].meetingID,
                      present);
                  Navigator.pop(context, present);
                },
                child:
                    students.values.toList()[nameIndex][dateIndex].attendance ==
                            present
                        ? const Text('Present (current value)', style: bodyText)
                        : const Text('Present', style: bodyText),
              ),
            ),
            Container(
              // Button to record student as absent and excused.
              color: const Color.fromARGB(255, 255, 0, 0), // Red
              child: SimpleDialogOption(
                onPressed: () {
                  DatabaseHelper dbHelper = DatabaseHelper();
                  dbHelper.editStudentAttendance(
                      students.values.toList()[nameIndex][dateIndex].studentID,
                      students.values.toList()[nameIndex][dateIndex].meetingID,
                      absentExcused);
                  Navigator.pop(context, absentExcused);
                },
                child:
                    students.values.toList()[nameIndex][dateIndex].attendance ==
                            absentExcused
                        ? const Text('Absent and excused (current value)',
                            style: bodyText)
                        : const Text('Absent and excused', style: bodyText),
              ),
            ),
            Container(
              // Button to record student as absent and unexcused.
              color: const Color.fromARGB(255, 255, 0, 0), // Red
              child: SimpleDialogOption(
                onPressed: () {
                  DatabaseHelper dbHelper = DatabaseHelper();
                  dbHelper.editStudentAttendance(
                      students.values.toList()[nameIndex][dateIndex].studentID,
                      students.values.toList()[nameIndex][dateIndex].meetingID,
                      absentUnexcused);
                  Navigator.pop(context, absentUnexcused);
                },
                child:
                    students.values.toList()[nameIndex][dateIndex].attendance ==
                            absentUnexcused
                        ? const Text('Absent and unexcused (current value)',
                            style: bodyText)
                        : const Text('Absent and unexcused', style: bodyText),
              ),
            ),
            Container(
              // Button to record student as tardy and excused.
              color: const Color.fromARGB(255, 127, 255, 0), // Yellow-green
              child: SimpleDialogOption(
                onPressed: () {
                  DatabaseHelper dbHelper = DatabaseHelper();
                  dbHelper.editStudentAttendance(
                      students.values.toList()[nameIndex][dateIndex].studentID,
                      students.values.toList()[nameIndex][dateIndex].meetingID,
                      tardyExcused);
                  Navigator.pop(context, tardyExcused);
                },
                child:
                    students.values.toList()[nameIndex][dateIndex].attendance ==
                            tardyExcused
                        ? const Text('Tardy and excused (current value)',
                            style: bodyText)
                        : const Text('Tardy and excused', style: bodyText),
              ),
            ),
            Container(
              // Button to record student as tardy and unexcused.
              color: const Color.fromARGB(255, 127, 255, 0), // Yellow-green
              child: SimpleDialogOption(
                onPressed: () {
                  DatabaseHelper dbHelper = DatabaseHelper();
                  dbHelper.editStudentAttendance(
                      students.values.toList()[nameIndex][dateIndex].studentID,
                      students.values.toList()[nameIndex][dateIndex].meetingID,
                      tardyUnexcused);
                  Navigator.pop(context, tardyUnexcused);
                },
                child:
                    students.values.toList()[nameIndex][dateIndex].attendance ==
                            tardyUnexcused
                        ? const Text('Tardy and unexcused (current value)',
                            style: bodyText)
                        : const Text('Tardy and unexcused', style: bodyText),
              ),
            ),
            SimpleDialogOption(
              // Button to make student attendance unknown.
              onPressed: () {
                DatabaseHelper dbHelper = DatabaseHelper();
                dbHelper.editStudentAttendance(
                    students.values.toList()[nameIndex][dateIndex].studentID,
                    students.values.toList()[nameIndex][dateIndex].meetingID,
                    unknown);
                Navigator.pop(context, unknown);
              },
              child:
                  students.values.toList()[nameIndex][dateIndex].attendance ==
                          unknown
                      ? const Text('Unknown (current value)', style: bodyText)
                      : const Text('Unknown', style: bodyText),
            ),
          ],
        );
      },
    ).then((selectedValue) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => ClassInformation(classID, classInfo)),
      );
    });
  }

  /// Get the students and their attendance values from the database.
  ///
  /// Return a map of a map of students and their attendance values
  /// and the dates of the meetings.
  Future<Map<Map<Student, List<Attendance>>, List<String>>>
      _getStudentsAndAttendance() async {
    DatabaseHelper dbHelper = DatabaseHelper();
    List<Student> studentsList = await dbHelper.getAllStudentsInClass(classID);
    List<List<int>> attendanceData = await dbHelper.getAttendance(classID);
    List<String> classDates = [];
    // Make list of meetingIDs and if they match skip.
    List<int> meetingIDs = [];
    for (var row in attendanceData) {
      if (!meetingIDs.contains(row[1])) {
        meetingIDs.add(row[1]);
        classDates.add(await dbHelper.getMeetingDate(row[1]));
      }
    }
    Map<Student, List<Attendance>> students = {};
    // Add attendance value for each student for each meeting.
    // Make attendanceMap keys the students and the values an empty list.
    for (var student in studentsList) {
      students[student] = [];
    }
    // Add Attendance objects to students.
    for (int meetingIndex = 0;
        meetingIndex < meetingIDs.length;
        meetingIndex++) {
      for (List<int> row in attendanceData) {
        if (row[1] == meetingIDs[meetingIndex]) {
          for (int index = 0; index < studentsList.length; index++) {
            if (studentsList[index].studentID == row[0]) {
              students[studentsList[index]]!
                  .add(Attendance(row[0], row[1], row[2]));
            }
          }
        }
      }
    }
    // Make a map of a map of students and their attendance values
    // and the dates of the meetings.
    Map<Map<Student, List<Attendance>>, List<String>> studentAttendance = {};
    studentAttendance[students] = classDates;
    return studentAttendance;
  }

  /// Reload the page so that the changes are displayed.
  ///
  /// [numPops] is the number of pages to pop off the stack.
  Future<void> reload(BuildContext context, numPops) async {
    // Reload the page with the updated database
    // Wait 250 ms then reload the page
    showDialog(
        context: context,
        builder: (context) {
          return const Center(child: CircularProgressIndicator());
        });
    await Future.delayed(const Duration(milliseconds: 250), () {
      for (var i = 0; i < numPops; i++) {
        Navigator.pop(context);
      }
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ClassInformation(classID, classInfo)));
    });
  }

  /// Build the class information page.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<Map<Student, List<Attendance>>, List<String>>>(
        future: _getStudentsAndAttendance(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // While waiting, display a loading indicator.
            return Scaffold(
              appBar: AppBar(
                backgroundColor: primaryColor,
                title: const Text('All students'),
              ),
              body: const Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError) {
            // If an error occurs, display an error message.
            return Scaffold(
              appBar: AppBar(
                backgroundColor: primaryColor,
                title: const Text('All students'),
              ),
              body: const Center(
                  child: Text(
                'Could not connect to the database. Please refresh the page.',
                style: bodyText,
                textAlign: TextAlign.center,
              )),
              bottomNavigationBar: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FloatingActionButton(
                    heroTag: 'refreshStudent',
                    onPressed: () {
                      reload(context, 2);
                    },
                    backgroundColor: primaryColor,
                    tooltip: 'Refresh page',
                    child: const Icon(Icons.refresh),
                  ),
                ],
              ),
            );
          } else if (snapshot.data!.keys.first.isEmpty) {
            return Scaffold(
              appBar: AppBar(
                backgroundColor: primaryColor,
                title: const Text('All students'),
              ),
              body: const Center(
                  child: Text(
                'There are no students in this class. Please add students.',
                style: bodyText,
                textAlign: TextAlign.center,
              )),
              bottomNavigationBar: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FloatingActionButton(
                    heroTag: 'refreshStudent',
                    onPressed: () {
                      reload(context, 2);
                    },
                    backgroundColor: primaryColor,
                    tooltip: 'Refresh page',
                    child: const Icon(Icons.refresh),
                  ),
                ],
              ),
            );
          } else {
            // Future object found; display students.
            Map<Student, List<Attendance>>? students =
                snapshot.data!.keys.first;
            List<String>? classDates = snapshot.data!.values.first;
            return Scaffold(
              appBar: AppBar(
                backgroundColor: primaryColor,
                title: Text('Edit attendance data for $classInfo'),
              ),
              body: TwoDimensionalGridView(
                diagonalDragBehavior: DiagonalDragBehavior.free,
                delegate: TwoDimensionalChildBuilderDelegate(
                    maxXIndex: students.values.first.length + 1,
                    maxYIndex: students.length,
                    builder: (BuildContext context, ChildVicinity vicinity) {
                      return SizedBox(
                          height: 75,
                          width: 75,
                          child: Center(
                            child: (vicinity.xIndex == 0 &&
                                    vicinity.yIndex == 0)
                                ? null // Empty top-left corner.
                                : (vicinity.xIndex == 0)
                                    ? Center(
                                        child: Text(
                                            // Name
                                            '${students.keys.toList()[vicinity.yIndex - 1].givenName} ${students.keys.toList()[vicinity.yIndex - 1].surname.replaceAll('-', '-\n')}',
                                            style:
                                                // Separate name by spaces and if a
                                                // token has than 8 characters,
                                                // decrease the font size.
                                                '${students.keys.toList()[vicinity.yIndex - 1].givenName} ${students.keys.toList()[vicinity.yIndex - 1].surname}'
                                                        .split(' ')
                                                        .any((element) =>
                                                            element.length > 8)
                                                    ? smallBodyText.copyWith(
                                                        fontSize: 12)
                                                    : smallBodyText,
                                            textAlign: TextAlign.center),
                                      )
                                    : (vicinity.yIndex == 0)
                                        ? (vicinity.xIndex ==
                                                students.values.first.length +
                                                    1) // Percent attended
                                            ? const Center(
                                                child: Padding(
                                                padding: EdgeInsets.only(
                                                    left: 13, right: 13),
                                                child: Text('%',
                                                    style: bodyText,
                                                    textAlign:
                                                        TextAlign.center),
                                              ))
                                            : Center(
                                                child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 13, right: 13),
                                                child: Text(
                                                    // Date
                                                    classDates[
                                                        vicinity.xIndex - 1],
                                                    style: smallBodyText,
                                                    textAlign:
                                                        TextAlign.center),
                                              ))
                                        : (vicinity.xIndex ==
                                                students.values.first.length +
                                                    1) // Percent attended
                                            ? (Center(
                                                child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 13, right: 13),
                                                child: Text(
                                                    _getPercentAttended(
                                                        // Get attendance.
                                                        students.values
                                                            .toList()[vicinity
                                                                    .yIndex -
                                                                1]
                                                            .map((e) =>
                                                                e.attendance)
                                                            .toList()),
                                                    style: smallBodyText,
                                                    textAlign:
                                                        TextAlign.center),
                                              )))
                                            : SizedBox(
                                                width: 70,
                                                child: OutlinedButton(
                                                  // Attendance
                                                  onPressed: () {
                                                    _showSelectionDialog(
                                                        context,
                                                        vicinity.yIndex - 1,
                                                        vicinity.xIndex - 1,
                                                        students,
                                                        classDates);
                                                  },
                                                  style:
                                                      OutlinedButton.styleFrom(
                                                          side: BorderSide(
                                                              color: _getOutlineColor(students
                                                                  .values
                                                                  .toList()[vicinity.yIndex - 1]
                                                                      [
                                                                      vicinity.xIndex -
                                                                          1]
                                                                  .attendance),
                                                              width:
                                                                  3), // Set the border color.
                                                          backgroundColor:
                                                              _getColor(students
                                                                  .values
                                                                  .toList()[
                                                                      vicinity.yIndex - 1]
                                                                      [vicinity.xIndex - 1]
                                                                  .attendance)),
                                                  // Set the background color.
                                                  child: Text(
                                                      _getAttendance(
                                                          // Get attendance value.
                                                          students.values
                                                              .toList()[vicinity
                                                                      .yIndex -
                                                                  1][vicinity
                                                                      .xIndex -
                                                                  1]
                                                              .attendance),
                                                      style: smallBodyText),
                                                ),
                                              ),
                          ));
                    }),
              ),
              bottomNavigationBar: FloatingActionButton(
                heroTag: 'makeUnknownDataAbsentUnexcused',
                onPressed: () {
                  DatabaseHelper dbHelper = DatabaseHelper();
                  dbHelper.makeUnknownDataAbsentUnexcused(classID);
                  reload(context, 2);
                },
                backgroundColor: primaryColor,
                child: const Text('Make all unknown data absent unexcused',
                    style: bodyText),
              ),
            );
          }
        });
  }
}

class TwoDimensionalGridView extends TwoDimensionalScrollView {
  const TwoDimensionalGridView({
    super.key,
    super.primary,
    super.mainAxis = Axis.vertical,
    super.verticalDetails = const ScrollableDetails.vertical(),
    super.horizontalDetails = const ScrollableDetails.horizontal(),
    required TwoDimensionalChildBuilderDelegate delegate,
    super.cacheExtent,
    super.diagonalDragBehavior = DiagonalDragBehavior.none,
    super.dragStartBehavior = DragStartBehavior.start,
    super.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    super.clipBehavior = Clip.hardEdge,
  }) : super(delegate: delegate);

  @override
  Widget buildViewport(
    BuildContext context,
    ViewportOffset verticalOffset,
    ViewportOffset horizontalOffset,
  ) {
    return TwoDimensionalGridViewport(
      horizontalOffset: horizontalOffset,
      horizontalAxisDirection: horizontalDetails.direction,
      verticalOffset: verticalOffset,
      verticalAxisDirection: verticalDetails.direction,
      mainAxis: mainAxis,
      delegate: delegate as TwoDimensionalChildBuilderDelegate,
      cacheExtent: cacheExtent,
      clipBehavior: clipBehavior,
    );
  }
}

class TwoDimensionalGridViewport extends TwoDimensionalViewport {
  const TwoDimensionalGridViewport({
    super.key,
    required super.verticalOffset,
    required super.verticalAxisDirection,
    required super.horizontalOffset,
    required super.horizontalAxisDirection,
    required TwoDimensionalChildBuilderDelegate super.delegate,
    required super.mainAxis,
    super.cacheExtent,
    super.clipBehavior = Clip.hardEdge,
  });

  @override
  RenderTwoDimensionalViewport createRenderObject(BuildContext context) {
    return RenderTwoDimensionalGridViewport(
      horizontalOffset: horizontalOffset,
      horizontalAxisDirection: horizontalAxisDirection,
      verticalOffset: verticalOffset,
      verticalAxisDirection: verticalAxisDirection,
      mainAxis: mainAxis,
      delegate: delegate as TwoDimensionalChildBuilderDelegate,
      childManager: context as TwoDimensionalChildManager,
      cacheExtent: cacheExtent,
      clipBehavior: clipBehavior,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderTwoDimensionalGridViewport renderObject,
  ) {
    renderObject
      ..horizontalOffset = horizontalOffset
      ..horizontalAxisDirection = horizontalAxisDirection
      ..verticalOffset = verticalOffset
      ..verticalAxisDirection = verticalAxisDirection
      ..mainAxis = mainAxis
      ..delegate = delegate
      ..cacheExtent = cacheExtent
      ..clipBehavior = clipBehavior;
  }
}

class RenderTwoDimensionalGridViewport extends RenderTwoDimensionalViewport {
  RenderTwoDimensionalGridViewport({
    required super.horizontalOffset,
    required super.horizontalAxisDirection,
    required super.verticalOffset,
    required super.verticalAxisDirection,
    required TwoDimensionalChildBuilderDelegate delegate,
    required super.mainAxis,
    required super.childManager,
    super.cacheExtent,
    super.clipBehavior = Clip.hardEdge,
  }) : super(delegate: delegate);

  @override
  void layoutChildSequence() {
    final double horizontalPixels = horizontalOffset.pixels;
    final double verticalPixels = verticalOffset.pixels;
    final double viewportWidth = viewportDimension.width + cacheExtent;
    final double viewportHeight = viewportDimension.height + cacheExtent;
    final TwoDimensionalChildBuilderDelegate builderDelegate =
        delegate as TwoDimensionalChildBuilderDelegate;

    final int maxRowIndex = builderDelegate.maxYIndex!;
    final int maxColumnIndex = builderDelegate.maxXIndex!;

    final int leadingColumn = math.max((horizontalPixels / 75).floor(), 0);
    final int leadingRow = math.max((verticalPixels / 75).floor(), 0);
    final int trailingColumn = math.min(
      ((horizontalPixels + viewportWidth) / 75).ceil(),
      maxColumnIndex,
    );
    final int trailingRow = math.min(
      ((verticalPixels + viewportHeight) / 75).ceil(),
      maxRowIndex,
    );

    double xLayoutOffset = (leadingColumn * 75) - horizontalOffset.pixels;
    for (int column = leadingColumn; column <= trailingColumn; column++) {
      double yLayoutOffset = (leadingRow * 75) - verticalOffset.pixels;
      for (int row = leadingRow; row <= trailingRow; row++) {
        final ChildVicinity vicinity =
            ChildVicinity(xIndex: column, yIndex: row);
        final RenderBox child = buildOrObtainChildFor(vicinity)!;
        child.layout(constraints.loosen());

        // Subclasses only need to set the normalized layout offset. The super
        // class adjusts for reversed axes.
        parentDataOf(child).layoutOffset = Offset(xLayoutOffset, yLayoutOffset);
        yLayoutOffset += 75;
      }
      xLayoutOffset += 75;
    }

    // Set the min and max scroll extents for each axis.
    final double verticalExtent = 75 * (maxRowIndex + 1);
    verticalOffset.applyContentDimensions(
      0.0,
      clampDouble(
          verticalExtent - viewportDimension.height, 0.0, double.infinity),
    );
    final double horizontalExtent = 75 * (maxColumnIndex + 1);
    horizontalOffset.applyContentDimensions(
      0.0,
      clampDouble(
          horizontalExtent - viewportDimension.width, 0.0, double.infinity),
    );
    // Super class handles garbage collection too!
  }
}
