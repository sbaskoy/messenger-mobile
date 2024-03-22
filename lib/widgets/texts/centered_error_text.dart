import 'package:flutter/material.dart';

class CenteredErrorText extends StatelessWidget {
  final String text;
  const CenteredErrorText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
      ),
    );
  }
}
