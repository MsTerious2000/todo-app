import 'package:flutter/material.dart';
import 'package:todo_app/widgets/texts.dart';

Widget streamError(AsyncSnapshot snapshot) =>
    Center(child: text(snapshot.error.toString()));
Widget streamLoading() => const Center(child: CircularProgressIndicator());
Widget streamEmpty(String message) => Center(child: text(message));
