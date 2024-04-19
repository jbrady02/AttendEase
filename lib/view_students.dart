import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:professor_app/database_helper.dart';
import 'package:professor_app/student.dart';

class Students extends StatelessWidget {
  const Students({super.key});

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

  /// Dialog to add a student to the students table.
  /// 
  /// [customFields] is a list of the custom fields.
  void _addStudentDialog(BuildContext context, List<Student> customFields) {
    TextEditingController givenNameTextField = TextEditingController();
    TextEditingController surnameTextField = TextEditingController();
    TextEditingController customField1TextField = TextEditingController();
    TextEditingController customField2TextField = TextEditingController();
    TextEditingController customField3TextField = TextEditingController();
    TextEditingController customField4TextField = TextEditingController();
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text('Add a student', textAlign: TextAlign.center),
            children: [
              Padding( // Given name text field.
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: SizedBox(
                  width: 200,
                  child: TextField(
                    controller: givenNameTextField,
                    maxLength: 50,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Given name',
                    ),
                  ),
                ),
              ),
              Padding( // Surname text field.
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: SizedBox(
                  width: 200,
                  child: TextField(
                    controller: surnameTextField,
                    maxLength: 50,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Surname',
                    ),
                  ),
                ),
              ),
              Padding( // Custom field 1 text field.
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: SizedBox(
                  width: 200,
                  child: TextField(
                    controller: customField1TextField,
                    maxLength: 50,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: '${customFields[0].customField1} (optional)',
                    ),
                  ),
                ),
              ),
              Padding( // Custom field 2 text field.
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: SizedBox(
                  width: 200,
                  child: TextField(
                    controller: customField2TextField,
                    maxLength: 50,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: '${customFields[0].customField2} (optional)',
                    ),
                  ),
                ),
              ),
              Padding( // Custom field 3 text field.
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: SizedBox(
                  width: 200,
                  child: TextField(
                    controller: customField3TextField,
                    maxLength: 50,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: '${customFields[0].customField3} (optional)',
                    ),
                  ),
                ),
              ),
              Padding( // Custom field 4 text field.
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: SizedBox(
                  width: 200,
                  child: TextField(
                    controller: customField4TextField,
                    maxLength: 50,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: '${customFields[0].customField4} (optional)',
                    ),
                  ),
                ),
              ),
              SizedBox( // Add student button.
                height: 75,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: OutlinedButton(
                      onPressed: () {
                        if (givenNameTextField.text.isNotEmpty &&
                            surnameTextField.text.isNotEmpty) {
                          DatabaseHelper dbHelper = DatabaseHelper();
                          dbHelper.addStudent(
                              givenNameTextField.text,
                              surnameTextField.text,
                              customField1TextField.text,
                              customField2TextField.text,
                              customField3TextField.text,
                              customField4TextField.text);
                          reload(context, 3);
                        } else { // If input is empty show an error dialog.
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text(
                                      'The student must have a given name and surname.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text('OK'),
                                    ),
                                  ],
                                );
                              });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text('Add student', style: bodyText)),
                ),
              ),
            ],
          );
        });
  }

  /// Dialog to remove a student from the students table.
  /// 
  /// [students] is a list Student objects containing.
  /// information for all students in the students table.
  void _removeStudentDialog(BuildContext context, List<Student> students) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Remove a student', textAlign: TextAlign.center),
          // Make children a list of buttons, one for each student.
          children: students
              .map((students) => Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: SizedBox(
                      width: 200,
                      child: ElevatedButton(
                        onPressed: () {
                          DatabaseHelper dbHelper = DatabaseHelper();
                          dbHelper.removeStudent(students.studentID);
                          reload(context, 3);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: Text(
                          '${students.givenName} ${students.surname}',
                          style: smallBodyText,
                        ),
                      ),
                    ),
                  ))
              .toList(),
        );
      },
    );
  }

  /// Dialog to edit a student in the students table.
  void _editStudentDialog(
      BuildContext context,
      List<Student> customFields,
      List<Student> students,
      String columnName,
      String databaseField,
      String givenName,
      String surname,
      int studentID,
      bool isCustomField) {
    TextEditingController editStudentTextField = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(
              (isCustomField)
                  ? 'Edit column name \n(currently $columnName)'
                  : 'Edit the $columnName for $givenName $surname',
              textAlign: TextAlign.center),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: SizedBox(
                width: 200,
                child: TextField(
                  controller: editStudentTextField,
                  maxLength: 50,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText:
                        (isCustomField) ? 'New column name' : 'New $columnName',
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 75,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: OutlinedButton(
                    onPressed: () {
                      if (editStudentTextField.text.isNotEmpty) {
                        DatabaseHelper dbHelper = DatabaseHelper();
                        dbHelper.editStudent(databaseField,
                            editStudentTextField.text, studentID);
                        reload(context, 3);
                      } else {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title:
                                    const Text('The value can not be empty.'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              );
                            });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: Text(
                        (isCustomField)
                            ? 'Edit column name'
                            : 'Edit $columnName',
                        style: bodyText)),
              ),
            ),
          ],
        );
      },
    );
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
          context, MaterialPageRoute(builder: (context) => const Students()));
    });
  }

  /// Build the view students page.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Student>>(
        future: getAllStudents(),
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
          } else {
            // Future object found; display students.
            List<Student>? students = snapshot.data;
            List<Student>?
                customFields = // Get the custom fields from student 0.
                students?.where((student) => student.studentID == 0).toList();
            students = // Remove student 0 from the list of students.
                students?.where((student) => student.studentID != 0).toList();
            return Scaffold(
              appBar: AppBar(
                backgroundColor: primaryColor,
                title: const Text('All students'),
              ),
              body: TwoDimensionalGridView(
                  diagonalDragBehavior: DiagonalDragBehavior.free,
                  delegate: TwoDimensionalChildBuilderDelegate(
                    maxXIndex: 5,
                    maxYIndex: students?.length,
                    builder: (BuildContext context, ChildVicinity vicinity) {
                      return SizedBox(
                          height: 75,
                          width: 200,
                          child: Center(
                              child:
                                  (vicinity.xIndex == 0 &&
                                              vicinity.yIndex == 0 ||
                                          vicinity.xIndex == 1 &&
                                              vicinity.yIndex == 0)
                                      ? Center(
                                          child: Text(
                                              (vicinity.xIndex == 0)
                                                  ? customFields![0].givenName
                                                  : customFields![0].surname,
                                              style: bodyText,
                                              textAlign: TextAlign.center),
                                        )
                                      : SizedBox(
                                          width: 190,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              (vicinity.yIndex != 0)
                                                  ? _editStudentDialog(
                                                      context,
                                                      customFields!,
                                                      students!,
                                                      (vicinity.xIndex == 0)
                                                          ? 'given name'
                                                          : (vicinity.xIndex ==
                                                                  1)
                                                              ? 'surname'
                                                              : (vicinity.xIndex ==
                                                                      2)
                                                                  ? customFields[0]
                                                                      .customField1
                                                                  : (vicinity.xIndex ==
                                                                          3)
                                                                      ? customFields[0]
                                                                          .customField2
                                                                      : (vicinity.xIndex ==
                                                                              4)
                                                                          ? customFields[0]
                                                                              .customField3
                                                                          : customFields[0]
                                                                              .customField4,
                                                      (vicinity.xIndex ==
                                                              0) // Table column names.
                                                          ? 'given_name'
                                                          : (vicinity.xIndex ==
                                                                  1)
                                                              ? 'surname'
                                                              : (vicinity.xIndex ==
                                                                      2)
                                                                  ? 'custom_field_1'
                                                                  : (vicinity.xIndex ==
                                                                          3)
                                                                      ? 'custom_field_2'
                                                                      : (vicinity.xIndex ==
                                                                              4)
                                                                          ? 'custom_field_3'
                                                                          : 'custom_field_4',
                                                      students[vicinity.yIndex - 1]
                                                          .givenName,
                                                      students[vicinity.yIndex -
                                                              1]
                                                          .surname,
                                                      students[vicinity.yIndex -
                                                              1]
                                                          .studentID,
                                                      false)
                                                  : _editStudentDialog(
                                                      context,
                                                      customFields!,
                                                      students!,
                                                      (vicinity.xIndex == 2)
                                                          ? customFields[0]
                                                              .customField1
                                                          : (vicinity.xIndex ==
                                                                  3)
                                                              ? customFields[0]
                                                                  .customField2
                                                              : (vicinity.xIndex ==
                                                                      4)
                                                                  ? customFields[0]
                                                                      .customField3
                                                                  : customFields[0]
                                                                      .customField4,
                                                      (vicinity.xIndex == 2)
                                                          ? 'custom_field_1'
                                                          : (vicinity.xIndex ==
                                                                  3)
                                                              ? 'custom_field_2'
                                                              : (vicinity.xIndex ==
                                                                      4)
                                                                  ? 'custom_field_3'
                                                                  : 'custom_field_4',
                                                      'a',
                                                      'a',
                                                      0,
                                                      true);
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: primaryColor,
                                            ),
                                            child: Text(
                                              // Display student information.
                                              (vicinity.yIndex != 0)
                                                  ? (vicinity.xIndex == 0)
                                                      ? students![vicinity.yIndex - 1]
                                                          .givenName
                                                      : (vicinity.xIndex == 1)
                                                          ? students![vicinity
                                                                      .yIndex -
                                                                  1]
                                                              .surname
                                                          : (vicinity.xIndex ==
                                                                  2)
                                                              ? students![vicinity
                                                                          .yIndex -
                                                                      1]
                                                                  .customField1
                                                              : (vicinity.xIndex ==
                                                                      3)
                                                                  ? students![
                                                                          vicinity.yIndex -
                                                                              1]
                                                                      .customField2
                                                                  : (vicinity.xIndex ==
                                                                          4)
                                                                      ? students![vicinity.yIndex - 1]
                                                                          .customField3
                                                                      : students![vicinity.yIndex - 1]
                                                                          .customField4
                                                  : (vicinity.xIndex == 2)
                                                      ? customFields![0]
                                                          .customField1
                                                      : (vicinity.xIndex == 3)
                                                          ? customFields![0]
                                                              .customField2
                                                          : (vicinity.xIndex ==
                                                                  4)
                                                              ? customFields![0]
                                                                  .customField3
                                                              : customFields![0]
                                                                  .customField4,
                                              style: smallBodyText,
                                            ),
                                          ))));
                    },
                  )),
              bottomNavigationBar: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FloatingActionButton(
                    heroTag: 'addStudent',
                    onPressed: () {
                      _addStudentDialog(context, customFields!);
                    },
                    backgroundColor: primaryColor,
                    tooltip: 'Add a student',
                    child: const Icon(Icons.add),
                  ),
                  FloatingActionButton(
                    heroTag: 'removeStudent',
                    onPressed: () {
                      _removeStudentDialog(context, students!);
                    },
                    backgroundColor: primaryColor,
                    tooltip: 'Remove a student',
                    child: const Icon(Icons.remove),
                  ),
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
          }
        });
  }
}

