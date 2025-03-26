import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DifferentLocationSameDate extends StatefulWidget {
  final String date;
  const DifferentLocationSameDate({super.key, required this.date});

  @override
  State<DifferentLocationSameDate> createState() =>
      _DifferentLocationSameDateState();
}

Widget _categoriesButton(BuildContext context, String title, String subtitle,
    {Function()? onPressed}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: ElevatedButton(
        style: ButtonStyle(
            side: WidgetStateProperty.all<BorderSide>(
                const BorderSide(color: Colors.white, width: 2)),
            shape: WidgetStateProperty.all<OutlinedBorder>(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            backgroundColor:
                WidgetStateProperty.all<Color>(Colors.transparent)),
        onPressed: () {},
        child: Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(color: Colors.white, fontSize: 20)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: Text(
                        maxLines: 2,
                        "($subtitle)",
                        style: const TextStyle(
                            color: Color.fromARGB(255, 250, 229, 229),
                            fontSize: 10)),
                  ),
                  ElevatedButton(
                      onPressed: () {},
                      style: ButtonStyle(
                          minimumSize:
                              WidgetStateProperty.all<Size>(const Size(50, 30)),
                          shape: WidgetStateProperty.all<OutlinedBorder>(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10))),
                          backgroundColor:
                              WidgetStateProperty.all<Color>(Colors.white70)),
                      child: const Text("Predict",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 10)))
                ],
              )
            ],
          ),
        )),
  );
}

class _DifferentLocationSameDateState extends State<DifferentLocationSameDate> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        extendBodyBehindAppBar: false,
        appBar: AppBar(
          centerTitle: true,
          automaticallyImplyLeading: true,
          title: const Text(
            textAlign: TextAlign.center,
            "Categories of tour types",
            style: TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          foregroundColor: Colors.white,
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle:
              const SystemUiOverlayStyle(statusBarBrightness: Brightness.dark),
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(15, 0.2 * kToolbarHeight, 15, 20),
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Stack(
              children: [
                Align(
                  alignment: const AlignmentDirectional(3, -0.3),
                  child: Container(
                    height: 300,
                    width: 300,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: Colors.deepPurple),
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
                    decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 141, 228, 41)),
                  ),
                ),
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 100.0, sigmaY: 100.0),
                  child: Container(
                    decoration: const BoxDecoration(color: Colors.transparent),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Center(
                    child: SizedBox(
                      child: SingleChildScrollView(
                        child: Column(
                          //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            
                            _categoriesButton(context, "Southern Costal Tour",
                                "Galle, Weligama, Matara, Hambantota"),
                            _categoriesButton(context, "Eastern Costal Tour",
                                "Trincomalee, Kalmunei"),
                            _categoriesButton(context, "Western Costal Tour",
                                "Mount Lavinia, Negambo, Kaluthara, Benthota"),
                            _categoriesButton(context, "Northern Costal Tour",
                                "Jaffna, Mannar, Puthalam"),
                            _categoriesButton(context, "Country Side Tour",
                                "Rathnapura, Badulla, Kurunagala, Kandy, Mathle, Hatton"),
                            _categoriesButton(context, "Western Area Tour",
                                "Colombo, Gampaha, Maharagama, Moratuwa,"),
                            
                            // ElevatedButton(
                            //     onPressed: () {},
                            //     child: const Text("Eastern Costal Tour")),
                            // ElevatedButton(
                            //     onPressed: () {},
                            //     child: const Text("Western Costal Tour")),
                            // ElevatedButton(
                            //     onPressed: () {},
                            //     child: const Text("Northern Costal Tour")),
                            // ElevatedButton(
                            //     onPressed: () {},
                            //     child: const Text("Country Side Tour")),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
