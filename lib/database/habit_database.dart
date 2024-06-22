import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../models/app_settings.dart';
import '../models/habit.dart';

class HabitDatabase extends ChangeNotifier {
  static late Isar isar;
  final List<Habit> currentHabits = [];

  /// initialize database
  static Future<void> initialize() async {
    final dir = await getApplicationSupportDirectory();
    isar = await Isar.open(
      [HabitSchema, AppSettingsSchema],
      directory: dir.path,
    );
  }

  /// save the first date of app launch (we will use it in heat map)
  Future<void> saveFirstLaunchDate() async {
    final existingSettings = await isar.appSettings.where().findFirst();

    /// if no date is saved, save the current date as app's first launch date
    if (existingSettings == null) {
      final settings = AppSettings()..firstLaunchDate = DateTime.now();
      isar.writeTxn(() => isar.appSettings.put(settings));
    }
  }

  /// get app's first launch date
  Future<DateTime?> getFirstLaunchDate() async {
    final settings = await isar.appSettings.where().findFirst();
    return settings?.firstLaunchDate;
  }

  /// create a new habit
  Future<void> addHabit(String habitName) async {
    /// create a [newHabit]
    final newHabit = Habit()..name = habitName;

    /// save habit to database
    await isar.writeTxn(() => isar.habits.put(newHabit));
    readHabits();
  }

  /// read all habits from the database
  Future<void> readHabits() async {
    List<Habit> fetchedHabits = await isar.habits.where().findAll();
    currentHabits.clear();
    currentHabits.addAll(fetchedHabits);
    notifyListeners();
  }

  /// Update - check habit on and off
  Future<void> updateHabitCompletion(int id, bool isCompleted) async {
    /// find specific habit
    final habit = await isar.habits.get(id);

    if (habit != null) {
      await isar.writeTxn(() async {
        final today = DateTime.now();
        if (isCompleted && !habit.completedDays.contains(DateTime.now())) {
          /// add the current date if it's not already in the list
          habit.completedDays.add(
            DateTime(
              today.year,
              today.month,
              today.day,
            ),
          );
        } else {
          habit.completedDays.removeWhere(
            (date) =>
                date.year == today.year &&
                date.month == today.month &&
                date.day == today.day,
          );
        }
        await isar.habits.put(habit);
      });
    }
    readHabits();
  }

  /// Update - habit name
  Future<void> updateHabitName(int id, String name) async {
    final habit = await isar.habits.get(id);

    if (habit != null) {
      habit.name = name;
      await isar.writeTxn(
        () async => await isar.habits.put(habit),
      );
      readHabits();
    }
  }

  Future<void> deleteHabit(int id) async {
    await isar.writeTxn(() async => await isar.habits.delete(id));
    readHabits();
  }
}
