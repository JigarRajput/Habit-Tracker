bool isCompletedToday(List<DateTime> completedDays) {
  final today = DateTime.now();
  return completedDays.any(
    (day) =>
        day.year == today.year &&
        day.month == today.month &&
        day.day == today.day,
  );
}
