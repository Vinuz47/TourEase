import 'package:data_management_project/screens/home/views/main_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SummeryOfTheTourPlanning extends StatelessWidget {
  final String collectionName;
  final String documentId;

  SummeryOfTheTourPlanning({
    super.key,
    required this.collectionName,
    required this.documentId,
  });
  String groupName = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 88, 156, 91),
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
        title: const Text(
          'Summery of the Planning',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection(collectionName)
            .doc(documentId)
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
            child: Column(
              // crossAxisAlignment: CrossAxisAlignment.start,
              
              children: [
                //centeer welcome topic
                const Center(
                    child: Text('Welcome to the \nTour-Ease',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          color: Colors.red,
                        ))),

                //group name
                Padding(
                  padding: const EdgeInsets.only(right: 22, left: 12, top: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.assistant_photo_sharp,
                            color: Color.fromARGB(255, 88, 156, 91),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text('Team knows as: ',
                              style: TextStyle(
                                color: Color.fromARGB(255, 12, 14, 15),
                                fontWeight: FontWeight.w400,
                                fontSize: 18,
                              )),
                        ],
                      ),
                      Text(data['group-name'],
                          style: const TextStyle(
                              color: Color.fromARGB(255, 15, 49, 77),
                              fontWeight: FontWeight.w500,
                              fontSize: 20,
                              fontStyle: FontStyle.italic)),
                    ],
                  ),
                ),

                //destination
                Padding(
                  padding: const EdgeInsets.only(right: 22, left: 12, top: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.assistant_photo_sharp,
                            color: Color.fromARGB(255, 88, 156, 91),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text('Destination: ',
                              style: TextStyle(
                                color: Color.fromARGB(255, 12, 14, 15),
                                fontWeight: FontWeight.w400,
                                fontSize: 18,
                              )),
                        ],
                      ),
                      Text(data['destination'],
                          style: const TextStyle(
                              color: Color.fromARGB(255, 15, 49, 77),
                              fontWeight: FontWeight.w500,
                              fontSize: 20,
                              fontStyle: FontStyle.italic)),
                    ],
                  ),
                ),

                //date
                Padding(
                  padding: const EdgeInsets.only(right: 22, left: 12, top: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.assistant_photo_sharp,
                            color: Color.fromARGB(255, 88, 156, 91),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text('Trip going on: ',
                              style: TextStyle(
                                color: Color.fromARGB(255, 12, 14, 15),
                                fontWeight: FontWeight.w400,
                                fontSize: 18,
                              )),
                        ],
                      ),
                      Text(data['date'],
                          style: const TextStyle(
                              color: Color.fromARGB(255, 15, 49, 77),
                              fontWeight: FontWeight.w500,
                              fontSize: 20,
                              fontStyle: FontStyle.italic)),
                    ],
                  ),
                ),

                //transport method
                Padding(
                  padding: const EdgeInsets.only(right: 22, left: 12, top: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.assistant_photo_sharp,
                            color: Color.fromARGB(255, 88, 156, 91),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text('Transport Method: ',
                              style: TextStyle(
                                color: Color.fromARGB(255, 12, 14, 15),
                                fontWeight: FontWeight.w400,
                                fontSize: 18,
                              )),
                        ],
                      ),
                      Text(data['transport-method'],
                          style: const TextStyle(
                              color: Color.fromARGB(255, 15, 49, 77),
                              fontWeight: FontWeight.w500,
                              fontSize: 20,
                              fontStyle: FontStyle.italic)),
                    ],
                  ),
                ),

                //number of people
                Padding(
                  padding: const EdgeInsets.only(right: 22, left: 12, top: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.assistant_photo_sharp,
                            color: Color.fromARGB(255, 88, 156, 91),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text('Count of Group: ',
                              style: TextStyle(
                                color: Color.fromARGB(255, 12, 14, 15),
                                fontWeight: FontWeight.w400,
                                fontSize: 18,
                              )),
                        ],
                      ),
                      Text(data['number-of-people'],
                          style: const TextStyle(
                              color: Color.fromARGB(255, 15, 49, 77),
                              fontWeight: FontWeight.w500,
                              fontSize: 20,
                              fontStyle: FontStyle.italic)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color.fromARGB(255, 88, 156, 91),
        notchMargin: 1,
        shape: const CircularNotchedRectangle(),
        child: Padding(
          padding: const EdgeInsets.only(left: BorderSide.strokeAlignCenter),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Back',
                    style: TextStyle(
                        color: Color.fromARGB(240, 0, 0, 0),
                        fontWeight: FontWeight.w600)),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MainScreen(groupName: groupName,)),
                  );
                },
                child: const Text('Continue',
                    style: TextStyle(
                        color: Color.fromARGB(240, 0, 0, 0),
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
