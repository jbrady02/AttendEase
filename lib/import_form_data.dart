import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:postgres/postgres.dart';
import 'package:professor_app/database_helper.dart';

class ImportFormData extends StatelessWidget {
  final int classID;

  const ImportFormData(this.classID, {super.key});

  // Theme
  static const TextStyle bodyText = TextStyle(
    fontSize: 20,
    color: Colors.black,
  );

  static const Color primaryColor = Color.fromARGB(255, 255, 100, 100);

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

  /// Get the class information from the classes record with [classID].
  Future<Result> getClassSessions(int classID) async {
    DatabaseHelper dbHelper = DatabaseHelper();
    return (await dbHelper.getClassSessions(classID));
  }

  /// Import the form data into the database.
  ///
  /// [classID] is the ID of the class to import the data into.
  /// [sessionID] is the ID of the class session to import the data into.
  /// [formCSV] is the CSV data to import.
  void importForm(
      BuildContext context, int classID, int sessionID, String formCSV) async {
    // Remove all non-numeric characters except for ']' from the CSV.
    formCSV = formCSV.replaceAll(RegExp(r'[^0-9\]]'), '');
    // If formCSV ends with a ']', remove it.
    if (formCSV.endsWith(']')) {
      formCSV = formCSV.substring(0, formCSV.length - 1);
    }
    // Convert formCSV to a list of integers separated by commas.
    List<int> formList = formCSV.split(']').map(int.parse).toList();
    DatabaseHelper dbHelper = DatabaseHelper();
    dbHelper.importFormData(sessionID, classID, formList);
  }

  /// Show a dialog with a text input for the attendance data.
  ///
  /// [classID] is the ID of the class to import the data into.
  /// [sessionID] is the ID of the class session to import the data into.
  void showImportDialog(BuildContext context, int classID, int sessionID) {
    TextEditingController importFormTextField = TextEditingController();
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text('Import form data', textAlign: TextAlign.center),
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: SizedBox(
                  width: 200,
                  child: TextField(
                    controller: importFormTextField,
                    maxLength: 100000,
                    minLines: 1,
                    maxLines: 10,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Form output CSV',
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
                        if (importFormTextField.text.isNotEmpty) {
                          importForm(context, classID, sessionID,
                              importFormTextField.text);
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
                      child: const Text('Import form data', style: bodyText)),
                ),
              ),
            ],
          );
        });
  }

  /// Build the widget.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Result>(
        future: getClassSessions(classID),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // While waiting, display a loading indicator.
            return Scaffold(
              appBar: AppBar(
                backgroundColor: primaryColor,
                title: const Text('Select a class session to import data into'),
              ),
              body: const Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError) {
            // If an error occurs, display an error message.
            return Scaffold(
              appBar: AppBar(
                backgroundColor: primaryColor,
                title: const Text('Select a class session to import data into'),
              ),
              body: const Center(
                  child: Text(
                'Could not connect to the database.',
                style: bodyText,
                textAlign: TextAlign.center,
              )),
            );
          } else {
            // Future object found; display class sessions.
            // Convert result to Map.
            List<int> sessionIDs = [];
            List<String> sessionDates = [];
            for (int index = 0; index < snapshot.data!.length; index++) {
              sessionIDs.add(snapshot.data![index][0] as int);
              sessionDates.add(snapshot.data![index][1] as String);
            }
            Map<int, String> classSessions =
                Map.fromIterables(sessionIDs, sessionDates);
            return Scaffold(
              appBar: AppBar(
                backgroundColor: primaryColor,
                title: const Text('Select a class session to import data into'),
              ),
              body: (classSessions.length - 1 <
                      0) // Message if no students found.
                  ? const Center(
                      child: Text(
                      'No class sessions were found for this class.',
                      style: bodyText,
                      textAlign: TextAlign.center,
                    ))
                  : TwoDimensionalGridView(
                      delegate: TwoDimensionalChildBuilderDelegate(
                          maxXIndex: 0,
                          maxYIndex: classSessions.length - 1,
                          builder:
                              (BuildContext context, ChildVicinity vicinity) {
                            return SizedBox(
                              height: 75,
                              child: Center(
                                  child: ElevatedButton(
                                onPressed: () {
                                  showImportDialog(
                                      context,
                                      classID,
                                      classSessions.keys
                                          .elementAt(vicinity.yIndex));
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                ),
                                child: Text(
                                  classSessions.values
                                      .elementAt(vicinity.yIndex),
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
