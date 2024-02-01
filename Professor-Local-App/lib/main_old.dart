import 'package:flutter/material.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
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
    // This method is rerun every time setState is called
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
      body: GridView(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4, // Number of columns in the grid
        ),
        children: [
          const Text('Class 1 information', style: bodyText20),
          const SizedBox(
            width: 150,
            child: FloatingActionButton(
              heroTag: 'class1Attendance',
              onPressed: null,
              child: Text('Take attendance'),
            ),
          ),
          const SizedBox(
            width: 150,
            child: FloatingActionButton(
              heroTag: 'class1EditData',
              onPressed: null,
              child: Text('View and edit data'),
            ),
          ),
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
          const Text('Class 2 information', style: bodyText20),
          const SizedBox(
            width: 150,
            child: FloatingActionButton(
              heroTag: 'class2Attendance',
              onPressed: null,
              child: Text('Take attendance'),
            ),
          ),
          const SizedBox(
            width: 150,
            child: FloatingActionButton(
              heroTag: 'class2EditData',
              onPressed: null,
              child: Text('View and edit data'),
            ),
          ),
          const SizedBox(
            width: 150,
            child: FloatingActionButton(
              heroTag: 'class2EditInfo',
              onPressed: null,
              child: Text('Edit class information'),
            ),
          ),
          const Text('Class 3 information', style: bodyText20),
          const SizedBox(
            width: 150,
            child: FloatingActionButton(
              heroTag: 'class3Attendance',
              onPressed: null,
              child: Text('Take attendance'),
            ),
          ),
          const SizedBox(
            width: 150,
            child: FloatingActionButton(
              heroTag: 'class3EditData',
              onPressed: null,
              child: Text('View and edit data'),
            ),
          ),
          const SizedBox(
            width: 150,
            child: FloatingActionButton(
              heroTag: 'class3EditInfo',
              onPressed: null,
              child: Text('Edit class information'),
            ),
          ),
          const Text('Class 4 information', style: bodyText20),
          const SizedBox(
            width: 150,
            child: FloatingActionButton(
              heroTag: 'class4Attendance',
              onPressed: null,
              child: Text('Take attendance'),
            ),
          ),
          const SizedBox(
            width: 150,
            child: FloatingActionButton(
              heroTag: 'class4EditData',
              onPressed: null,
              child: Text('View and edit data'),
            ),
          ),
          const SizedBox(
            width: 150,
            child: FloatingActionButton(
              heroTag: 'class4EditInfo',
              onPressed: null,
              child: Text('Edit class information'),
            ),
          ),
          const Text('Class 5 information', style: bodyText20),
          const SizedBox(
            width: 150,
            child: FloatingActionButton(
              heroTag: 'class5Attendance',
              onPressed: null,
              child: Text('Take attendance'),
            ),
          ),
          const SizedBox(
            width: 150,
            child: FloatingActionButton(
              heroTag: 'class5EditData',
              onPressed: null,
              child: Text('View and edit data'),
            ),
          ),
          const SizedBox(
            width: 150,
            child: FloatingActionButton(
              heroTag: 'class5EditInfo',
              onPressed: null,
              child: Text('Edit class information'),
            ),
          ),
          const Text('Class 6 information', style: bodyText20),
          const SizedBox(
            width: 150,
            child: FloatingActionButton(
              heroTag: 'class6Attendance',
              onPressed: null,
              child: Text('Take attendance'),
            ),
          ),
          const SizedBox(
            width: 150,
            child: FloatingActionButton(
              heroTag: 'class6EditData',
              onPressed: null,
              child: Text('View and edit data'),
            ),
          ),
          const SizedBox(
            width: 150,
            child: FloatingActionButton(
              heroTag: 'class6EditInfo',
              onPressed: null,
              child: Text('Edit class information'),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Row(
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
