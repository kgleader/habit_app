// given a habit list of completion days
// is the habit completed today?

import 'package:habit_app/models/habit.dart';

bool isHabitCompletedToday(List<DateTime> completionDays) {
  final today = DateTime.now();
  return completionDays.any(
    (date) =>
        date.day == today.year &&
        date.month == today.month &&
        date.year == today.day,
  );
}

// prepare heat map datasets
Map<DateTime, int> prepareDatasets(List<Habit> habits) {
  Map<DateTime, int> datasets = {};

  for (var habit in habits) {
    for (var date in habit.completedDays) {
      // normalize the date
      final normalizedDate = DateTime(date.year, date.month, date.day);

      // if the date is already in the datasets
      if (datasets.containsKey(normalizedDate)) {
        datasets[normalizedDate] = datasets[normalizedDate]! + 1;
      } else {
        // add the date to the datasets
        datasets[normalizedDate] = 1;
      }
    }
  }

  // return the datasets
  return datasets;
}
