import 'package:flutter/cupertino.dart';
import 'package:habit_app/models/app_settings.dart';
import 'package:habit_app/models/habit.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class HabitDatebase extends ChangeNotifier {
  static late Isar isar;

  /*

  S E T U P

   */

  // I N I T I A L I Z E - D A T A B A S E
  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open([
      HabitSchema,
      AppSettingsSchema,
    ], directory: dir.path);
  }

  // Save first date of app startup (for heatmap)
  Future<void> saveFirstDate(DateTime date) async {
    final existingSetting = await isar.appSettings.where().findFirst();
    if (existingSetting == null) {
      final settings = AppSettings()..firstLaunchDate = DateTime.now();
      await isar.writeTxn(() => isar.appSettings.put(settings));
    }
  }

  // Get first date of app startup (for heatmap)
  Future<DateTime?> getFirstDate() async {
    final settings = await isar.appSettings.where().findFirst();
    return settings?.firstLaunchDate;
  }

  /*

    C R U D X O P E R A T I O N S

   */

  // List of habits
  final List<Habit> currentHabits = [];

  // C R E A T E - add a new habit
  Future<void> addHabit(String habitName) async {
    // create a new habit
    final newHabit = Habit()..name = habitName;

    // save to database
    await isar.writeTxn(() => isar.habits.put(newHabit));

    //re-read from database
    readHabits();
  }

  // R E A D - read saved habits from database
  Future<void> readHabits() async {
    // fetch all habits from database
    List<Habit> fetchedHabits = await isar.habits.where().findAll();

    // give to current habits
    currentHabits.clear();
    currentHabits.addAll(fetchedHabits);

    // update the UI
    notifyListeners();
  }

  // U P D A T E - check habit on and off
  Future<void> updateHabitCompletion(int id, bool isCompleted) async {
    // find the specific habit
    final habit = await isar.habits.get(id);

    // update completion status
    if (habit != null) {
      await isar.writeTxn(() async {
        // if habit is completed => add the current date to the CompleteDays list
        if (isCompleted && !habit.completedDays.contains(DateTime.now())) {
          // today's date
          final today = DateTime.now();

          //add current date if it is not already in the list
          habit.completedDays.add(DateTime(today.year, today.month, today.day));
        }
        // if habit is NOT completed => remove the current date from the CompleteDays list
        else {
          // remove today's date if the habit is marked as incomplete
          habit.completedDays.removeWhere(
            (date) =>
                date.year == DateTime.now().year &&
                date.month == DateTime.now().month &&
                date.day == DateTime.now().day,
          );
        }
        //save the updated habits back to the database
        await isar.habits.put(habit);
      });
    }
  }

  // U P D A T E - edit habit name
  Future<void> updateHabitName(int id, String newName) async {
    // find the habit
    final habit = await isar.habits.get(id);

    // update habit name
    if (habit != null) {
      // update the name
      await isar.writeTxn(() async {
        habit.name = newName;
        // save the updated habit back to the database
        await isar.habits.put(habit);
      });
    }

    // re-read from database
    readHabits();
  }

  // D E L E T E - delete habit
  Future<void> deleteHabit(int id) async {
    // perform the delete operation
    await isar.writeTxn(() async {
      await isar.habits.delete(id);
    });

    // re-read from database
    readHabits();
  }
}
