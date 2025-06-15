import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutterstudy/providers/workout_data.dart';
import 'package:flutterstudy/models/workout.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('addWorkout stores a workout record', () async {
    final data = WorkoutData();
    final date = DateTime(2024, 1, 1);
    final record =
        WorkoutRecord('Bench Test', '3set', '80kg x 10', MuscleGroup.chest, 8);

    data.addWorkout(date, record);

    final records = data.workoutsForDay(date);
    expect(records.length, 1);
    expect(records.first.exercise, 'Bench Test');
  });

  test('deleteWorkout removes the workout record', () async {
    final data = WorkoutData();
    final date = DateTime(2024, 1, 1);
    final record =
        WorkoutRecord('Delete Test', '3set', '100kg x 5', MuscleGroup.back, 7);

    data.addWorkout(date, record);
    expect(data.workoutsForDay(date).isNotEmpty, true);

    data.deleteWorkout(date, 0);
    expect(data.workoutsForDay(date).isEmpty, true);
  });
}
