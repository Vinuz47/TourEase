import 'dart:math';

import 'package:data_management_project/data/expences_category_list.dart';
import 'package:data_management_project/data/group_people_name_list.dart';
import 'package:data_management_project/screens/home/views/main_screen.dart';
import 'package:data_management_project/screens/stats/stats_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int index = 0;
  late Color selectItem = Colors.blue;
  late Color unselectItem = Colors.grey;
  DateTime? _selectedDate;
  String? _selectedNameItem;
  String? _selectedCategoryItem;

  // Function to show the date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      keyboardType: TextInputType.emailAddress,

      context: context,
      initialDate: DateTime.now(), // Current date as default
      firstDate: DateTime(2000), // Earliest date selectable
      lastDate: DateTime(2100), // Latest date selectable
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate; // Set the selected date
      });
    }
  }

  Widget dialogBox(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Transactions'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            children: [
              // TextFormField with dropdown
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Select a Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  value: _selectedNameItem, // Currently selected value
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedNameItem = newValue; // Update the selected value
                    });
                  },
                  items: groupPeopleNames
                      .map<DropdownMenuItem<String>>((String itemOfName) {
                    return DropdownMenuItem<String>(
                      value: itemOfName,
                      child: Text(itemOfName),
                    );
                  }).toList(),
                ),
              ),

              //transactions categories
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Select a Category',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  value: _selectedCategoryItem, // Currently selected value
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCategoryItem =
                          newValue; // Update the selected value
                    });
                  },
                  items: expencesList
                      .map<DropdownMenuItem<String>>((String itemOfCategories) {
                    return DropdownMenuItem<String>(
                      value: itemOfCategories,
                      child: Text(itemOfCategories),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: TextFormField(
                keyboardType: const TextInputType.numberWithOptions(),
                decoration: InputDecoration(
                  hintText: "Enter Amount",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(
                        color: Colors.blue,
                        width: 2.0,
                      )),
                )),
          ),
          // ElevatedButton(
          //     onPressed: () => _selectDate(context),
          //     style: const ButtonStyle(
          //       backgroundColor:
          //           WidgetStatePropertyAll(Color.fromARGB(255, 33, 31, 31)),
          //       foregroundColor: WidgetStatePropertyAll(Colors.white),
          //     ),
          //     child: const Text("Select date"))
        ],
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                print("done");
                Navigator.of(context).pop(); // Close the popup
              },
            ),
            TextButton(
              child: const Text('Done'),
              onPressed: () {
                // print(
                //     'Selected Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}');
                Navigator.of(context).pop(); // Done the popup
              },
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        child: BottomNavigationBar(
            onTap: (value) {
              setState(() {
                index = value;
              });
              //print(value);
            },
            //fixedColor: Colors.red,
            //backgroundColor: Colors.white,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            elevation: 5,
            items: [
              BottomNavigationBarItem(
                  icon: Icon(
                    CupertinoIcons.home,
                    color: index == 0 ? selectItem : unselectItem,
                  ),
                  label: 'Home'),
              BottomNavigationBarItem(
                  icon: Icon(
                    CupertinoIcons.graph_square_fill,
                    color: index == 1 ? selectItem : unselectItem,
                  ),
                  label: 'Stats'),
            ]),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _selectedNameItem = null; // Clear the selected name
            _selectedCategoryItem = null; // Clear the selected category
          });
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return dialogBox(context);
            },
          );
        },
        shape: const CircleBorder(),
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.tertiary,
                  Theme.of(context).colorScheme.secondary,
                  Theme.of(context).colorScheme.primary,
                ],
                transform: const GradientRotation(pi / 4), //gradient rotation
              )),
          child: const Icon(CupertinoIcons.add),
        ),
      ),
      body: index == 0 ? const MainScreen(groupName: "Unknown",) : const StatsScreen(),
    );
  }
}
