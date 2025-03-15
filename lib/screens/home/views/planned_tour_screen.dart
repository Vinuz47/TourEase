import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_management_project/screens/home/views/display_tour_planning_data.dart';
import 'package:data_management_project/screens/home/views/tour_planning_page.dart';
import 'package:flutter/material.dart';

class PlannedTourScreen extends StatelessWidget {
  const PlannedTourScreen({super.key});

  Future<List<Map<String, dynamic>>> getTrips() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('tour_plan').get();

    return querySnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id; // Add document ID to the data map
      return data;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Trips")),
      body: Column(
        children: [
          // top adding new trips button
          Padding(
            padding:
                const EdgeInsets.only(left: 16, right: 16, bottom: 30, top: 15),
            child: SizedBox(
              width: double.infinity, // Full screen width
              height: 50, // Set a specific height
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TourPlanningPage(),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 20,
                ),
                label: const Text("Create New Trip"),
                style: ElevatedButton.styleFrom(
                  elevation: 20,
                  backgroundColor: Theme.of(context).colorScheme.outline,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: getTrips(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No trips found"));
                }

                List<Map<String, dynamic>> trips = snapshot.data!;

                return ListView.builder(
                  itemCount: trips.length,
                  itemBuilder: (context, index) {
                    var trip = trips[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 15),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SummeryOfTheTourPlanning(
                                collectionName: 'tour_plan',
                                documentId: trip['id'],
                              ),
                            ),
                          );
                        },
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.1,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 7,
                                offset: const Offset(
                                    0, 3), // changes position of shadow
                              ),
                            ],
                            border: Border.all(
                                color: Colors.grey, width: 2), // Outline border
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white, // Background color (optional)
                          ),
                          child: ListTile(
                            //tileColor: Colors.green[50],
                            isThreeLine: true,
                            title: Text(trip['group-name'] ?? 'Unnamed Trip',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18)),
                            subtitle: Text(
                                trip['destination'] ?? 'Unknown Location',
                                style: const TextStyle(fontSize: 16)),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(trip['date'] ?? 'No Date'),
                                const SizedBox(
                                  height: 5,
                                ),
                                SizedBox(
                                  height: 35, // Set button height
                                  width: 100,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              SummeryOfTheTourPlanning(
                                            collectionName: 'tour_plan',
                                            documentId: trip['id'],
                                          ),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Theme.of(context).colorScheme.outline,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            10), // Rounded corners
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5),
                                      textStyle: const TextStyle(
                                          fontSize:
                                              12), // Adjust font size if needed
                                    ),
                                    child: const Text("Check"),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
