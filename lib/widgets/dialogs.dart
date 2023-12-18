import 'package:flutter/material.dart';
import 'package:todo_app/widgets/colors.dart';
import 'package:todo_app/widgets/texts.dart';

Widget errorDialog(context, String title, String message) => AlertDialog(
        title: text(title, weight: bold),
        content: text(message, color: darkRed),
        actions: [
          ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: text('OK', weight: bold))
        ]);

Widget successDialog(context, String title, String message) => AlertDialog(
        title: text(title, weight: bold),
        content: text(message),
        actions: [
          ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: text('OK', weight: bold))
        ]);
