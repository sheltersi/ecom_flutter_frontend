import 'package:flutter/material.dart';

/// Text rendered with a multi-color linear gradient via [ShaderMask].
/// Defaults to the app's signature amber-to-yellow gradient.
class GradientText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final List<Color> colors;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const GradientText(
    this.text, {
    super.key,
    this.style,
    this.colors = const [Colors.amber, Colors.yellow],
    this.begin = Alignment.centerLeft,
    this.end = Alignment.centerRight,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: colors,
        begin: begin,
        end: end,
      ).createShader(bounds),
      child: Text(
        text,
        style: style?.copyWith(color: Colors.white) ??
            const TextStyle(color: Colors.white),
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      ),
    );
  }
}
