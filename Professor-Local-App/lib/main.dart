import 'package:flutter/material.dart';
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
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Your Classes'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => Home();
}

class Home extends State<MyHomePage> {
  // Theme
  static const TextStyle bodyText20 = TextStyle(
    fontSize: 20,
    color: Colors.black,
  );

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

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // First Column
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Class 1 information', style: bodyText20),
                const SizedBox(width: 20), // Spacing
                const SizedBox(
                  width: 150,
                  child: FloatingActionButton(
                    heroTag: 'class1Attendance',
                    onPressed: null,
                    child: Text('Take attendance'),
                  ),
                ),
                const SizedBox(width: 20), // Spacing
                const SizedBox(
                  width: 150,
                  child: FloatingActionButton(
                    heroTag: 'class1EditData',
                    onPressed: null,
                    child: Text('View and edit data'),
                  ),
                ),
                const SizedBox(width: 20), // Spacing
                SizedBox(
                  width: 150,
                  child: FloatingActionButton(
                    heroTag: 'class1EditInfo',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ClassInformation()),
                      );
                    },
                    child: const Text('Edit class information'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20), // Spacing
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Class 2 information', style: bodyText20),
                SizedBox(width: 20), // Spacing
                SizedBox(
                  width: 150,
                  child: FloatingActionButton(
                    heroTag: 'class2Attendance',
                    onPressed: null,
                    child: Text('Take attendance'),
                  ),
                ),
                SizedBox(width: 20), // Spacing
                SizedBox(
                  width: 150,
                  child: FloatingActionButton(
                    heroTag: 'class2EditData',
                    onPressed: null,
                    child: Text('View and edit data'),
                  ),
                ),
                SizedBox(width: 20), // Spacing
                SizedBox(
                  width: 150,
                  child: FloatingActionButton(
                    heroTag: 'class2EditInfo',
                    onPressed: null,
                    child: Text('Edit class information'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20), // Spacing
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Class 3 information', style: bodyText20),
                SizedBox(width: 20), // Spacing
                SizedBox(
                  width: 150,
                  child: FloatingActionButton(
                    heroTag: 'class3Attendance',
                    onPressed: null,
                    child: Text('Take attendance'),
                  ),
                ),
                SizedBox(width: 20), // Spacing
                SizedBox(
                  width: 150,
                  child: FloatingActionButton(
                    heroTag: 'class3EditData',
                    onPressed: null,
                    child: Text('View and edit data'),
                  ),
                ),
                SizedBox(width: 20), // Spacing
                SizedBox(
                  width: 150,
                  child: FloatingActionButton(
                    heroTag: 'class3EditInfo',
                    onPressed: null,
                    child: Text('Edit class information'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20), // Spacing
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Class 4 information', style: bodyText20),
                SizedBox(width: 20), // Spacing
                SizedBox(
                  width: 150,
                  child: FloatingActionButton(
                    heroTag: 'class4Attendance',
                    onPressed: null,
                    child: Text('Take attendance'),
                  ),
                ),
                SizedBox(width: 20), // Spacing
                SizedBox(
                  width: 150,
                  child: FloatingActionButton(
                    heroTag: 'class4EditData',
                    onPressed: null,
                    child: Text('View and edit data'),
                  ),
                ),
                SizedBox(width: 20), // Spacing
                SizedBox(
                  width: 150,
                  child: FloatingActionButton(
                    heroTag: 'class4EditInfo',
                    onPressed: null,
                    child: Text('Edit class information'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20), // Spacing
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Class 5 information', style: bodyText20),
                SizedBox(width: 20), // Spacing
                SizedBox(
                  width: 150,
                  child: FloatingActionButton(
                    heroTag: 'class5Attendance',
                    onPressed: null,
                    child: Text('Take attendance'),
                  ),
                ),
                SizedBox(width: 20), // Spacing
                SizedBox(
                  width: 150,
                  child: FloatingActionButton(
                    heroTag: 'class5EditData',
                    onPressed: null,
                    child: Text('View and edit data'),
                  ),
                ),
                SizedBox(width: 20), // Spacing
                SizedBox(
                  width: 150,
                  child: FloatingActionButton(
                    heroTag: 'class5EditInfo',
                    onPressed: null,
                    child: Text('Edit class information'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20), // Spacing
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Class 6 information', style: bodyText20),
                SizedBox(width: 20), // Spacing
                SizedBox(
                  width: 150,
                  child: FloatingActionButton(
                    heroTag: 'class6Attendance',
                    onPressed: null,
                    child: Text('Take attendance'),
                  ),
                ),
                SizedBox(width: 20), // Spacing
                SizedBox(
                  width: 150,
                  child: FloatingActionButton(
                    heroTag: 'class6EditData',
                    onPressed: null,
                    child: Text('View and edit data'),
                  ),
                ),
                SizedBox(width: 20), // Spacing
                SizedBox(
                  width: 150,
                  child: FloatingActionButton(
                    heroTag: 'class6EditInfo',
                    onPressed: null,
                    child: Text('Edit class information'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton(
            heroTag: 'addClass',
            onPressed: _incrementCounter,
            tooltip: 'Add a class',
            child: const Icon(Icons.add),
          ),
          const FloatingActionButton(
            heroTag: 'removeClass',
            onPressed: null,
            tooltip: 'Remove a class',
            child: Icon(Icons.remove),
          ),
          const SizedBox(
            width: 150,
            child: FloatingActionButton(
              heroTag: 'viewAllStudents',
              onPressed: null,
              child: Text('View all students'),
            ),
          ),
        ],
      ),
    );
  }
}
