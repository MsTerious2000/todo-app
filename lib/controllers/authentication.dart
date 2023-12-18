import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/widgets/dialogs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseFirestore firebaseInstance = FirebaseFirestore.instance;
CollectionReference usersCollection = firebaseInstance.collection('users');
CollectionReference tasksCollection = firebaseInstance.collection('tasks');

class UserController {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  Future<User?> createUserWithEmailAndPassword(
      context, String email, String password) async {
    try {
      final UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      return userCredential.user!;
    } catch (e) {
      if (kDebugMode) print('ERROR: $e');
      showDialog(
          context: context,
          builder: (_) => errorDialog(context, 'Login Failed', '$e'));
      return null;
    }
  }

  Future<User?> signInWithEmailAndPassword(
      context, String email, String password) async {
    try {
      final UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      return userCredential.user!;
    } catch (e) {
      if (kDebugMode) print('ERROR: $e');
      showDialog(
          context: context,
          builder: (_) => errorDialog(context, 'Login Failed', '$e'));
      return null;
    }
  }
}
