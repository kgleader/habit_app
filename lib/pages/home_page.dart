import 'package:flutter/material.dart';
import 'package:habit_app/components/my_drawer.dart';
import 'package:habit_app/database/habit_datebase.dart';
import 'package:habit_app/models/habit.dart';
import 'package:habit_app/util/habit_util.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    // read existing habits from db
    Provider.of<HabitDatebase>(context, listen: false).readHabits();

    super.initState();
  }

  // text controller
  final TextEditingController _textController = TextEditingController();

  // createNewHabit method
  void createNewHabit() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            content: TextField(
              controller: _textController,
              decoration: const InputDecoration(hintText: 'Enter habit name'),
            ),
            actions: [
              // save button
              MaterialButton(
                onPressed: () {
                  // get new habit name
                  String newHabitName = _textController.text;

                  // save to db
                  context.read<HabitDatebase>().addHabit(newHabitName);

                  // pop box
                  Navigator.pop(context);

                  // clear controller
                  _textController.clear();
                },
                child: const Text('Save'),
              ),

              // cancel button
              MaterialButton(
                onPressed: () {
                  // pop box
                  Navigator.pop(context);

                  // clear controller
                  _textController.clear();
                },
                child: const Text('Cancel'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(),
      drawer: const MyDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: createNewHabit,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        child: const Icon(Icons.add),
      ),
      body: _buildHabitList(),
    );
  }

  // build habit list
  Widget _buildHabitList() {
    // habit db
    final habitDatabase = context.watch<HabitDatebase>();

    // current habits
    List<Habit> currentHabits = habitDatabase.currentHabits;

    // return list of habits UI
    return ListView.builder(
      itemCount: currentHabits.length,
      itemBuilder: (context, index) {
        // get each individual habit
        final habit = currentHabits[index];

        // check if habit is completed today
        bool isCompletedToday = isHabitCompletedToday(habit.completedDays);

        // return habit title UI
        return ListTile(title: Text(habit.name));
      },
    );
  }
}
