import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'class_information.dart';
import 'database_helper.dart';

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
      home: const MyHomePage(title: 'Your Classes'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => Home();
}

class Home extends State<MyHomePage> {
  // Theme
  static const TextStyle bodyText = TextStyle(
    fontSize: 20,
    color: Colors.black,
  );
  static const Color primaryColor = Color.fromARGB(255, 255, 100, 100);

  int refreshTimer = 0;

  List<int> classID = [];
  List<String> classInfo = [];

  void _sample() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      // _counter++;
    });
  }

  void showAboutDialog({
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

  void addClassDialog(BuildContext context) {
    var classNameTextField = TextEditingController();
    var classDataTimeTextField = TextEditingController();
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
                  width: 250,
                  child: TextField(
                    controller: classNameTextField,
                    maxLength: 63,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Class name',
                    ),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: SizedBox(
                  width: 250,
                  child: TextField(
                    controller: classDataTimeTextField,
                    maxLength: 63,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Class date and time',
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
                        if (classNameTextField.text.isNotEmpty &&
                            classDataTimeTextField.text.isNotEmpty) {
                          Navigator.pop(context);
                          DatabaseHelper dbHelper = DatabaseHelper();
                          dbHelper.addClass(classNameTextField.text,
                              classDataTimeTextField.text);
                          setState(() {
                            // TODO: When edit class info is implemented, go to that page upon creation
                            classID = [];
                            classInfo = [];
                            refreshTimer = -1;
                          });
                        } else {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text(
                                      'You must fill out both fields.'),
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
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.green)),
                      child: const Text('Add class', style: bodyText)),
                ),
              ),
            ],
          );
        });
  }

  // Mobile device class action selection dialog
  void _showSelectionDialog(BuildContext context, int classIndex) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(classInfo[classIndex]),
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
                            classIndex, classInfo[classIndex])),
                  );
                },
                child: const Text('View/edit data', style: bodyText)),
            SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Edit class info', style: bodyText)),
          ],
        );
      },
    );
  }

  // Get Classes
  void getClassList() async {
    DatabaseHelper dbHelper = DatabaseHelper();
    dbHelper.getClasses().then((classList) {
      for (int index = 0; index < classList.length; index++) {
        classID.add(int.parse(classList[index][0].toString()));
        classInfo.add('${classList[index][1]} ${classList[index][2]}');
      }
    });
  }

  // This method is rerun every time setState is called
  @override
  Widget build(BuildContext context) {
    if (refreshTimer == 0) {
      // Get class information once
      getClassList();
    }
    if (refreshTimer < 30 && classID.isEmpty) {
      // Wait for class information
      Future.delayed(const Duration(milliseconds: 100), () {
        setState(() {
          refreshTimer++;
        });
      });
    } else if (refreshTimer >= 30 && classID.isEmpty) {
      // If class information is not found after waiting display message
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
                addClassDialog(context);
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
                  classInfo = [];
                  refreshTimer = 0;
                });
              }, // TODO: Implement
              backgroundColor: primaryColor,
              tooltip: 'Refresh page',
              child: const Icon(Icons.refresh),
            ),
            const SizedBox(
              width: 130,
              child: FloatingActionButton(
                heroTag: 'viewAllStudents',
                onPressed: null, // TODO: Implement
                backgroundColor: primaryColor,
                child: Text('Students', style: bodyText),
              ),
            ),
            SizedBox(
              width: 100,
              child: FloatingActionButton(
                heroTag: 'license',
                onPressed: () {
                  showAboutDialog(
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
    return classID.isEmpty
        ? Scaffold(
            // If class information is being loaded display loading screen
            appBar: AppBar(
              backgroundColor: primaryColor,
              title: Text(widget.title),
            ),
            body: const Center(child: CircularProgressIndicator()),
            bottomNavigationBar: SizedBox(
              width: 100,
              child: FloatingActionButton(
                heroTag: 'license',
                onPressed: () {
                  showAboutDialog(
                      context: context, applicationVersion: '0.0.0');
                },
                backgroundColor: primaryColor,
                child: const Text('About', style: bodyText),
              ),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: primaryColor,
              title: Text(widget.title),
            ),
            body: TwoDimensionalGridView(
                diagonalDragBehavior: DiagonalDragBehavior.free,
                // Different delegate for mobile and desktop
                delegate: kIsWeb ||
                        Platform.isWindows ||
                        Platform.isLinux ||
                        Platform.isMacOS ||
                        Platform.isFuchsia
                    // Desktop layout
                    ? TwoDimensionalChildBuilderDelegate(
                        maxXIndex: 3,
                        maxYIndex: classInfo.length - 1,
                        builder:
                            (BuildContext context, ChildVicinity vicinity) {
                          return SizedBox(
                            height: 75,
                            width: (vicinity.xIndex == 0) ? 400 : 600,
                            child: Center(
                                child: (vicinity.xIndex == 0)
                                    ? Center(
                                        child: Text(
                                          classInfo[vicinity.yIndex],
                                          style: bodyText,
                                          textAlign: TextAlign.center,
                                        ),
                                      )
                                    : (vicinity.xIndex == 1)
                                        ? SizedBox(
                                            width: 197,
                                            child: ElevatedButton(
                                              onPressed: null,
                                              style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty.all(
                                                          primaryColor)),
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
                                                                  classInfo[vicinity
                                                                      .yIndex])),
                                                    );
                                                  },
                                                  style: ButtonStyle(
                                                      backgroundColor:
                                                          MaterialStateProperty
                                                              .all(
                                                                  primaryColor)),
                                                  child: const Text(
                                                      'View/edit data',
                                                      style: bodyText),
                                                ),
                                              )
                                            : SizedBox(
                                                width: 197,
                                                child: ElevatedButton(
                                                  onPressed: () {},
                                                  style: ButtonStyle(
                                                      backgroundColor:
                                                          MaterialStateProperty
                                                              .all(
                                                                  primaryColor)),
                                                  child: const Text(
                                                      'Edit class info', // TODO: Implement
                                                      style: bodyText),
                                                ),
                                              )),
                          );
                        })
                    // Mobile layout
                    : TwoDimensionalChildBuilderDelegate(
                        maxXIndex: 0,
                        maxYIndex: classInfo.length - 1,
                        builder:
                            (BuildContext context, ChildVicinity vicinity) {
                          return SizedBox(
                            height: 100,
                            child: Center(
                                child: ElevatedButton(
                              onPressed: () {
                                _showSelectionDialog(context, vicinity.yIndex);
                              },
                              style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all(primaryColor)),
                              child: Text(
                                classInfo[vicinity.yIndex],
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
                    addClassDialog(context);
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
                      classInfo = [];
                      refreshTimer = 0;
                    });
                  },
                  backgroundColor: primaryColor,
                  tooltip: 'Refresh page',
                  child: const Icon(Icons.refresh),
                ),
                const SizedBox(
                  width: 130,
                  child: FloatingActionButton(
                    heroTag: 'viewAllStudents',
                    onPressed: null, // TODO: Implement
                    backgroundColor: primaryColor,
                    child: Text('Students', style: bodyText),
                  ),
                ),
                SizedBox(
                  width: 100,
                  child: FloatingActionButton(
                    heroTag: 'license',
                    onPressed: () {
                      showAboutDialog(
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
