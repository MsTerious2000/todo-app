import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/firebase_options.dart';
import 'package:todo_app/screens/authentication/login.dart';
import 'package:todo_app/widgets/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ToDoApp());
}

class ToDoApp extends StatefulWidget {
  const ToDoApp({super.key});

  @override
  State<ToDoApp> createState() => _ToDoAppState();
}

class _ToDoAppState extends State<ToDoApp> {
  @override
  Widget build(BuildContext context) => MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          appBarTheme:
              AppBarTheme(backgroundColor: darkBlue, foregroundColor: white),
          colorSchemeSeed: darkBlue,
          elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                  backgroundColor: darkBlue, foregroundColor: white)),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
              backgroundColor: darkBlue, foregroundColor: white),
          fontFamily: 'Nunito'),
      home: const LoginScreen());
}
