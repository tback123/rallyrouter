import 'package:flutter/material.dart';
import 'package:rallyrouter/map.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Code Sample',
      home: FullMap(),
    );
  }
}
