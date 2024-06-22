import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../database/habit_database.dart';
import '../../models/habit.dart';
import '../../utils/habit_utils.dart';
import '../../widgets/habit_drawer.dart';
import '../../widgets/habit_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController textController = TextEditingController();

  void createNewHabit() {
    showDialogBox(
        text: null,
        onSave: () async {
          final habit = textController.text;
          context.read<HabitDatabase>().addHabit(habit);
          Navigator.of(context).pop();
          textController.clear();
        });
  }

  void checkHabit(Habit habit, bool? val) {
    if (val != null) {
      context.read<HabitDatabase>().updateHabitCompletion(habit.id, val);
    }
  }

  void handleDismiss(int id) => context.read<HabitDatabase>().deleteHabit(id);

  void showDialogBox({String? text, void Function()? onSave}) {
    if (text != null) {
      textController.text = text;
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(
          controller: textController,
        ),
        actions: [
          MaterialButton(
            onPressed: () {
              Navigator.of(context).pop();
              textController.clear();
            },
            child: const Text("Cancel"),
          ),
          MaterialButton(
            onPressed: onSave,
            child: const Text("Save"),
          )
        ],
      ),
    );
  }

  void handleEdit(Habit habit) {
    showDialogBox(
      text: habit.name,
      onSave: () async {
        context.read<HabitDatabase>().updateHabitName(
              habit.id,
              textController.text,
            );
        Navigator.of(context).pop();
      },
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HabitDatabase>(context, listen: false).readHabits();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final habitsDatabase = context.watch<HabitDatabase>();
    List<Habit> habits = habitsDatabase.currentHabits;

    return Scaffold(
      appBar: AppBar(),
      drawer: const HabitDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: createNewHabit,
        backgroundColor: themeData.colorScheme.tertiary,
        child: Icon(
          Icons.add,
          color: themeData.colorScheme.inversePrimary,
        ),
      ),
      body: ListView.builder(
        itemCount: habits.length,
        itemBuilder: (context, index) => HabitTile(
            key: Key(index.toString()),
            title: habits[index].name,
            isCompleted: isCompletedToday(habits[index].completedDays),
            onChanged: (val) => checkHabit(habits[index], val),
            index: index,
            onDismiss: (_) => handleDismiss(habits[index].id),
            onEdit: () => handleEdit(habits[index])),
      ),
    );
  }
}
