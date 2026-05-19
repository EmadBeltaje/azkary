import 'package:azkary/azkary.dart';
import 'package:flutter/material.dart';

void snackError(BuildContext context, Object e) {
  final msg = e is AzkaryException ? e.message : '$e';
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
}
