import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:todo_app/controllers/authentication.dart';
import 'package:todo_app/screens/tasks.dart';
import 'package:todo_app/widgets/colors.dart';
import 'package:todo_app/widgets/dialogs.dart';
import 'package:todo_app/widgets/texts.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final session = const FlutterSecureStorage();
  bool isHiddenPassword = true;
  @override
  Widget build(BuildContext context) => Scaffold(
          body: AlertDialog(
              scrollable: true,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: darkBlue, width: 3)),
              titlePadding: EdgeInsets.zero,
              title: Card(
                  color: darkBlue,
                  margin: EdgeInsets.zero,
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10))),
                  child: ListTile(
                      title: text('TO-DO APP',
                          color: white,
                          size: 15,
                          weight: bold,
                          textAlign: taCenter))),
              content: Column(children: [
                TextField(
                    controller: _email,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(), labelText: 'EMAIL')),
                const SizedBox(height: 10),
                TextField(
                    controller: _password,
                    obscureText: isHiddenPassword,
                    decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: 'PASSWORD',
                        suffixIcon: IconButton(
                            onPressed: () => isHiddenPassword == true
                                ? setState(() => isHiddenPassword = false)
                                : setState(() => isHiddenPassword = true),
                            icon: Icon(isHiddenPassword == true
                                ? Icons.visibility
                                : Icons.visibility_off))))
              ]),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
            Column(children: [
              ElevatedButton.icon(
                  onPressed: () => register(context),
                  icon: const Icon(Icons.app_registration),
                  label: text('REGISTER', size: 15, weight: bold)),
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: text('LOGIN INSTEAD', size: 15, weight: bold))
            ])
          ]));

  void register(context) async {
    if (_email.text.isEmpty || _password.text.isEmpty) {
      showDialog(
          context: context,
          builder: (_) => errorDialog(
              context, 'Registration failed', 'Invalid email or password!'));
    } else {
      User? user = await UserController()
          .createUserWithEmailAndPassword(context, _email.text, _password.text);
      if (user != null) {
        await session.write(key: 'session', value: generateToken()).then(
            (value) => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => TasksScreen(user: user)),
                (route) => false));
      }
    }
  }
}
