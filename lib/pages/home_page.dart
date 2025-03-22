import 'package:flutter/material.dart';
import 'package:habit_app/components/my_drawer.dart';
import 'package:habit_app/components/my_habit_tile.dart';
import 'package:habit_app/components/my_heat_map.dart';
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
  // TO DO: implement initState
  @override
  void initState() {
    //read existing habits
    Provider.of<HabitDatebase>(context, listen: false).readHabits();

    super.initState();
    // TO DO: implement initState
  }

  // text controller
  final TextEditingController textController = TextEditingController();

  // create new habit
  void createNewHabit() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            content: TextField(
              controller: textController,
              decoration: const InputDecoration(hintText: "Create new habit"),
            ),
            actions: [
              // save button
              MaterialButton(
                onPressed: () {
                  // get the new habit
                  String newHabitName = textController.text;

                  //save to db
                  context.read<HabitDatebase>().addHabit(newHabitName);

                  // pop box
                  Navigator.pop(context);

                  // clear controller
                  textController.clear();
                },
                child: const Text('Save'),
              ),
              // cancel button
              MaterialButton(
                onPressed: () {
                  // pop box
                  Navigator.pop(context);

                  // clear controller
                  textController.clear();
                },
                child: const Text('Cancel it'),
              ),
            ],
          ),
    );
  }

  // check habit on & off
  void checkHabitOnOff(bool? value, Habit habit) {
    // update habit completion status
    if (value != null) {
      context.read<HabitDatebase>().updateHabitCompletion(habit.id, value);
      setState(() {});
    }
  }

  // edit habit box
  void editHabitBox(Habit habit) {
    // set text controller
    textController.text = habit.name;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            content: TextField(
              controller: textController,
              decoration: const InputDecoration(hintText: "Editing habit"),
            ),
            actions: [
              // save button
              MaterialButton(
                onPressed: () {
                  // get the new habit
                  String newHabitName = textController.text;

                  //save to db
                  context.read<HabitDatebase>().updateHabitName(
                    habit.id,
                    newHabitName,
                  );

                  // pop box
                  Navigator.pop(context);

                  // clear controller
                  textController.clear();
                },
                child: const Text('Save'),
              ),
              // cancel button
              MaterialButton(
                onPressed: () {
                  // pop box
                  Navigator.pop(context);

                  // clear controller
                  textController.clear();
                },
                child: const Text('Cancel'),
              ),
            ],
          ),
    );
  }

  // delete habit box
  void deleteHabitBox(Habit habit) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Are you sure you want to delete this habit?'),
            actions: [
              // delete button
              MaterialButton(
                onPressed: () {
                  //save to db
                  context.read<HabitDatebase>().deleteHabit(habit.id);

                  // pop box
                  Navigator.pop(context);
                },
                child: const Text('Delete'),
              ),
              // cancel button
              MaterialButton(
                onPressed: () {
                  // pop box
                  Navigator.pop(context);
                },
                child: const Text('Cancel it'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      drawer: const MyDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: createNewHabit,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        child: const Icon(Icons.add),
      ),
      body: ListView(
        children: [
          // H E A T M A P
          _buildHeatMap(),

          // H A B I T  L I S T
          _buildHabitList(),
        ],
      ),
    );
  }

  // build heat map
  Widget _buildHeatMap() {
    // habit db
    final habitDatabase = context.watch<HabitDatebase>();

    // current habits
    List<Habit> currentHabits = habitDatabase.currentHabits;

    // return heat map UI
    return FutureBuilder<DateTime?>(
      future: habitDatabase.getFirstDate(),
      builder: (context, snapshot) {
        //once the data available => build heat map
        if (snapshot.hasData) {
          return MyHeatMap(
            startDate: snapshot.data!,
            endDate: DateTime.now(),
            datasets: prepHeatMapDateset(currentHabits),
          );
        }
        //handle case where no data is returned
        else {
          return Container();
        }
      },
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
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        // get each individual habit
        final habit = currentHabits[index];

        // check if habit is completed today
        bool isCompletedToday = isHabitCompletedToday(habit.completedDays);

        // return habit title UI
        return MyHabitTile(
          text: habit.name,
          isCompleted: isCompletedToday,
          onChanged: (value) => checkHabitOnOff(value, habit),
          editHabit: (context) => editHabitBox(habit),
          deleteHabit: (context) => deleteHabitBox(habit),
        );
      },
    );
  }
}
