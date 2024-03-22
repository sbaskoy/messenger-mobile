import 'package:flutter/material.dart';

class BodyLargeText extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final TextAlign textAlign;
  final Color? color;
  final TextOverflow? textOverflow;
  final int? maxLines;
  const BodyLargeText(
    this.text, {
    super.key,
    this.fontSize = 30,
    this.fontWeight = FontWeight.w700,
    this.textAlign = TextAlign.center,
    this.color,
    this.textOverflow,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: color ?? Theme.of(context).textTheme.bodyLarge!.color,
          ),
      overflow: textOverflow,
      textAlign: textAlign,
      maxLines: maxLines,
    );
  }
}

class BodyLargeTextDisable extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final TextAlign textAlign;
  final Color? color;
  final TextOverflow? textOverflow;
  final int? maxLines;
  const BodyLargeTextDisable(
    this.text, {
    super.key,
    this.fontSize = 16,
    this.fontWeight = FontWeight.w400,
    this.textAlign = TextAlign.center,
    this.color,
    this.textOverflow,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            fontSize: fontSize,
            color: color ?? Theme.of(context).disabledColor,
            fontWeight: fontWeight,
            height: 1.6,
          ),
      textAlign: textAlign,
      overflow: textOverflow,
      maxLines: maxLines,
    );
  }
}

class ExpandableText extends StatefulWidget {
  final Widget child;
  const ExpandableText({super.key, required this.child});

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool isExpanded = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ConstrainedBox(
          constraints: isExpanded ? const BoxConstraints() : const BoxConstraints(maxHeight: 50.0),
          child: widget.child,
        ),
        TextButton(
          child: BodyLargeTextDisable(
            isExpanded ? "Daha az" : "Daha fazla",
            fontSize: 12,
          ),
          onPressed: () => setState(() => isExpanded = !isExpanded),
        )
      ],
    );
  }
}
