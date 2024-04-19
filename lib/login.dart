import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:professor_app/database_helper.dart';
import 'package:professor_app/main.dart';
import 'package:path_provider/path_provider.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  // Theme
  static const TextStyle bodyText = TextStyle(
    fontSize: 20,
    color: Colors.black,
  );

  static const Color primaryColor = Color.fromARGB(255, 255, 100, 100);

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

  /// Test the user's credentials to make sure they are correct.
  ///
  /// [ip] is the IP address of the database.
  /// [name] is the name of the database.
  /// [portString] is the port number of the database.
  /// [username] is the username of the database.
  /// [password] is the password of the database.
  /// Returns true if the credentials are correct, false otherwise.
  Future<bool> testCredentials(String ip, String name, String portString,
      String username, String password) async {
    int port = int.parse(portString);
    DatabaseHelper dbHelper = DatabaseHelper();
    return await dbHelper.correctCredentials(
        ip, name, port, username, password);
  }

  /// Get the path of the application's documents directory.
  ///
  /// Return the path of the application's documents directory.
  Future<String> getPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  /// Build the login page.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getPath(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // While waiting, display a loading indicator.
            return Scaffold(
                appBar: AppBar(
                  backgroundColor: primaryColor,
                  title: const Text('Please wait'),
                ),
                body: const Center(child: CircularProgressIndicator()),
                bottomNavigationBar: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: 100,
                        child: FloatingActionButton(
                          heroTag: 'license',
                          onPressed: () {
                            _showAboutDialog(
                                context: context, applicationVersion: '1.0.0');
                          },
                          backgroundColor: primaryColor,
                          child: const Text('About', style: bodyText),
                        ),
                      )
                    ]));
          } else if (snapshot.hasError || snapshot.data!.isEmpty) {
            return Scaffold(
                appBar: AppBar(
                  backgroundColor: primaryColor,
                  title: const Text('Error. Could not find the path.'),
                ),
                body: const Center(child: CircularProgressIndicator()),
                bottomNavigationBar: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: 100,
                        child: FloatingActionButton(
                          heroTag: 'license',
                          onPressed: () {
                            _showAboutDialog(
                                context: context, applicationVersion: '1.0.0');
                          },
                          backgroundColor: primaryColor,
                          child: const Text('About', style: bodyText),
                        ),
                      )
                    ]));
          } else {
            // Get the credentials from the files.
            Directory('${snapshot.data}/config').createSync();
            String ip = File('${snapshot.data}/config/ip.txt').existsSync()
                ? File('${snapshot.data}/config/ip.txt').readAsStringSync()
                : '';
            String database =
                File('${snapshot.data}/config/database.txt').existsSync()
                    ? File('${snapshot.data}/config/database.txt')
                        .readAsStringSync()
                    : '';
            String port = File('${snapshot.data}/config/port.txt').existsSync()
                ? File('${snapshot.data}/config/port.txt').readAsStringSync()
                : '';
            String username =
                File('${snapshot.data}/config/username.txt').existsSync()
                    ? File('${snapshot.data}/config/username.txt')
                        .readAsStringSync()
                    : '';
            String password =
                File('${snapshot.data}/config/password.txt').existsSync()
                    ? File('${snapshot.data}/config/password.txt')
                        .readAsStringSync()
                    : '';
            TextEditingController ipTextField = TextEditingController(text: ip);
            TextEditingController nameTextField =
                TextEditingController(text: database);
            TextEditingController portTextField =
                TextEditingController(text: port);
            TextEditingController usernameTextField =
                TextEditingController(text: username);
            TextEditingController passwordTextField =
                TextEditingController(text: password);
            return Scaffold(
                appBar: AppBar(
                  backgroundColor: primaryColor,
                  title: const Center(
                    child: Text('Login to the database'),
                  ),
                ),
                body: SingleChildScrollView(
                    child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        // IP address field.
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        child: SizedBox(
                          width: 350,
                          child: TextField(
                            controller: ipTextField,
                            maxLength: 39,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'IP address',
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        // Name text field.
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        child: SizedBox(
                          width: 350,
                          child: TextField(
                            controller: nameTextField,
                            maxLength: 100,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Name',
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        // Port text field.
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        child: SizedBox(
                          width: 100,
                          child: TextField(
                            controller: portTextField,
                            maxLength: 5,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Port',
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        // Username text field.
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        child: SizedBox(
                          width: 350,
                          child: TextField(
                            controller: usernameTextField,
                            maxLength: 100,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Username',
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        // Password text field.
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        child: SizedBox(
                          width: 350,
                          child: TextField(
                            obscureText: true,
                            controller: passwordTextField,
                            maxLength: 100,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Password',
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        // Login button.
                        height: 75,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: OutlinedButton(
                              onPressed: () async {
                                bool validCredentials = await testCredentials(
                                    ipTextField.text,
                                    nameTextField.text,
                                    portTextField.text,
                                    usernameTextField.text,
                                    passwordTextField.text);
                                if (validCredentials) {
                                  Navigator.push(
                                    // ignore: use_build_context_synchronously
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const MyHomePage()),
                                  );
                                } else {
                                  // If input is invalid show an error dialog.
                                  showDialog(
                                      // ignore: use_build_context_synchronously
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: const Text(
                                              'Invalid credentials.'),
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
                              child: const Text('Login', style: bodyText)),
                        ),
                      ),
                    ],
                  ),
                )),
                bottomNavigationBar: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: 100,
                      child: FloatingActionButton(
                        heroTag: 'license',
                        onPressed: () {
                          _showAboutDialog(
                              context: context, applicationVersion: '1.0.0');
                        },
                        backgroundColor: primaryColor,
                        child: const Text('About', style: bodyText),
                      ),
                    ),
                  ],
                ));
          }
        });
  }
}
