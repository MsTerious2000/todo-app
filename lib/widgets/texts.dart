import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

TextAlign taCenter = TextAlign.center;
TextAlign taLeft = TextAlign.left;
TextAlign taRight = TextAlign.right;

FontStyle italic = FontStyle.italic;
FontWeight bold = FontWeight.bold;

Widget text(String text,
        {TextAlign? textAlign,
        Color? color,
        double? size,
        FontStyle? style,
        FontWeight? weight}) =>
    Text(text,
        textAlign: textAlign,
        style: TextStyle(
            color: color,
            fontSize: size,
            fontStyle: style,
            fontWeight: weight));

String dateTimeToString(Timestamp timestamp) =>
    DateFormat('MMM dd, yyyy - hh:mm a').format(timestamp.toDate()).toString();
String generateToken() => String.fromCharCodes(
    List.generate(100, (index) => Random().nextInt(33) + 89));
DateTime getDateNow() => DateTime.now();
String getDate() => DateFormat('yyyy-MM-dd').format(getDateNow());
String generateID() => DateFormat('yyMMddhhmmss').format(getDateNow());
