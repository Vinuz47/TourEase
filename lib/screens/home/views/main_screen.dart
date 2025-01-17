import 'dart:math';
import 'package:data_management_project/data/data.dart';
import 'package:data_management_project/screens/home/views/tour_planning_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  final String groupName;

  const MainScreen({super.key, required this.groupName});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

int? index;

class _MainScreenState extends State<MainScreen> {
  // Calculate the total sum of `totalAmount`
  double totalExpensec = myTransactionData.fold(0, (sum, item) {
    return sum + double.parse(item['totalAmount']);
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
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
                          onPressed: () {},
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
                        transform:
                            const GradientRotation(pi / 4), //gradient rotation
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
                        'Rs. ${totalExpensec.toStringAsFixed(2)}',
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            //income and arrow down widget
                            Row(
                              children: [
                                Container(
                                    height: 25,
                                    width: 25, //arrorw down size
                                    decoration: const BoxDecoration(
                                      color: Colors.white30,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                        child: Icon(
                                      CupertinoIcons.arrow_down,
                                      color: Colors.greenAccent,
                                      size: 12,
                                    ))),
                                const SizedBox(
                                  width: 12,
                                ), //distance between arrow down and text
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Income',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w400),
                                    ),
                                    Text(
                                      'Rs. 200.00',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600),
                                    )
                                  ],
                                )
                              ],
                            ),

                            Row(
                              children: [
                                Container(
                                    height: 25,
                                    width: 25, //arrorw down size
                                    decoration: const BoxDecoration(
                                      color: Colors.white30,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                        child: Icon(
                                      CupertinoIcons.arrow_down,
                                      color: Colors.red,
                                      size: 12,
                                    ))),
                                const SizedBox(
                                  width: 12,
                                ), //distance between arrow down and text
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Balance',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w400),
                                    ),
                                    Text(
                                      'Rs. 700.00',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600),
                                    )
                                  ],
                                )
                              ],
                            )
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
                  Text(
                    'Transactions',
                    style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.bold),
                  ),
                  InkWell(
                    onTap: () {},
                    child: Text(
                      'View All',
                      style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.outline,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Expanded(
                child: ListView.builder(
                    itemCount: myTransactionData.length,
                    itemBuilder: (context, int i) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                              color: myTransactionData[i]
                                                  ['color'],
                                              shape: BoxShape.circle),
                                        ),
                                        myTransactionData[i]['icon'],
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
                                      myTransactionData[i]['name'],
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      myTransactionData[i]['totalAmount'],
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      myTransactionData[i]['date'],
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                          fontWeight: FontWeight.w400),
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

              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.people_sharp,
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
                            onPressed: () {},
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
                                  color: Theme.of(context).colorScheme.outline,
                                  fontWeight: FontWeight.w600)),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
