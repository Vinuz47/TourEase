import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_management_project/data/city_data.dart';
import 'package:data_management_project/data/city_model.dart';
import 'package:data_management_project/screens/home/views/display_tour_planning_data.dart';
import 'package:data_management_project/screens/home/views/main_screen.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TourPlanningPage extends StatefulWidget {
  const TourPlanningPage({super.key});

  @override
  State<TourPlanningPage> createState() => _TourPlanningPageState();
}

final dropDownKey = GlobalKey<DropdownSearchState<String>>();
final _formKey = GlobalKey<FormState>();
TextEditingController _destinationController = TextEditingController();
TextEditingController _groupNameController = TextEditingController();
TextEditingController _groupCounterController = TextEditingController();

DateTime? _selectedDate;
String? _selectedTransportMethod;
City? selectedCity;
double? selectedLatitude;
double? selectedLongitude;
final List<String> transportMethodList = ['Train', 'Bus', 'Car', 'Van', 'Other'];

class _TourPlanningPageState extends State<TourPlanningPage> {
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

  /// This function returns the latitude & longitude in double format.
  void onCitySelected(String? cityName) {
    if (cityName != null) {
      City city = cities.firstWhere((city) => city.name == cityName);
      setState(() {
        selectedCity = city;
        selectedLatitude = city.latitude;
        selectedLongitude = city.longitude;
      });

      // Print the values in console
      // print("Selected City: ${selectedCity!.name}");
      // print("Latitude: ${selectedLatitude}");
      // print("Longitude: ${selectedLongitude}");
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      onCitySelected(_destinationController.text);
      try {
        // Store data in Firestore
        DocumentReference docRef = await FirebaseFirestore.instance.collection('tour_plan').add({
          'date': DateFormat('yyyy-MM-dd').format(_selectedDate!),
          'destination': _destinationController.text[0].toUpperCase() + _destinationController.text.substring(1),
          'transport-method': _selectedTransportMethod,
          'group-name': _groupNameController.text,
          'number-of-people': _groupCounterController.text,
          "latitude": selectedLatitude,
          "longitude": selectedLongitude,
          'createdAt': Timestamp.now(),
        });

        String docId = docRef.id;
        print("Docement id: $docId");

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Form submitted successfully!'),
        ));

        // Clear the form
        _formKey.currentState!.reset();

        Future.delayed(const Duration(seconds: 2), () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SummeryOfTheTourPlanning(
                collectionName: 'tour_plan',
                documentId: docId,
              ),
            ),
          );
        });

        setState(() {
          _selectedTransportMethod = null;
          _selectedDate = null;
          _groupNameController.clear();
          _destinationController.clear();
          _groupCounterController.clear();
        });
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to submit form: $error'),
        ));
      }
    }
  }

  Future<List<String>> getCityList(String filter, dynamic infiniteScrollProps) async {
    return cities.map((city) => city.name).where((name) => name.toLowerCase().contains(filter.toLowerCase())).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 88, 156, 91),
        foregroundColor: const Color.fromARGB(255, 38, 39, 38),
        title: const Text(
          "Tour Planning page",
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 12, left: 20, right: 20, bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  decoration: BoxDecoration(color: const Color.fromARGB(255, 120, 182, 122), borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Card(
                                elevation: 20,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            "Tour Planning Date: ",
                                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                                          ),
                                          ElevatedButton(
                                              onPressed: () => _selectDate(context),
                                              style: const ButtonStyle(
                                                backgroundColor: WidgetStatePropertyAll(Color.fromARGB(255, 33, 31, 31)),
                                                foregroundColor: WidgetStatePropertyAll(Colors.white),
                                              ),
                                              child: const Text("Select date")),
                                        ],
                                      ),
                                      _selectedDate != null ? Text("Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}") : const SizedBox()
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Card(
                                elevation: 20,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: MediaQuery.of(context).size.width * 1,
                                        child: const AutoSizeText(
                                          "Arrival Destination: ",
                                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      SizedBox(
                                        width: MediaQuery.of(context).size.width * 1,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            DropdownSearch<String>(
                                              key: dropDownKey,
                                              selectedItem: null,
                                              items: getCityList,
                                              onChanged: (selectedCity) {
                                                print("Selected City: $selectedCity");
                                                setState(() {
                                                  _destinationController.text = selectedCity!;
                                                });
                                              },
                                              dropdownBuilder: (context, selectedItem) {
                                                return Text(
                                                  selectedItem ?? "Select a City",
                                                  style: const TextStyle(fontSize: 16, color: Colors.black),
                                                );
                                              },
                                              popupProps: const PopupProps.menu(
                                                fit: FlexFit.loose,
                                                constraints: BoxConstraints(),
                                                showSearchBox: true,
                                                searchFieldProps: TextFieldProps(
                                                  decoration: InputDecoration(
                                                    labelText: "Search city",
                                                    border: OutlineInputBorder(),
                                                  ),
                                                ),
                                              ),
                                              decoratorProps: const DropDownDecoratorProps(
                                                decoration: InputDecoration(
                                                  //labelText: "Select a City",
                                                  border: OutlineInputBorder(),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        // TextFormField(
                                        //   controller: _destinationController,
                                        //   keyboardType: TextInputType.name,
                                        //   decoration: InputDecoration(
                                        //     hintText: "Enter Destination",
                                        //     hintStyle: const TextStyle(
                                        //         fontSize: 15,
                                        //         fontWeight: FontWeight.w400),
                                        //     border: OutlineInputBorder(
                                        //         borderRadius:
                                        //             BorderRadius.circular(10.0),
                                        //         borderSide: const BorderSide(
                                        //           color: Colors.blue,
                                        //         )),
                                        //   ),
                                        //   validator: (value) {
                                        //     if (value == null ||
                                        //         value.isEmpty) {
                                        //       return 'Please enter destination';
                                        //     }
                                        //     return null;
                                        //   },
                                        // ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Card(
                                elevation: 20,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: MediaQuery.of(context).size.width * 0.4,
                                        child: const AutoSizeText(
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          "Enter Transport Method: ",
                                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      SizedBox(
                                        //width: MediaQuery.of(context).size.width * 0.2,
                                        child: DropdownButtonFormField<String>(
                                          decoration: InputDecoration(
                                            labelText: 'Select method',
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(10.0),
                                            ),
                                          ),
                                          value: _selectedTransportMethod, // Currently selected value
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              _selectedTransportMethod = newValue; // Update the selected value
                                            });
                                          },
                                          items: transportMethodList.map<DropdownMenuItem<String>>((String itemOfCategories) {
                                            return DropdownMenuItem<String>(
                                              value: itemOfCategories,
                                              child: Text(itemOfCategories),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Card(
                                elevation: 20,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                        width: MediaQuery.of(context).size.width * 0.4,
                                        child: const AutoSizeText(
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          "Enter Group Name: ",
                                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                                        ),
                                      ),
                                      SizedBox(
                                        width: MediaQuery.of(context).size.width * 0.3,
                                        child: TextFormField(
                                          controller: _groupNameController,
                                          keyboardType: TextInputType.name,
                                          decoration: InputDecoration(
                                            hintText: "Type Name",
                                            hintStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                                            border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(10.0),
                                                borderSide: const BorderSide(
                                                  color: Colors.blue,
                                                )),
                                          ),
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Please enter name';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Card(
                                elevation: 20,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                        width: MediaQuery.of(context).size.width * 0.4,
                                        child: const AutoSizeText(
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          "Number of People in group: ",
                                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                                        ),
                                      ),
                                      SizedBox(
                                        width: MediaQuery.of(context).size.width * 0.3,
                                        child: TextFormField(
                                          controller: _groupCounterController,
                                          keyboardType: const TextInputType.numberWithOptions(),
                                          decoration: InputDecoration(
                                            hintText: "Enter Amount",
                                            hintStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                                            border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(10.0),
                                                borderSide: const BorderSide(
                                                  color: Colors.blue,
                                                )),
                                          ),
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Please enter amount';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: _submitForm,
                              child: const Text('Submit'),
                            ),
                          ],
                        )),
                  )),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  style: ButtonStyle(backgroundColor: WidgetStateProperty.all(const Color.fromARGB(255, 6, 27, 7))),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MainScreen(
                          groupName: "Guys",
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    "Skip Planning",
                    style: TextStyle(color: Colors.white),
                  ))
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Action when the button is pressed
          print('FAB Pressed');
        },
        child: const Icon(Icons.add), // Icon for the FAB
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat, // Optional location adjustment
    );
  }
}
