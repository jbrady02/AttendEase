import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:postgres/postgres.dart';
import 'package:professor_app/database_helper.dart';
import 'package:professor_app/student.dart';

class EditClassRemoveStudent extends StatelessWidget {
  final int classID;

  const EditClassRemoveStudent(this.classID, {super.key});

  // Theme
  static const TextStyle bodyText = TextStyle(
    fontSize: 20,
    color: Colors.black,
  );

  static const Color primaryColor = Color.fromARGB(255, 255, 100, 100);

  Future<Map<List<Student>, Result>> getAllStudentsAndClass(int classID) async {
    DatabaseHelper dbHelper = DatabaseHelper();
    List<Student> students = await dbHelper.getStudents();
    Result classResult = await dbHelper.getClass(classID);
    return {students: classResult};
  }

  /// Remove a student from the class.
  /// 
  /// [studentID] is the ID of the student to remove.
  void removeStudentFromClass(int studentID) async {
    DatabaseHelper dbHelper = DatabaseHelper();
    dbHelper.removeStudentFromClass(classID, studentID);
  }

  /// Reload the page and pop the page [numPops] times.
  Future<void> reload(BuildContext context, numPops) async {
    showDialog(
        context: context,
        builder: (context) {
          return const Center(child: CircularProgressIndicator());
        });
    // Wait 250 ms for the database to update before popping the page.
    await Future.delayed(const Duration(milliseconds: 250), () {
      for (var i = 0; i < numPops; i++) {
        Navigator.pop(context);
      }
    });
  }

  /// Get the class information for the class with ID [classID].
  Future<Result> getClass(int classID) async {
    DatabaseHelper dbHelper = DatabaseHelper();
    return (await dbHelper.getClass(classID));
  }

  /// Build the widget.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<List<Student>, Result>>(
        future: getAllStudentsAndClass(classID),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // While waiting, display a loading indicator.
            return Scaffold(
              appBar: AppBar(
                backgroundColor: primaryColor,
                title: const Text('Remove a student from'),
              ),
              body: const Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError) {
            // If an error occurs, display an error message.
            return Scaffold(
              appBar: AppBar(
                backgroundColor: primaryColor,
                title: const Text('Remove a student from'),
              ),
              body: const Center(
                  child: Text(
                'Could not connect to the database.',
                style: bodyText,
                textAlign: TextAlign.center,
              )),
            );
          } else {
            // Future object found; display students.
            List<Student>? students = snapshot.data!.keys.first
                .where((student) => student.studentID != 0)
                .toList();
            List<dynamic>? classInfo = snapshot.data!.values.first[0];
            if (classInfo[2] == null) {
            } else {
              for (int i = 0; i < students.length; i++) {
                if (!classInfo[2].contains(students[i].studentID)) {
                  students.removeAt(i);
                  i--; // Decrement i to account for the removed element.
                }
              }
            }
            return Scaffold(
              appBar: AppBar(
                backgroundColor: primaryColor,
                title: Text('Remove a student from ${classInfo[1]}'),
              ),
              body: (students.length - 1 < 0) // Message if no students found.
                  ? const Center(
                      child: Text(
                      'No students that are not already in the class were found.',
                      style: bodyText,
                      textAlign: TextAlign.center,
                    ))
                  : TwoDimensionalGridView(
                      delegate: TwoDimensionalChildBuilderDelegate(
                          maxXIndex: 0,
                          maxYIndex: students.length - 1,
                          builder:
                              (BuildContext context, ChildVicinity vicinity) {
                            return SizedBox(
                              height: 75,
                              child: Center(
                                  child: ElevatedButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return SimpleDialog(
                                        title: Text(
                                            'Are you sure that '
                                            'you want to remove '
                                            '${students[vicinity.yIndex].givenName} '
                                            '${students[vicinity.yIndex].surname} '
                                            'from ${classInfo[1]}? This '
                                            'will delete all attendance data '
                                            'for this student in this class.',
                                            textAlign: TextAlign.center),
                                        children: [
                                          SizedBox(
                                            height: 75,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 10),
                                              child: OutlinedButton(
                                                  onPressed: () {
                                                    removeStudentFromClass(
                                                        students[
                                                                vicinity.yIndex]
                                                            .studentID);
                                                    reload(context, 3);
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.green,
                                                  ),
                                                  child: const Text('Yes',
                                                      style: bodyText)),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                ),
                                child: Text(
                                  '${students[vicinity.yIndex].givenName} ${students[vicinity.yIndex].surname}',
                                  style: bodyText,
                                  textAlign: TextAlign.center,
                                ),
                              )),
                            );
                          })),
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
