import 'package:flutter/material.dart';

class SlideLeft extends PageRouteBuilder {
  final Widget page;
  SlideLeft({required this.page})
      : super(
            pageBuilder: (context, animation, secondaryAnimation) => page,
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    SlideTransition(
                      position: Tween(begin: const Offset(1, 0), end: Offset.zero)
                          .animate(animation),
                      child: child,
                    ),
            transitionDuration: const Duration(milliseconds: 300));
}

class SizeRoute extends PageRouteBuilder {
  final Widget page;
  SizeRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              Align(
            child: SizeTransition(
              sizeFactor: animation,
              child: child,
            ),
          ),
        );
}