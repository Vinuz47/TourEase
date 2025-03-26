import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:data_management_project/data/city_data.dart';
import 'package:data_management_project/data/city_model.dart';
import 'package:data_management_project/screens/home/views/main_screen.dart';
import 'package:data_management_project/screens/home/views/weather_prediction/weather_prediction_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class SummeryOfTheTourPlanning extends StatefulWidget {
  final String collectionName;
  final String documentId;

  SummeryOfTheTourPlanning({
    super.key,
    required this.collectionName,
    required this.documentId,
  });

  @override
  State<SummeryOfTheTourPlanning> createState() =>
      _SummeryOfTheTourPlanningState();
}

class _SummeryOfTheTourPlanningState extends State<SummeryOfTheTourPlanning> {
  String groupName = '';
  DateTime? _selectedDate;
  double? selectedLatitude;

  double? selectedLongitude;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _selectDate(BuildContext context, String preDate) async {
    final DateTime? pickedDate = await showDatePicker(
      keyboardType: TextInputType.emailAddress,

      context: context,
      initialDate: DateTime.parse(preDate), // Current date as default
      firstDate: DateTime(2000), // Earliest date selectable
      lastDate: DateTime.now()
          .add(const Duration(days: 14)), // Latest date selectable
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate; // Set the selected date
      });
      await FirebaseFirestore.instance
          .collection(widget.collectionName)
          .doc(widget.documentId)
          .update({"date": DateFormat('yyyy-MM-dd').format(_selectedDate!)});

