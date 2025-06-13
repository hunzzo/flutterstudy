import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'pages/workout_home_page.dart';
import 'providers/workout_data.dart';

void main() {
  runApp(const WorkoutApp());
}

class WorkoutApp extends StatelessWidget {
  const WorkoutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WorkoutData(),
      child: MaterialApp(
        title: '운동 기록',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: WorkoutHomePage(),
      ),
    );
  }
}
