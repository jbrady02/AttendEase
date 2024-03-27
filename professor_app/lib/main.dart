import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:postgres/postgres.dart';
import 'package:professor_app/edit_class_add_student.dart';
import 'package:professor_app/edit_class_remove_student.dart';
import 'class_information.dart';
import 'database_helper.dart';
import 'view_students.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Professor Attendance App',
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: PointerDeviceKind.values.toSet(),
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: 'Your classes'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => Home();
}

/// State class for the main page.
class Home extends State<MyHomePage> {
  // Theme
  static const TextStyle bodyText = TextStyle(
    fontSize: 20,
    color: Colors.black,
  );
  static const Color primaryColor = Color.fromARGB(255, 255, 100, 100);

  List<int> classID = [];
  List<String> className = [];

  /// Display app information and licenses.
  void _showAboutDialog({
    required BuildContext context,
    String? applicationName,
    String? applicationVersion,
    Widget? applicationIcon,
    String? applicationLegalese,
    List<Widget>? children,
    bool barrierDismissible = true,
    Color? barrierColor,
    String? barrierLabel,
    bool useRootNavigator = true,
    RouteSettings? routeSettings,
    Offset? anchorPoint,
  }) {
    showDialog<void>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      barrierLabel: barrierLabel,
      useRootNavigator: useRootNavigator,
      builder: (BuildContext context) {
        return AboutDialog(
          applicationName: applicationName,
          applicationVersion: applicationVersion,
          applicationIcon: applicationIcon,
          applicationLegalese: applicationLegalese,
          children: children,
        );
      },
      routeSettings: routeSettings,
      anchorPoint: anchorPoint,
    );
  }

  /// Dialog to add a class to the classes table.
  void _addClassDialog(BuildContext context) {
    var classNameTextField = TextEditingController();
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text('Add a class', textAlign: TextAlign.center),
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: SizedBox(
                  width: 200,
                  child: TextField(
                    controller: classNameTextField,
                    maxLength: 100,
                    minLines: 1,
                    maxLines: 10,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Class name and time',
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
                        if (classNameTextField.text.isNotEmpty) {
                          Navigator.pop(context);
                          DatabaseHelper dbHelper = DatabaseHelper();
                          dbHelper.addClass(
                              classNameTextField.text.replaceAll('\n', ''));
                          // Wait 250 ms for the database to update
                          Future.delayed(const Duration(milliseconds: 250), () {
                            setState(() {
                              classID = [];
                              className = [];
                            });
                          });
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
                      child: const Text('Add class', style: bodyText)),
                ),
              ),
            ],
          );
        });
  }

  /// Mobile device class action selection dialog.
  /// 
  /// [classIndex] is the class index in the className and classID lists.
  void _showSelectionDialog(BuildContext context, int classIndex) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(className[classIndex]),
          children: [
            SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Take attendance', style: bodyText)),
            SimpleDialogOption(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ClassInformation(
                            classIndex, className[classIndex])),
                  );
                },
                child: const Text('View/edit data', style: bodyText)),
            SimpleDialogOption(
                onPressed: () {
                  _editClassDialog(classID[classIndex], className[classIndex]);
                },
                child: const Text('Edit class info', style: bodyText)),
          ],
        );
      },
    );
  }

  /// Dialog to edit a class in the classes table.
  /// 
  /// [editClassID] is the class_id of the class to be edited.
  /// [editClassName] is the name of the class to be edited.
  void _editClassDialog(int editClassID, String editClassName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(editClassName),
          children: [
            SimpleDialogOption(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => EditClassAddStudent(editClassID)),
                  );
                },
                child: const Text('Add a student', style: bodyText)),
            SimpleDialogOption(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            EditClassRemoveStudent(editClassID)),
                  );
                },
                child: const Text('Remove a student', style: bodyText)),
            SimpleDialogOption(
                onPressed: () {
                  _renameClassDialog(context, editClassID);
                },
                child: const Text('Rename class', style: bodyText)),
            SimpleDialogOption(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return SimpleDialog(
                        title: Text(
                            'Are you sure that you want to delete '
                            '$editClassName? This will delete all '
                            'attendance records for this class.',
                            textAlign: TextAlign.center),
                        children: [
                          SizedBox(
                            height: 75,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              child: OutlinedButton(
                                  onPressed: () {
                                    removeClass(editClassID);
                                    // Wait 250 ms for the database to update
                                    Future.delayed(
                                        const Duration(milliseconds: 250), () {
                                      setState(() {
                                        classID = [];
                                        className = [];
                                      });
                                      _popNavigator(
                                          context, isDesktop() ? 2 : 3);
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                  ),
                                  child: const Text('Yes', style: bodyText)),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text('Delete class', style: bodyText))
          ],
        );
      },
    );
  }

  /// Put the classes data into lists for this page only.
  /// 
  /// [classes] is the data from the classes table.
  void _addClassesToLists(List<dynamic> classes) {
    for (var index = 0; index < classes.length; index++) {
      classID.add(classes[index][0]);
      className.add(classes[index][1]);
    }
  }

  /// Get all classes from the classes table.
  /// 
  /// Return a Future object with the classes data.
  Future<Result> getClassList() async {
    DatabaseHelper dbHelper = DatabaseHelper();
    return (dbHelper.getClasses());
  }

  /// Dialog to update a class_name in the classes table.
  /// 
  /// [editClassID] is the class_id of the class to be renamed.
  void _renameClassDialog(BuildContext context, int editClassID) {
    var classNameTextField = TextEditingController();
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text('Rename the class', textAlign: TextAlign.center),
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: SizedBox(
                  width: 200,
                  child: TextField(
                    controller: classNameTextField,
                    maxLength: 100,
                    minLines: 1,
                    maxLines: 10,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Class name and time',
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
                        if (classNameTextField.text.isNotEmpty) {
                          DatabaseHelper dbHelper = DatabaseHelper();
                          dbHelper.renameClass(editClassID,
                              classNameTextField.text.replaceAll('\n', ''));
                          // Wait 250 ms for the database to update
                          Future.delayed(const Duration(milliseconds: 250), () {
                            setState(() {
                              classID = [];
                              className = [];
                            });
                            _popNavigator(context, isDesktop() ? 2 : 3);
                          });
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
                      child: const Text('Rename class', style: bodyText)),
                ),
              ),
            ],
          );
        });
  }

  /// Remove [classID] from the classes table.
  void removeClass(int classID) async {
    DatabaseHelper dbHelper = DatabaseHelper();
    dbHelper.removeClass(classID);
  }

  /// Check to see if the app is running on a desktop or mobile device.
  /// 
  /// Mobile devices have a different layout.
  bool isDesktop() {
    return (kIsWeb ||
        Platform.isWindows ||
        Platform.isLinux ||
        Platform.isMacOS ||
        Platform.isFuchsia);
  }

  /// Pop the navigator [numPops] times.
  void _popNavigator(BuildContext context, int numPops) {
    for (var i = 0; i < numPops; i++) {
      Navigator.pop(context);
    }
  }

  /// Build the main page.
  ///
  /// This method is rerun every time setState is called.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getClassList(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // While waiting, display a loading indicator
            return Scaffold(
              appBar: AppBar(
                backgroundColor: primaryColor,
                title: Text(widget.title),
              ),
              body: const Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError || snapshot.data!.isEmpty) {
            // Put snapshot data into classID and className lists
            _addClassesToLists(snapshot.data!);
            // Display a message about no classes being found
            return Scaffold(
              appBar: AppBar(
                backgroundColor: primaryColor,
                title: Text(widget.title),
              ),
              body: const Center(
                  child: Text(
                'No classes found. Please add a class or refresh the page.',
                style: bodyText,
                textAlign: TextAlign.center,
              )),
              bottomNavigationBar: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FloatingActionButton(
                    heroTag: 'addClass',
                    onPressed: () {
                      _addClassDialog(context);
                    },
                    backgroundColor: primaryColor,
                    tooltip: 'Add a class',
                    child: const Icon(Icons.add),
                  ),
                  FloatingActionButton(
                    heroTag: 'refresh',
                    onPressed: () {
                      setState(() {
                        classID = [];
                        className = [];
                      });
                    },
                    backgroundColor: primaryColor,
                    tooltip: 'Refresh page',
                    child: const Icon(Icons.refresh),
                  ),
                  SizedBox(
                    width: 130,
                    child: FloatingActionButton(
                      heroTag: 'viewAllStudents',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Students()),
                        );
                      },
                      backgroundColor: primaryColor,
                      child: const Text('Students', style: bodyText),
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    child: FloatingActionButton(
                      heroTag: 'license',
                      onPressed: () {
                        _showAboutDialog(
                            context: context, applicationVersion: '0.0.0');
                      },
                      backgroundColor: primaryColor,
                      child: const Text('About', style: bodyText),
                    ),
                  ),
                ],
              ),
            );
          } else {
            // Put snapshot data into classID and className lists
            _addClassesToLists(snapshot.data!);
            // Future object found; display classes
            return Scaffold(
              appBar: AppBar(
                backgroundColor: primaryColor,
                title: Text(widget.title),
              ),
              body: TwoDimensionalGridView(
                  diagonalDragBehavior: DiagonalDragBehavior.free,
                  // Different delegate for mobile and desktop
                  delegate: isDesktop()
                      // Desktop layout
                      ? TwoDimensionalChildBuilderDelegate(
                          maxXIndex: 3,
                          maxYIndex: className.length - 1,
                          builder:
                              (BuildContext context, ChildVicinity vicinity) {
                            return SizedBox(
                              height: 75,
                              width: (vicinity.xIndex == 0) ? 400 : 600,
                              child: Center(
                                  child: (vicinity.xIndex == 0)
                                      ? Center(
                                          child: Text(
                                            className[vicinity.yIndex],
                                            style: bodyText,
                                            textAlign: TextAlign.center,
                                          ),
                                        )
                                      : (vicinity.xIndex == 1)
                                          ? SizedBox(
                                              width: 197,
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  null;
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: primaryColor,
                                                ),
                                                child: const Text(
                                                    'Take attendance', // TODO: Implement
                                                    style: bodyText),
                                              ),
                                            )
                                          : (vicinity.xIndex == 2)
                                              ? SizedBox(
                                                  width: 197,
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                ClassInformation(
                                                                    classID[vicinity
                                                                        .yIndex],
                                                                    className[
                                                                        vicinity
                                                                            .yIndex])),
                                                      );
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          primaryColor,
                                                    ),
                                                    child: const Text(
                                                        'View/edit data',
                                                        style: bodyText),
                                                  ),
                                                )
                                              : SizedBox(
                                                  width: 197,
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      _editClassDialog(
                                                          classID[
                                                              vicinity.yIndex],
                                                          className[
                                                              vicinity.yIndex]);
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          primaryColor,
                                                    ),
                                                    child: const Text(
                                                        'Edit class info',
                                                        style: bodyText),
                                                  ),
                                                )),
                            );
                          })
                      // Mobile layout
                      : TwoDimensionalChildBuilderDelegate(
                          maxXIndex: 0,
                          maxYIndex: className.length - 1,
                          builder:
                              (BuildContext context, ChildVicinity vicinity) {
                            return SizedBox(
                              height: 100,
                              child: Center(
                                  child: ElevatedButton(
                                onPressed: () {
                                  _showSelectionDialog(
                                      context, vicinity.yIndex);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                ),
                                child: Text(
                                  className[vicinity.yIndex],
                                  style: bodyText,
                                  textAlign: TextAlign.center,
                                ),
                              )),
                            );
                          })),
              bottomNavigationBar: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FloatingActionButton(
                    heroTag: 'addClass',
                    onPressed: () {
                      _addClassDialog(context);
                    },
                    backgroundColor: primaryColor,
                    tooltip: 'Add a class',
                    child: const Icon(Icons.add),
                  ),
                  FloatingActionButton(
                    heroTag: 'refresh',
                    onPressed: () {
                      setState(() {
                        classID = [];
                        className = [];
                      });
                    },
                    backgroundColor: primaryColor,
                    tooltip: 'Refresh page',
                    child: const Icon(Icons.refresh),
                  ),
                  SizedBox(
                    width: 130,
                    child: FloatingActionButton(
                      heroTag: 'viewAllStudents',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Students()),
                        );
                      },
                      backgroundColor: primaryColor,
                      child: const Text('Students', style: bodyText),
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    child: FloatingActionButton(
                      heroTag: 'license',
                      onPressed: () {
                        _showAboutDialog(
                            context: context, applicationVersion: '0.0.0');
                      },
                      backgroundColor: primaryColor,
                      child: const Text('About', style: bodyText),
                    ),
                  ),
                ],
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
