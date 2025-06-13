import 'package:flutter_test/flutter_test.dart';
import 'package:flutterstudy/main.dart';
import 'package:flutterstudy/pages/workout_home_page.dart';
import 'package:flutterstudy/models/workout.dart';

void main() {
  testWidgets('addWorkout adds a workout record', (WidgetTester tester) async {
    await tester.pumpWidget(WorkoutApp());

    final dynamic state = tester.state(find.byType(WorkoutHomePage));
    state._addWorkout(
      'Bench Test',
      '3set',
      '80kg x 10',
      MuscleGroup.chest,
      8,
    );
    await tester.pump();

    expect(find.text('Bench Test'), findsOneWidget);
  });

  testWidgets('deleteWorkout removes a workout record', (WidgetTester tester) async {
    await tester.pumpWidget(WorkoutApp());

    final dynamic state = tester.state(find.byType(WorkoutHomePage));
    state._addWorkout(
      'Delete Test',
      '3set',
      '100kg x 5',
      MuscleGroup.back,
      7,
    );
    await tester.pump();
    expect(find.text('Delete Test'), findsOneWidget);

    state._deleteWorkout(0);
    await tester.pump();

    expect(find.text('Delete Test'), findsNothing);
  });
}
