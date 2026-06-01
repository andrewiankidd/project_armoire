import 'package:flutter/material.dart';

extension BuildContextExtensions on BuildContext {
  Future goTo(Widget page) {
    return Navigator.pushAndRemoveUntil(
      this,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return Container(
            color: Colors.black,
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
      ),
      (Route<dynamic> route) => false,
    );
  }
}

extension CapExtension on String {
  String get inCaps => this.length > 0 ?'${this[0].toUpperCase()}${this.substring(1)}':'';
  String get allInCaps => this.toUpperCase();
  String get capitalizeFirstofEach => this.replaceAll(RegExp(' +'), ' ').split(" ").map((str) => str.inCaps).join(" ");
}
