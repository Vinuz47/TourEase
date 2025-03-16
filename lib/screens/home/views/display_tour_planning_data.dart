import 'dart:ui';

import 'package:data_management_project/data/city_data.dart';
import 'package:data_management_project/data/city_model.dart';
import 'package:data_management_project/screens/home/views/main_screen.dart';
import 'package:data_management_project/screens/home/views/weather_prediction_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

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

  double? selectedLatitude;

  double? selectedLongitude;

  @override
  void initState() {
    super.initState();
  }

// ignore: non_constant_identifier_names
  Widget listTile_of_tour_summery(
      String title, String subtitle, IconData icon) {
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
                  const Color.fromARGB(255, 188, 249, 225), // Background color
              borderRadius: BorderRadius.circular(25),
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
              subtitle: Text(subtitle,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 15, 49, 77),
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  )),
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
      //backgroundColor: Colors.white,
      //extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Colors.white.withOpacity(0.9),
        elevation: 10,
        // systemOverlayStyle:
        //     const SystemUiOverlayStyle(statusBarBrightness: Brightness.dark),
        title: const Text(
          textAlign: TextAlign.center,
          'Summery of the Planning',
          style: TextStyle(
              fontWeight: FontWeight.w600, color: Color.fromARGB(255, 0, 0, 0)),
        ),
        flexibleSpace: Stack(
          children: [
            Positioned.fill(
              bottom: -20, // Extend blur effect slightly below AppBar
              child: Align(
                alignment: Alignment.bottomCenter,
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      height: 10, // Thickness of the blurred border
                      color: Colors.white.withOpacity(0.2), // Adjust opacity
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
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
                                color: Color.fromARGB(255, 12, 11, 11),
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
                    listTile_of_tour_summery(
                        'Group Name', data['group-name'], Icons.groups_2),

                    //destination
                    listTile_of_tour_summery(
                        "Destination",
                        //"(Lat: ${data['latitude']} , Long: ${data['longitude']}
                        "${data['destination']}",
                        Icons.location_on),

                    //date
                    listTile_of_tour_summery(
                        "Trip on", data['date'], Icons.date_range),
                    //transport method
                    listTile_of_tour_summery("Transport Method",
                        data['transport-method'], Icons.directions_car),
                    //number of people
                    listTile_of_tour_summery("Count of Group",
                        data['number-of-people'], Icons.people),

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
                                            longitude:
                                                (data['longitude']).toString(),
                                            latitude:
                                                (data['latitude']).toString(),
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
    );
  }
}
