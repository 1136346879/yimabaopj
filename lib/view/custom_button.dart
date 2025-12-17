import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final Widget? child;
  final Function()? onPress;
  final double? width;
  final double? height;
  final EdgeInsets padding;
  final BorderSide? borderSide;
  final double borderRadiusValue;
  final MaterialColor? color;
  CustomButton({
    Key? key,
    required  this.onPress,
    this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.fromLTRB(16, 5, 16, 5),
    this.borderSide,
    this.borderRadiusValue = 5,
    this.color,

  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(borderRadiusValue),
      color: color,
      child: InkWell(
        borderRadius: BorderRadius.circular(borderRadiusValue),
        onTap: onPress,
        child: Container(
          decoration: borderSide == null ? null : BoxDecoration(
              border: Border.fromBorderSide(borderSide!),
              borderRadius: BorderRadius.circular(borderRadiusValue)
          ),
          padding: padding,
          width: width,
          height: height,
          child: Center(child: child),
        ),
      ),
    );
  }
}
