import 'package:data_management_project/screens/home/views/planned_tour_screen.dart';
import 'package:data_management_project/screens/home/views/tour_planning_page.dart';
import 'package:flutter/material.dart';

class MyAppView extends StatelessWidget {
  const MyAppView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Budget Tracker",
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          surface: Colors.grey.shade100,
          onSurface: Colors.black,
          primary: const Color(0xFF00B2E7),
          secondary: const Color(0xFFE064F7),
          //secondary:Color.fromARGB(255, 138, 20, 249),
          tertiary: const Color(0xFFFF8D6C),
          outline: Colors.grey,
        ),
      ),
      //home: const TourPlanningPage(),
      home: const PlannedTourScreen(),
    );
  }
}