Future<List<Student>> getAllStudents() async {
  DatabaseHelper dbHelper = DatabaseHelper();
  return (await dbHelper.getStudents());
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

    final int leadingColumn = math.max((horizontalPixels / 200).floor(), 0);
    final int leadingRow = math.max((verticalPixels / 75).floor(), 0);
    final int trailingColumn = math.min(
      ((horizontalPixels + viewportWidth) / 200).ceil(),
      maxColumnIndex,
    );
    final int trailingRow = math.min(
      ((verticalPixels + viewportHeight) / 75).ceil(),
      maxRowIndex,
    );

    double xLayoutOffset = (leadingColumn * 200) - horizontalOffset.pixels;
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
      xLayoutOffset += 200;
    }

    // Set the min and max scroll extents for each axis.
    final double verticalExtent = 75 * (maxRowIndex + 1);
    verticalOffset.applyContentDimensions(
      0.0,
      clampDouble(
          verticalExtent - viewportDimension.height, 0.0, double.infinity),
    );
    final double horizontalExtent = 200 * (maxColumnIndex + 1);
    horizontalOffset.applyContentDimensions(
      0.0,
      clampDouble(
          horizontalExtent - viewportDimension.width, 0.0, double.infinity),
    );
    // Super class handles garbage collection too!
  }
}