      // setState(() {}); // Refresh UI
      // Navigator.pop(context);
    }
  }

  void _showEditDialog(String fieldName, String currentValue) {
    TextEditingController controller =
        TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit $fieldName"),
          content: fieldName != 'destination'
              ? TextField(
                  controller: controller,
                  decoration: InputDecoration(hintText: "Enter new $fieldName"),
                )
              : DropdownButtonFormField<String>(
                  value: currentValue,
                  onChanged: (String? newValue) {
                    controller.text = newValue!;
                  },
                  items: cities.map((City city) {
                    return DropdownMenuItem<String>(
                      value: city.name,
                      child: Text(city.name),
                    );
                  }).toList(),
                ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                String updatedValue = controller.text.trim();
                if (updatedValue.isNotEmpty) {
                  await FirebaseFirestore.instance
                      .collection(widget.collectionName)
                      .doc(widget.documentId)
                      .update({fieldName: updatedValue});

                  if (fieldName == 'destination') {
                    City city =
                        cities.firstWhere((city) => city.name == updatedValue);

                    await FirebaseFirestore.instance
                        .collection(widget.collectionName)
                        .doc(widget.documentId)
                        .update({"latitude": city.latitude});

                    await FirebaseFirestore.instance
                        .collection(widget.collectionName)
                        .doc(widget.documentId)
                        .update({"longitude": city.longitude});
                  }

                  setState(() {}); // Refresh UI
                  Navigator.pop(context);
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

// ignore: non_constant_identifier_names
  Widget listTile_of_tour_summery(
      String title, String subtitle, String fieldName, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(
        right: 22,
        left: 12,
        top: 12,
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color:
                  const Color.fromARGB(255, 255, 255, 255), // Background color
              borderRadius: BorderRadius.circular(15),
              // Change the border radius
              // ignore: prefer_const_literals_to_create_immutables
              boxShadow: [
                const BoxShadow(
                    color: Colors.grey,
                    blurRadius: 5,
                    spreadRadius: 2,
                    offset: Offset(5, 10),
                    blurStyle: BlurStyle.normal),
              ],
            ),
            child: ListTile(
              //tileColor: const Color.fromARGB(255, 174, 222, 245),
              title: Text(title,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 12, 14, 15),
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  )),
              subtitle: InkWell(
                onTap: () => fieldName == "date"
                    ? _selectDate(context, subtitle)
                    : _showEditDialog(fieldName, subtitle),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AutoSizeText(subtitle,
                        maxLines: 2,
                        minFontSize: 5,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 15, 49, 77),
                          fontWeight: FontWeight.w500,
                          //fontSize: 15,
                        )),
                    InkWell(
                      onTap: () {
                        fieldName == "date"
                            ? _selectDate(context, subtitle)
                            : _showEditDialog(fieldName, subtitle);
                      },
                      child: const Padding(
                        padding: EdgeInsets.only(left: 10.0),
                        child: Icon(
                          Icons.edit_square,
                          color: Color.fromARGB(255, 65, 116, 67),
                          size: 20,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              leading: Icon(
                icon,
                color: const Color.fromARGB(255, 14, 41, 6),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          const Divider(
            color: Color.fromARGB(210, 120, 118, 118),
            thickness: 1,
          ),
        ],
      ),
    );
  }

//bottom buttons
  Widget bottomButtons(
      {required String text, required VoidCallback onPressed}) {
    return Align(
      alignment: Alignment.topRight,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          elevation: WidgetStateProperty.all(10),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0))),
          backgroundColor:
              WidgetStateProperty.all(const Color.fromARGB(255, 88, 156, 91)),
        ),
        child: Text(text,
            style: const TextStyle(
                color: Color.fromARGB(240, 0, 0, 0),
                fontWeight: FontWeight.w600)),
      ),
    );
  }

  //   /// Fetch city details based on selected city name
  // void _fetchCityDetails(String selectedCityName) {
  //   City? selectedCity =
  //       cities.firstWhere((city) => city.name == selectedCityName);

  //   setState(() {
  //     selectedLatitude = selectedCity.latitude;
  //     selectedLongitude = selectedCity.longitude;
  //   });

  //   //print("Selected City: ${selectedCity.name}");
  //   print("Latitude: $selectedLatitude");
  //   print("Longitude: $selectedLongitude");
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar:
          // AppBar(
          //   automaticallyImplyLeading: true,
          //   backgroundColor: Colors.white.withOpacity(0.9),
          //   elevation: 10,
          //   // systemOverlayStyle:
          //   //     const SystemUiOverlayStyle(statusBarBrightness: Brightness.dark),
          //   title: const Text(
          //     textAlign: TextAlign.center,
          //     'Summery of the Planning',
          //     style: TextStyle(
          //         fontWeight: FontWeight.w600, color: Color.fromARGB(255, 0, 0, 0)),
          //   ),
          //   flexibleSpace: Stack(
          //     children: [
          //       Positioned.fill(
          //         bottom: -20, // Extend blur effect slightly below AppBar
          //         child: Align(
          //           alignment: Alignment.bottomCenter,
          //           child: ClipRect(
          //             child: BackdropFilter(
          //               filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          //               child: Container(
          //                 height: 10, // Thickness of the blurred border
          //                 color: Colors.white.withOpacity(0.2), // Adjust opacity
          //               ),
          //             ),
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          AppBar(
        foregroundColor: Colors.white,
        // title: const Center(
        //   child: Text(
        //     "Weather Prediction",
        //     //textAlign: TextAlign.center,
        //   ),
        // ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle:
            const SystemUiOverlayStyle(statusBarBrightness: Brightness.dark),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(0, 1.2 * kToolbarHeight, 0, 20),
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Stack(children: [
            Align(
              alignment: const AlignmentDirectional(3, -0.3),
              child: Container(
                height: 300,
                width: 300,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color.fromARGB(255, 63, 183, 99)),
              ),
            ),
            Align(
              alignment: const AlignmentDirectional(-3, -0.3),
              child: Container(
                height: 300,
                width: 300,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color.fromARGB(255, 36, 4, 58)),
              ),
            ),
            Align(
              alignment: const AlignmentDirectional(0, -1.2),
              child: Container(
                height: 300,
                width: 600,
                decoration:
                    const BoxDecoration(color: Color.fromARGB(255, 2, 115, 4)),
              ),
            ),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 100.0, sigmaY: 100.0),
              child: Container(
                decoration: const BoxDecoration(color: Colors.transparent),
              ),
            ),
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection(widget.collectionName)
                  .doc(widget.documentId)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(
                      child: Text(
                    'Document does not exist',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ));
                }

                // Access document data
                var data = snapshot.data!.data() as Map<String, dynamic>;
                groupName = data['group-name'];

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    //child: Stack(children: [
                    // Align(
                    //   alignment: const AlignmentDirectional(3, -0.3),
                    //   child: Container(
                    //     height: 300,
                    //     width: 300,
                    //     decoration: const BoxDecoration(
                    //         shape: BoxShape.circle,
                    //         color: Color.fromARGB(255, 201, 205, 206)),
                    //   ),
                    // ),
                    // Align(
                    //   alignment: const AlignmentDirectional(-3, -0.3),
                    //   child: Container(
                    //     height: 300,
                    //     width: 300,
                    //     decoration: const BoxDecoration(
                    //         shape: BoxShape.circle,
                    //         color: Color.fromARGB(255, 201, 205, 206)),
                    //   ),
                    // ),
                    // Align(
                    //   alignment: const AlignmentDirectional(0, -1.2),
                    //   child: Container(
                    //     height: 300,
                    //     width: 600,
                    //     decoration: const BoxDecoration(
                    //       color: Color.fromARGB(255, 241, 239, 241),
                    //     ),
                    //   ),
                    // ),
                    // BackdropFilter(
                    //   filter: ImageFilter.blur(
                    //     sigmaX: 100.0,
                    //     sigmaY: 100.0,
                    //     //tileMode: TileMode.repeated
                    //   ),
                    //   child: Container(
                    //     decoration: const BoxDecoration(color: Colors.transparent),
                    //   ),
                    // ),
                    // SizedBox(
                    child: SingleChildScrollView(
                      child: Column(
                        // crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          //centeer welcome topic
                          Padding(
                            padding: const EdgeInsets.only(left: 15, right: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Welcome to the \nTour-Ease',
                                    //textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.w900,
                                      color: Color.fromARGB(255, 207, 207, 207),
                                    )),
                                Image.asset(
                                  'assets/summery_page_logo.png',
                                  width: 100,
                                  height: 100,
                                ),
                              ],
                            ),
                          ),

                          //group name
                          listTile_of_tour_summery('Group Name',
                              data['group-name'], "group-name", Icons.groups_2),

                          //destination
                          listTile_of_tour_summery(
                              "Destination",
                              //"(Lat: ${data['latitude']} , Long: ${data['longitude']}
                              "${data['destination']}",
                              "destination",
                              Icons.location_on),

                          //date
                          listTile_of_tour_summery("Trip on", data['date'],
                              "date", Icons.date_range),
                          //transport method
                          listTile_of_tour_summery(
                              "Transport Method",
                              data['transport-method'],
                              "transport-method",
                              Icons.directions_car),
                          //number of people
                          listTile_of_tour_summery(
                              "Count of Group",
                              data['number-of-people'],
                              "number-of-people",
                              Icons.people),

                          const SizedBox(
                            height: 10,
                          ),

                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                //weather predictio button
                                bottomButtons(
                                    text: "Weather Prediction",
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                WeatherPredictionScreen(
                                                  date: data['date'],
                                                  longitude: (data['longitude'])
                                                      .toString(),
                                                  latitude: (data['latitude'])
                                                      .toString(),
                                                  city: data['destination'],
                                                )),
                                      );
                                    }),

                                //continue button
                                bottomButtons(
                                    text: "Continue",
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => MainScreen(
                                                  groupName: groupName,
                                                )),
                                      );
                                    }),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    //),
                  ),
                );
              },
            ),
          ]),
        ),
      ),
    );
  }
}
