import 'package:isar/isar.dart';

part 'habit.g.dart';

@Collection()
class Habit {
  Id id = Isar.autoIncrement;
  late String name;
  List<DateTime> completedDays = [
    /// stores days in format DateTime(year, month, day)
  ];
}
