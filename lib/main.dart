import 'package:flutter/material.dart';
import 'package:habit_app/database/habit_datebase.dart';
import 'package:habit_app/pages/home_page.dart';
import 'package:habit_app/theme/theme_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize the database
  await HabitDatebase.initialize();
  await HabitDatebase().saveFirstDate(DateTime.now());

  runApp(
    MultiProvider(
      providers: [
        // habit provider
        ChangeNotifierProvider(create: (context) => HabitDatebase()),

        // theme provider
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
      theme: Provider.of<ThemeProvider>(context).themeData,
    );
  }
}
