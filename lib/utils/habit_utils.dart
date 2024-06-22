import '../models/habit.dart';

bool isCompletedToday(List<DateTime> completedDays) {
  final today = DateTime.now();
  return completedDays.any(
    (day) =>
        day.year == today.year &&
        day.month == today.month &&
        day.day == today.day,
  );
}

// prepare heatmap data set
Map<DateTime, int> prepareHeatmapDataset(List<Habit> habits) {
  Map<DateTime, int> dataset = {};

  for (final habit in habits) {
    for (final date in habit.completedDays) {
      final normalizedDate = DateTime(date.year, date.month, date.day);

      if (dataset.containsKey(normalizedDate)) {
        dataset[normalizedDate] = dataset[normalizedDate]! + 1;
      } else {
        dataset[normalizedDate] = 1;
      }
    }
  }
  return dataset;
}
