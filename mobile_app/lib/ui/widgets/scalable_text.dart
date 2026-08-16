import 'package:flutter/material.dart';

class ScalableText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const ScalableText(
    this.text, {
    Key? key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Scales text sizes gracefully based on OS font sizes (Dynamic Text support)
    final double textScaleFactor = MediaQuery.textScaleFactorOf(context);
    
    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: style?.copyWith(
        fontSize: (style?.fontSize ?? 14.0) * (textScaleFactor > 2.0 ? 2.0 : textScaleFactor),
      ),
    );
  }
}
