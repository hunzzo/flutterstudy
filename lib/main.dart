import 'package:flutter/material.dart';

import 'pages/workout_home_page.dart';

void main() {
  runApp(WorkoutApp());
}

class WorkoutApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '운동 기록',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: WorkoutHomePage(),
    );
  }
}
