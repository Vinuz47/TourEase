import 'dart:math';
import 'package:data_management_project/data/data.dart';
import 'package:data_management_project/screens/home/views/tour_planning_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class MainScreen extends StatefulWidget {
  final String groupName;

  const MainScreen({super.key, required this.groupName});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

int? index;

class _MainScreenState extends State<MainScreen> {
  List<Person> people = [];
  List<Category> categories = [
    Category(name: 'Food', color: Colors.red, icon: Icons.fastfood),
    Category(name: 'Transport', color: Colors.blue, icon: Icons.train_sharp),
    Category(
        name: 'Medicals',
        color: Colors.green,
        icon: Icons.local_hospital_rounded),
  ];
  final Map<String, Color> _colorMap = {};
  TextEditingController nameController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  final ScrollController _scrollControllerPrimary = ScrollController();
  final ScrollController _scrollControllerSecondary = ScrollController();
  late PageController _pageController;
  int _currentPageIndex = 0;
  Category? selectedCategory;
  Color _currentColor = Colors.red;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Listening to page changes
    _pageController.addListener(() {
      int currentPage = _pageController.page?.round() ?? 0;
      if (_currentPageIndex != currentPage) {
        setState(() {
          _currentPageIndex = currentPage;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  //add people to the list
  void _addPerson(String name) {
    setState(() {
      people.add(Person(name: name));
    });
  }

  //add new category
  void _addCategory(String name, Color color, IconData icon) {
    categories.add(Category(name: name, color: color, icon: icon));
  }

  //remove category
  void _removeCategory(String name) {
    categories.removeWhere((category) => category.name == name);
  }

  //add expense
  void _addExpense(String personName, String category, double amount) {
    setState(() {
      final person = people.firstWhere((p) => p.name == personName);
      person.expenses[category] = (person.expenses[category] ?? 0) + amount;
    });
  }

  //calculate total category expenses
  // Map<String, double> _calculateCategoryTotals() {
  //   Map<String, double> categoryTotals = {};
  //   for (var category in categories) {
  //     categoryTotals[category] = 0.0;
  //     for (var person in people) {
  //       categoryTotals[category] =
  //           categoryTotals[category]! + (person.expenses[category] ?? 0);
  //     }
  //   }
  //   return categoryTotals;
  // }
  Map<Category, double> _calculateCategoryTotals() {
    Map<Category, double> categoryTotals = {};

    // Initialize totals for each category
    for (var category in categories) {
      categoryTotals[category] = 0.0;
    }

    // Sum the expenses for each category across all people
    for (var person in people) {
      for (var category in categories) {
        categoryTotals[category] =
            categoryTotals[category]! + (person.expenses[category.name] ?? 0);
      }
    }

    return categoryTotals;
  }

  //show add person dialog box
  void _showAddPersonDialog() {
    nameController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Person'),
        content: Wrap(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ButtonStyle(
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              elevation: WidgetStateProperty.all(10),
              backgroundColor: WidgetStateProperty.all(Colors.blue),
              foregroundColor: WidgetStateProperty.all(Colors.white),
            ),
            onPressed: () {
              setState(() {
                _currentColor = _getRandomColor();
              });
              if (nameController.text.trim().isNotEmpty) {
                _addPerson(nameController.text.trim());
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          'Successfully added ${nameController.text.trim()}.')),
                );
                Navigator.of(context).pop();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddExpenseDialog() {
    if (people.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one person first.')),
      );
      return;
    }

    String selectedPerson = people.first.name;
    Category? selectedCategory =
        categories.isNotEmpty ? categories.first : null;
    amountController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Expense'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedPerson,
                items: people
                    .map((person) => DropdownMenuItem(
                          value: person.name,
                          child: Text(person.name),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedPerson = value;
                    });
                  }
                },
                decoration: const InputDecoration(labelText: 'Person'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Category>(
                value: selectedCategory,
                items: categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: category.color,
                          child: Icon(category.icon, color: Colors.white),
                        ),
                        const SizedBox(width: 8),
                        Text(category.name),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedCategory = value;
                    });
                  }
                },
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (selectedCategory != null) {
                double amount = double.tryParse(amountController.text) ?? 0.0;
                if (amount > 0) {
                  _addExpense(selectedPerson, selectedCategory!.name, amount);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Successfully added expense.')),
                  );
                  Navigator.of(context).pop();
                }
                // ScaffoldMessenger.of(context).showSnackBar(
                //   const SnackBar(content: Text('Please enter a valid amount.')),
                // );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please select a category.')),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  //show manage category dialog box
  void _showManageCategoryDialog() {
    final ScrollController scrollController = ScrollController();
    categoryController.clear();
    Color selectedColor = Colors.blue; // Default category color
    IconData selectedIcon = Icons.category; // Default category icon

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Manage Categories'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Input for New Category Name
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(labelText: 'New Category'),
              ),
              const SizedBox(height: 16),

              // Color Picker Section
              Row(
                children: [
                  const Text('Select Color:'),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () async {
                      final pickedColor = await showDialog<Color>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Pick a Color'),
                          content: SingleChildScrollView(
                            child: BlockPicker(
                              pickerColor: selectedColor,
                              onColorChanged: (color) {
                                selectedColor = color;
                                Navigator.of(context).pop(color);
                              },
                            ),
                          ),
                        ),
                      );
                      if (pickedColor != null) {
                        selectedColor = pickedColor;
                        (context as Element).markNeedsBuild();
                      }
                    },
                    child: CircleAvatar(
                      backgroundColor: selectedColor,
                      radius: 15,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Icon Picker Section
              Row(
                children: [
                  const Text('Select Icon:'),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () async {
                      final pickedIcon = await showDialog<IconData>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Pick an Icon'),
                          content: Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: _iconOptions.map((iconData) {
                              return GestureDetector(
                                onTap: () =>
                                    Navigator.of(context).pop(iconData),
                                child: Icon(iconData, size: 30),
                              );
                            }).toList(),
                          ),
                        ),
                      );
                      if (pickedIcon != null) {
                        selectedIcon = pickedIcon;
                        (context as Element).markNeedsBuild();
                      }
                    },
                    child: Icon(selectedIcon, size: 30),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Add New Category Button
              ElevatedButton(
                onPressed: () {
                  if (categoryController.text.trim().isNotEmpty) {
                    _addCategory(
                      categoryController.text.trim(),
                      selectedColor,
                      selectedIcon,
                    );
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Add Category'),
              ),

              const SizedBox(height: 16),

              // Display Existing Categories with Options to Remove
              SizedBox(
                height: MediaQuery.of(context).size.height / 3,
                child: Scrollbar(
                  controller: scrollController,
                  interactive: true,
                  radius: const Radius.circular(50),
                  thickness: 5,
                  thumbVisibility: true,
                  child: ListView(
                    controller: scrollController,
                    children: categories.map((category) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: category.color,
                          child: Icon(category.icon, color: Colors.white),
                        ),
                        title: Text(category.name),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _removeCategory(category.name);
                            Navigator.of(context).pop();
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).then((_) => scrollController.dispose());
  }

  // // Calculate the total sum of `totalAmount`
  // double totalExpensec = myTransactionData.fold(0, (sum, item) {
  //   return sum + double.parse(item['totalAmount']);
  // });

  //calculate total expenses
  double _calculateTotalExpenses() {
    return people.fold(
      0.0,
      (total, person) =>
          total +
          person.expenses.values.fold(0.0, (sum, expense) => sum + expense),
    );
  }

  //calculate per person expenses
  double _calculatePerPersonShare() {
    if (people.isEmpty) return 0.0;
    return _calculateTotalExpenses() / people.length;
  }

  //calculate per person balance
  List<Map<String, dynamic>> _calculateBalances() {
    double perPersonShare = _calculatePerPersonShare();
    return people.map((person) {
      double totalSpent =
          person.expenses.values.fold(0.0, (sum, expense) => sum + expense);
      return {
        'name': person.name,
        'totalSpent': totalSpent,
        'balance': totalSpent - perPersonShare,
      };
    }).toList();
  }

  //get random color
  Color _getRandomColor() {
    final random = Random();
    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }

  // Get a unique color for a person
  Color _getColorForPerson(String name) {
    if (!_colorMap.containsKey(name)) {
      _colorMap[name] = _getRandomColor();
    }
    return _colorMap[name]!;
  }

  @override
  Widget build(BuildContext context) {
    double totalExpense = _calculateTotalExpenses();
    double perPersonShare = _calculatePerPersonShare();
    List<Map<String, dynamic>> balances = _calculateBalances();
    Map<Category, double> categoryTotals = _calculateCategoryTotals();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      // mainAxisSize: MainAxisSize.max,
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.yellow[700],
                              ),
                            ),
                            Icon(
                              CupertinoIcons.person_fill,
                              color: Colors.yellow[900],
                            )
                          ],
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                            ),
                            Text(
                              widget.groupName,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        //add expence button
                        IconButton(
                            onPressed: _showAddExpenseDialog,
                            icon: const Icon(
                              size: 40,
                              CupertinoIcons.add_circled_solid,
                            )),
                        Text("Add Expence",
                            style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.outline,
                                fontWeight: FontWeight.w600))
                      ],
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),

                //Main Screen box
                Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.width / 2,
                    decoration: BoxDecoration(
                        //color: Colors.red,
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.secondary,
                            Theme.of(context).colorScheme.tertiary,
                          ],
                          transform: const GradientRotation(
                              pi / 4), //gradient rotation
                        ),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                              blurRadius: 4,
                              color: Colors.grey.shade400,
                              offset: const Offset(5, 5))
                        ]),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Total Expences',
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(
                          height: 2,
                        ),
                        Text(
                          'Rs. ${totalExpense.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 40,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 7,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              //income and arrow down widget
                              Row(
                                children: [
                                  Container(
                                      height: 30,
                                      width: 30, //arrorw down size
                                      decoration: const BoxDecoration(
                                        color: Colors.white30,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Center(
                                          child: Icon(
                                        CupertinoIcons.person_fill,
                                        color: Colors.greenAccent,
                                        size: 20,
                                      ))),
                                  const SizedBox(
                                    width: 12,
                                  ), //distance between arrow down and text
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Per Person Share',
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w400),
                                      ),
                                      Text(
                                        'Rs. ${perPersonShare.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                            fontSize: 18,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w900),
                                      )
                                    ],
                                  )
                                ],
                              ),

                              // Row(
                              //   children: [
                              //     Container(
                              //         height: 25,
                              //         width: 25, //arrorw down size
                              //         decoration: const BoxDecoration(
                              //           color: Colors.white30,
                              //           shape: BoxShape.circle,
                              //         ),
                              //         child: const Center(
                              //             child: Icon(
                              //           CupertinoIcons.person_3_fill,
                              //           color: Colors.red,
                              //           size: 12,
                              //         ))),
                              //     const SizedBox(
                              //       width: 12,
                              //     ), //distance between arrow down and text
                              //     Column(
                              //       crossAxisAlignment:
                              //           CrossAxisAlignment.start,
                              //       children: [
                              //         const Text(
                              //           'Group Count',
                              //           style: TextStyle(
                              //               fontSize: 14,
                              //               color: Colors.white,
                              //               fontWeight: FontWeight.w400),
                              //         ),
                              //         Text(
                              //           '${people.length}',
                              //           style: const TextStyle(
                              //               fontSize: 14,
                              //               color: Colors.white,
                              //               fontWeight: FontWeight.w600),
                              //         )
                              //       ],
                              //     )
                              //   ],
                              // )
                            ],
                          ),
                        )
                      ],
                    )),
                const SizedBox(
                  height: 40,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          _currentPageIndex = 0;
                          _pageController.animateToPage(0,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut);
                        });
                      },
                      child: Text(
                        'Transactions',
                        style: TextStyle(
                            fontSize: _currentPageIndex == 0 ? 16 : 14,
                            color: _currentPageIndex == 0
                                ? Theme.of(context).colorScheme.onSurface
                                : Theme.of(context).colorScheme.outline,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _currentPageIndex = 1;
                          _pageController.animateToPage(1,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut);
                        });
                      },
                      child: Text(
                        'People Payments',
                        style: TextStyle(
                            fontSize: _currentPageIndex == 1 ? 16 : 14,
                            color: _currentPageIndex == 1
                                ? Theme.of(context).colorScheme.onSurface
                                : Theme.of(context).colorScheme.outline,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),

                SizedBox(
                  // width: MediaQuery.of(context).size.width *
                  //     2, // Make the container large enough to allow scrolling
                  height: MediaQuery.of(context).size.height / 2.4,
                  child: PageView(
                    controller: _pageController,
                    scrollDirection: Axis.horizontal,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: 40,
                        ),
                        child: Scrollbar(
                          controller: _scrollControllerPrimary,
                          interactive: true,
                          radius: const Radius.circular(50),
                          thickness: 5,
                          thumbVisibility: true,
                          trackVisibility: false,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: ListView.builder(
                                controller: _scrollControllerPrimary,
                                keyboardDismissBehavior:
                                    ScrollViewKeyboardDismissBehavior.onDrag,
                                itemCount: categoryTotals.length,
                                itemBuilder: (context, int i) {
                                  final category =
                                      categoryTotals.keys.elementAt(i);
                                  final totalExpense =
                                      categoryTotals[category]!;
                                  return Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 16.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          color: Colors.white),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Stack(
                                                  alignment: Alignment.center,
                                                  children: [
                                                    Container(
                                                      //Yellow colour Circle
                                                      width: 50,
                                                      height: 50,
                                                      decoration: BoxDecoration(
                                                          color: category
                                                              .color, //Colors.yellow[700],
                                                          shape:
                                                              BoxShape.circle),
                                                    ),
                                                    Icon(category.icon,
                                                        color: Colors.white),
                                                    // myTransactionData[i]['icon'],
                                                    // const Icon(
                                                    //   Icons.myTransactionData[i]['icon'],
                                                    //   color: Colors.white,
                                                    // )
                                                  ],
                                                ),
                                                const SizedBox(
                                                  width: 12,
                                                ),
                                                Text(
                                                  category.name,
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onSurface,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                                const SizedBox(
                                                  width: 20,
                                                ),
                                              ],
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  'Rs. ${totalExpense.toStringAsFixed(2)}',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onSurface,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Text(
                                                  "date",
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onSurface,
                                                      fontWeight:
                                                          FontWeight.w400),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                          ),
                        ),
                      ),

                      //second page
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: 40,
                        ),
                        child: balances.isEmpty
                            ? const Center(
                                child: Text(
                                "No one to show",
                                style: TextStyle(
                                    color: Color.fromARGB(255, 129, 135, 138),
                                    fontWeight: FontWeight.bold),
                              ))
                            : Scrollbar(
                                controller: _scrollControllerSecondary,
                                interactive: true,
                                radius: const Radius.circular(50),
                                thickness: 5,
                                thumbVisibility: true,
                                trackVisibility: false,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: ListView.builder(
                                      controller: _scrollControllerSecondary,
                                      keyboardDismissBehavior:
                                          ScrollViewKeyboardDismissBehavior
                                              .onDrag,
                                      itemCount: balances.length,
                                      itemBuilder: (context, int i) {
                                        //final peopleCount = balances.length;
                                        final balance = balances.elementAt(i);
                                        final color =
                                            _getColorForPerson(balance['name']);
                                        // final totalExpense =
                                        //     categoryTotals[balance]!;
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 16.0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                color: Colors.white),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(10.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Stack(
                                                        alignment:
                                                            Alignment.center,
                                                        children: [
                                                          Container(
                                                            //Yellow colour Circle
                                                            width: 50,
                                                            height: 50,
                                                            decoration:
                                                                BoxDecoration(
                                                                    color:
                                                                        color, //Colors.yellow[700],
                                                                    shape: BoxShape
                                                                        .circle),
                                                          ),
                                                          const Icon(
                                                              Icons.person,
                                                              color:
                                                                  Colors.white),
                                                          // myTransactionData[i]['icon'],
                                                          // const Icon(
                                                          //   Icons.myTransactionData[i]['icon'],
                                                          //   color: Colors.white,
                                                          // )
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                        width: 12,
                                                      ),
                                                      balance['balance'] != 0
                                                          ? Column(
                                                              children: [
                                                                Text(
                                                                  balance[
                                                                      'name'],
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      color: Theme.of(
                                                                              context)
                                                                          .colorScheme
                                                                          .onSurface,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500),
                                                                ),
                                                                Text(
                                                                  balance['balance'] >
                                                                          0
                                                                      ? '(Owe)'
                                                                      : '(Pay)',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      color: balance['balance'] > 0
                                                                          ? Colors
                                                                              .green
                                                                          : Colors
                                                                              .red,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500),
                                                                ),
                                                              ],
                                                            )
                                                          : Text(
                                                              balance['name'],
                                                              style: TextStyle(
                                                                  fontSize: 14,
                                                                  color: Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .onSurface,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                            ),
                                                      const SizedBox(
                                                        width: 20,
                                                      ),
                                                    ],
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      Text(
                                                        'Rs. ${num.parse(balance['balance'].toStringAsFixed(2)).abs()}',
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            color: balance[
                                                                        'balance'] >
                                                                    0
                                                                ? Colors.green
                                                                : Colors.red,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Text(
                                                        "${balance['totalSpent'].toStringAsFixed(2)}",
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .onSurface,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w400),
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20), // Increased radius
                    topRight: Radius.circular(20), // Increased radius
                  ),
                  color: Color.fromARGB(255, 248, 240, 248),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                              onPressed: _showAddPersonDialog,
                              icon: Icon(
                                Icons.person_add_alt_rounded,
                                color: Theme.of(context).colorScheme.primary,
                                size: 40,
                              )),
                          Text("Add People",
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.outline,
                                  fontWeight: FontWeight.w600))
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                              onPressed: _showManageCategoryDialog,
                              icon: Icon(
                                Icons.category_rounded,
                                color: Theme.of(context).colorScheme.primary,
                                size: 40,
                              )),
                          Center(
                            child: Text("Add Category",
                                maxLines: 2,
                                style: TextStyle(
                                    fontSize: 12,
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                    fontWeight: FontWeight.w600)),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class Person {
  String name;
  Map<String, double> expenses;

  Person({
    required this.name,
  }) : expenses = {};
}

class Category {
  String name;
  Color color;
  IconData icon;

  Category({
    required this.name,
    required this.color,
    required this.icon,
  });
}

final List<IconData> _iconOptions = [
  Icons.fastfood,
  Icons.flight,
  Icons.video_camera_front_rounded,
  Icons.shopping_cart,
  Icons.home,
  Icons.pets,
  Icons.train_sharp,
  Icons.build_sharp,
  Icons.school,
  Icons.local_drink_rounded,
  Icons.oil_barrel,
  Icons.emoji_transportation_rounded,
  Icons.people,
  Icons.local_hospital,
  Icons.person,
  Icons.water_drop,
  Icons.ice_skating_sharp,
  Icons.local_laundry_service,
];
