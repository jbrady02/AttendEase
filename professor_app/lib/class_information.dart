import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ClassInformation extends StatelessWidget {
  final int classID;
  final String classInfo;

  ClassInformation(this.classID, this.classInfo, {super.key});

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

  static const Map<String, List<int>> students = {
    'Long String Name': [1, 2, 3, 4, 5],
    'Jane Doe': [1, 0, 1, 1, 1],
    'Alice': [0, 0, 0, 0, 0],
    'Bob': [0, 1, 0, 1, 1]
  };

  static const List<String> classSessions = [
    '2024-07-01',
    '2024-07-03',
    '2023-07-05',
    '2023-07-07',
    '2023-07-09',
  ];

  String getAttendance(int attendanceInt) {
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

  Color getColor(int attendanceInt) {
    switch (attendanceInt) {
      case present:
        return Colors.green;
      case absentExcused || absentUnexcused:
        return Colors.orange;
      case tardyExcused || tardyUnexcused:
        return Colors.yellow;
      default:
        return Colors.white;
    }
  }

  Color getOutlineColor(int attendanceInt) {
    switch (attendanceInt) {
      case absentUnexcused || tardyUnexcused:
        return Colors.red;
      case unknown:
        return Colors.black;
      default:
        return Colors.transparent;
    }
  }

  void _showSelectionDialog(
      BuildContext context, int nameIndex, int dateIndex) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text('Edit attendance data for '
              '${students.keys.toList()[nameIndex]} '
              'on ${classSessions[dateIndex]}:'),
          children: [
            Container(
              color: Colors.green,
              child: SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, present);
                },
                child: students.values.toList()[nameIndex][dateIndex] == present
                    ? const Text('Present (current value)', style: bodyText)
                    : const Text('Present', style: bodyText),
              ),
            ),
            Container(
              color: Colors.orange,
              child: SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, absentExcused);
                },
                child: students.values.toList()[nameIndex][dateIndex] == absentExcused
                    ? const Text('Absent and excused (current value)',
                        style: bodyText)
                    : const Text('Absent and excused', style: bodyText),
              ),
            ),
            Container(
              color: Colors.orange,
              child: SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, absentUnexcused);
                },
                child: students.values.toList()[nameIndex][dateIndex] == absentUnexcused
                    ? const Text('Absent and unexcused (current value)',
                        style: bodyText)
                    : const Text('Absent and unexcused', style: bodyText),
              ),
            ),
            Container(
              color: Colors.yellow,
              child: SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, tardyExcused);
                },
                child: students.values.toList()[nameIndex][dateIndex] == tardyExcused
                    ? const Text('Tardy and excused (current value)',
                        style: bodyText)
                    : const Text('Tardy and excused', style: bodyText),
              ),
            ),
            Container(
              color: Colors.yellow,
              child: SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, tardyUnexcused);
                },
                child: students.values.toList()[nameIndex][dateIndex] == tardyUnexcused
                    ? const Text('Tardy and unexcused (current value)',
                        style: bodyText)
                    : const Text('Tardy and unexcused', style: bodyText),
              ),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, unknown);
              },
              child: students.values.toList()[nameIndex][dateIndex] == unknown
                  ? const Text('Unknown (current value)', style: bodyText)
                  : const Text('Unknown', style: bodyText),
            ),
          ],
        );
      },
    ).then((selectedValue) {
      null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(classInfo),
      ),
      body: TwoDimensionalGridView(
        diagonalDragBehavior: DiagonalDragBehavior.free,
        delegate: TwoDimensionalChildBuilderDelegate(
            maxXIndex: students.values.first.length,
            maxYIndex: students.length,
            builder: (BuildContext context, ChildVicinity vicinity) {
              return SizedBox(
                  height: 75,
                  width: 75,
                  child: Center(
                    child: (vicinity.xIndex == 0 && vicinity.yIndex == 0)
                        ? null // Empty top-left corner
                        : (vicinity.xIndex == 0)
                            ? Center(
                                child: Text(
                                    // Name
                                    students.keys
                                        .toList()[vicinity.yIndex - 1]
                                        .replaceAll('-', '-\n'),
                                    style:
                                        // Separate name by spaces and if a
                                        // token has than 8 characters,
                                        // decrease the font size
                                        students.keys
                                                .toList()[vicinity.yIndex - 1]
                                                .split(' ')
                                                .any((element) =>
                                                    element.length > 8)
                                            ? smallBodyText.copyWith(
                                                fontSize: 12)
                                            : smallBodyText,
                                    textAlign: TextAlign.center),
                              )
                            : (vicinity.yIndex == 0)
                                ? Center(
                                    child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 13, right: 13),
                                    child: Text(
                                        // Date
                                        classSessions[vicinity.xIndex - 1],
                                        style: smallBodyText,
                                        textAlign: TextAlign.center),
                                  ))
                                : SizedBox(
                                    width: 70,
                                    child: OutlinedButton(
                                      // Attendance
                                      onPressed: () {
                                        _showSelectionDialog(
                                            context,
                                            vicinity.yIndex - 1,
                                            vicinity.xIndex - 1);
                                      },
                                      style: OutlinedButton.styleFrom(
                                          side: BorderSide(
                                              color: getOutlineColor(
                                                  students.values.toList()[
                                                          vicinity.yIndex - 1]
                                                      [vicinity.xIndex - 1]),
                                              width: 3), // Set the border color
                                          backgroundColor: getColor(students
                                                  .values
                                                  .toList()[vicinity.yIndex - 1]
                                              [vicinity.xIndex - 1])),
                                      // Set the background color
                                      child: Text(
                                          getAttendance(
                                              // Get integer value in list from map
                                              students.values.toList()[
                                                      vicinity.yIndex - 1]
                                                  [vicinity.xIndex - 1]),
                                          style: smallBodyText),
                                    ),
                                  ),
                  ));
            }),
      ),
    );
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
