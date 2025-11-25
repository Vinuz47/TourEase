import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_management_project/screens/home/views/main_screen.dart';
import 'package:data_management_project/screens/home/views/weather_prediction_screen.dart';
import 'package:flutter/material.dart';

class SummeryOfTheTourPlanning extends StatefulWidget {
  final String collectionName;
  final String documentId;

  const SummeryOfTheTourPlanning({
    super.key,
    required this.collectionName,
    required this.documentId,
  });

  @override
  State<SummeryOfTheTourPlanning> createState() => _SummeryOfTheTourPlanningState();
}

class _SummeryOfTheTourPlanningState extends State<SummeryOfTheTourPlanning> {
  String groupName = '';

  Widget summaryCard(String title, String subtitle, IconData icon, Color iconBg) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 6,
      shadowColor: Colors.green[800],
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        leading: CircleAvatar(
          backgroundColor: iconBg,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 15, color: Colors.black87),
        ),
        trailing: Icon(
          size: 30,
          Icons.edit_calendar_rounded,
          color: Colors.green[800],
        ),
      ),
    );
  }

  Widget gradientButton(String text, IconData icon, VoidCallback onPressed) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF56AB2F), Color(0xFFA8E063)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.4),
              blurRadius: 6,
              offset: const Offset(2, 4),
            )
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Welcome to Tour-Ease',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.green.withOpacity(0.9),
        elevation: 16,
        centerTitle: true,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.blue.withOpacity(0.1)),
          ),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection(widget.collectionName).doc(widget.documentId).get(),
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
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              );
            }

            var data = snapshot.data!.data() as Map<String, dynamic>;
            groupName = data['group-name'];

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        summaryCard('Group Name', data['group-name'], Icons.groups_2, Colors.green),
                        summaryCard('Destination', data['destination'], Icons.location_on, Colors.orange),
                        summaryCard('Trip Date', data['date'], Icons.date_range, Colors.blue),
                        summaryCard('Transport Method', data['transport-method'], Icons.directions_car, Colors.purple),
                        summaryCard('Group Count', data['number-of-people'], Icons.people, Colors.teal),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      gradientButton(
                        'Weather Prediction',
                        Icons.cloud,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WeatherPredictionScreen(
                                date: data['date'],
                                longitude: (data['longitude']).toString(),
                                latitude: (data['latitude']).toString(),
                                city: data['destination'],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      gradientButton(
                        'Continue',
                        Icons.arrow_forward,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MainScreen(groupName: groupName),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
