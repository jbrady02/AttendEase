import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'class_information.dart';

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

  static const List<int> classID = [0, 1, 2, 3];
  static const List<String> className = [
    'Class name 1',
    'Class name 2',
    'Class name 3',
    'Class name 4'
  ];
  static const List<String> classMeetingDays = ['MWF', 'TR', 'F', 'MWF'];
  static const List<String> classMeetingTime = [
    '8:30-9:35',
    '12:20-2:00',
    '12:20-3:20',
    '12:15-1:20'
  ];

  void _incrementCounter() {
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

  @override
  Widget build(BuildContext context) { // TODO: Make a different home page layout for mobile
    // This method is rerun every time setState is called
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(widget.title),
      ),
      body: TwoDimensionalGridView(
        diagonalDragBehavior: DiagonalDragBehavior.free,
        delegate: TwoDimensionalChildBuilderDelegate(
            maxXIndex: 3,
            maxYIndex: className.length - 1,
            builder: (BuildContext context, ChildVicinity vicinity) {
              return SizedBox(
                height: 75,
                width: (vicinity.xIndex == 0) ? 400 : 600,
                child: Center(
                    child: (vicinity.xIndex == 0)
                        ? Center(
                            child: Text(
                              '${className[vicinity.yIndex]} ${classMeetingDays[vicinity.yIndex]} ${classMeetingTime[vicinity.yIndex]}',
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
                                  child: const Text('Take attendance', // TODO: Implement
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
                                                      vicinity.yIndex,
                                                      '${className[vicinity.yIndex]} ${classMeetingDays[vicinity.yIndex]} ${classMeetingTime[vicinity.yIndex]}')),
                                        );
                                      },
                                      style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  primaryColor)),
                                      child: const Text('View/edit data',
                                          style: bodyText),
                                    ),
                                  )
                                : SizedBox(
                                    width: 197,
                                    child: ElevatedButton(
                                      onPressed: null,
                                      style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  primaryColor)),
                                      child: const Text('Edit class info', // TODO: Implement
                                          style: bodyText),
                                    ),
                                  )),
              );
            }),
      ),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton(
            heroTag: 'addClass',
            onPressed: _incrementCounter, // TODO: Implement
            backgroundColor: primaryColor,
            tooltip: 'Add a class',
            child: const Icon(Icons.add),
          ),
          const FloatingActionButton(
            heroTag: 'removeClass',
            onPressed: null, // TODO: Implement
            backgroundColor: primaryColor,
            tooltip: 'Remove a class',
            child: Icon(Icons.remove),
          ),
          const SizedBox(
            width: 200,
            child: FloatingActionButton(
              heroTag: 'viewAllStudents',
              onPressed: null, // TODO: Implement
              backgroundColor: primaryColor,
              child: Text('View all students', style: bodyText),
            ),
          ),
          SizedBox(
            width: 100,
            child: FloatingActionButton(
              heroTag: 'license',
              onPressed: () {
                showAboutDialog(context: context, applicationVersion: "0.0.0");
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
