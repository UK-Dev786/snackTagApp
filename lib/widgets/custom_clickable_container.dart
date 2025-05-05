import 'package:flutter/material.dart';

class SimpleContainerWidget extends StatelessWidget {
  final double height;
  final double width;
  final Widget? child;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;
  final BorderRadiusGeometry borderRadius;
  final BoxShadow boxShadow;

  const SimpleContainerWidget({
    super.key,
    this.height = 56,
    this.width = double.infinity,
    this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
    this.backgroundColor = Colors.white,
    this.borderRadius = const BorderRadius.all(Radius.circular(100)),
    this.boxShadow = const BoxShadow(
      color: Colors.black26,
      blurRadius: 6,
      offset: Offset(0, 3),
    ), required String hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: backgroundColor,
        boxShadow: [boxShadow],
      ),
      child: Center(child: child), // Use the child widget to customize content
    );
  }
}
