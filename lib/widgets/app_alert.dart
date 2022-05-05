import 'package:flutter/material.dart';

class AppAlert extends StatelessWidget {
  final List<Widget> buttons;
  final String title;
  final String description;

  const AppAlert(
      {Key? key,
      required this.buttons,
      required this.title,
      required this.description})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(title),
        Text(description),
        Row(
          mainAxisSize: MainAxisSize.max,
          children: buttons,
        )
      ],
    );
  }
}
