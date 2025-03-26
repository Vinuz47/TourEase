import 'dart:convert';
import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:data_management_project/constant.dart';
import 'package:data_management_project/screens/home/views/weather_prediction/weather_prediction_screen.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class SameLocationOtherDatesScreen extends StatefulWidget {
  final String city;
  final String longitude;
  final String latitude;

  const SameLocationOtherDatesScreen(
      {super.key,
      required this.city,
      required this.longitude,
      required this.latitude});

  @override
  State<SameLocationOtherDatesScreen> createState() =>
      _SameLocationOtherDatesScreenState();
}

class _SameLocationOtherDatesScreenState
    extends State<SameLocationOtherDatesScreen> {
  String apiKey = API_KEY;
  bool isLoading = true;
  List<Map<String, dynamic>> predictions = [];

  @override
  void initState() {
    super.initState();
    fetch14DayPredictions();
  }

  double fahrenheitToCelsius(double fahrenheit) {
    return (fahrenheit - 32) * 5 / 9;
  }

  List<String> generateNext14Days() {
    return List.generate(15, (index) {
      return DateFormat('yyyy-MM-dd')
          .format(DateTime.now().add(Duration(days: index)));
    });
  }

  Future<Map<String, dynamic>> fetchTemperature(String date) async {
    String url =
        'https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline/${widget.latitude},${widget.longitude}/$date?key=$apiKey&include=days&elements=datetime,tempmax,tempmin,temp,feelslikemax,feelslikemin,feelslike,precip,sunrise,sunset';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final dayData = data['days'][0];

      return {
        'date': date,
        'tempMax': fahrenheitToCelsius((dayData['tempmax'] as num).toDouble()),
        'tempMin': fahrenheitToCelsius((dayData['tempmin'] as num).toDouble()),
        'tempMean': fahrenheitToCelsius((dayData['temp'] as num).toDouble()),
        'apparentTempMax':
            fahrenheitToCelsius((dayData['feelslikemax'] as num).toDouble()),
        'apparentTempMin':
            fahrenheitToCelsius((dayData['feelslikemin'] as num).toDouble()),
        'apparentTempMean':
            fahrenheitToCelsius((dayData['feelslike'] as num).toDouble()),
        'precip': (dayData['precip'] as num).toDouble() *
            25.4, // Convert inches to mm
        'sunrise': dayData['sunrise'],
        'sunset': dayData['sunset']
      };
    } else {
      throw Exception('Failed to fetch weather data');
    }
  }

  Future<void> fetch14DayPredictions() async {
    try {
      List<String> dates = generateNext14Days();
      List<Map<String, dynamic>> tempPredictions = [];

      for (String date in dates) {
        final tempData = await fetchTemperature(date);

        final response = await http.post(
          Uri.parse(PREDICT_ENDPOINT),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'latitude': double.parse(widget.latitude),
            'longitude': double.parse(widget.longitude),
            'temperature_2m_max': tempData['tempMax'],
            'temperature_2m_min': tempData['tempMin'],
            'temperature_2m_mean': tempData['tempMean'],
            'apparent_temperature_max': tempData['apparentTempMax'],
            'apparent_temperature_min': tempData['apparentTempMin'],
            'apparent_temperature_mean': tempData['apparentTempMean'],
            'precipitation_sum': tempData['precip'],
          }),
        );

        if (response.statusCode == 200) {
          final result = jsonDecode(response.body);
          tempData['prediction'] = result['weather_code'];
        } else {
          tempData['prediction'] = 'Error: ${response.reasonPhrase}';
        }

        tempPredictions.add(tempData);
      }

      setState(() {
        predictions = tempPredictions;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget displayPrediction(String prediction) {
    Map<String, String> icons = {
      'Sunny': 'assets/predict/sunny.png',
      'Mid Sunny': 'assets/predict/moderatesunny.png',
      'Cloudy': 'assets/predict/lightcloudy.png',
      'Heavy Cloudy': 'assets/predict/heavycloudy.png',
      'Light drizzle': 'assets/predict/lightdrizle.png',
      'Moderate drizzle': 'assets/predict/moderatedrizle.png',
      'Heavy drizzle': 'assets/predict/heavydrizle.png',
      'Light Rain': 'assets/predict/lightrain.png',
      'Moderate Rain': 'assets/predict/moderaterain.png',
      'Heavy Rain with Thunder': 'assets/predict/heavyrain.png',
    };

    return Image.asset(
      icons[prediction] ?? 'assets/predict/default.png',
      scale: 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: true,
        title: Text(
          textAlign: TextAlign.center,
          "Best Days to travel\n${widget.city}",
          style: const TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle:
            const SystemUiOverlayStyle(statusBarBrightness: Brightness.dark),
      ),
      body: isLoading
          ? const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(child: CircularProgressIndicator(color: Colors.white)),
                Text("Loading...",
                    style: TextStyle(color: Colors.white, fontSize: 20)),
              ],
            )
          : Padding(
              padding:
                  const EdgeInsets.fromLTRB(15, 0.2 * kToolbarHeight, 15, 20),
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
                        decoration:
                            const BoxDecoration(color: Colors.transparent),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: ListView.builder(
                        itemCount: predictions.length,
                        itemBuilder: (context, index) {
                          final dayData = predictions[index];
                          return SizedBox(
                            // height: 200,
                            child: Card(
                              color: Colors.transparent,
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.white, // Set border color
                                    width: 2, // Set border width
                                  ),
                                  borderRadius: BorderRadius.circular(
                                      10), // Optional: Add rounded corners
                                ),
                                child: ListTile(
                                  isThreeLine: true,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  // tileColor: const Color.fromARGB(255, 25, 219, 28),
                                  leading: SizedBox(
                                    //color: const Color.fromARGB(255, 243, 46, 200),

                                    width: MediaQuery.of(context).size.width *
                                        0.15,
                                    // height:
                                    // MediaQuery.of(context).size.height * 0.8,
                                    child: Column(
                                        // mainAxisSize: MainAxisSize
                                        //     .min, // Prevents unnecessary expansion
                                        mainAxisAlignment: MainAxisAlignment
                                            .center, // Centers items vertically
                                        spacing: 6,
                                        children: [
                                          Expanded(
                                            child:
                                                // if(dayData['prediction'] == 'Sunny'|| dayData['prediction'] == 'Mid Sunny'|| dayData['prediction'] == 'Cloudy'|| dayData['prediction'] == 'Heavy Cloudy'|| dayData['prediction'] == 'Light drizzle')

                                                displayPrediction(
                                                    dayData['prediction']),
                                          ),
                                        ]),
                                  ),
                                  title: AutoSizeText(
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    dayData['prediction'] ?? 'N/A',
                                    style: const TextStyle(
                                        color:
                                            Color.fromARGB(255, 255, 255, 255),
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${dayData['date']} ",
                                        //"Min: ${dayData['tempMin'].toStringAsFixed(1)}°C",
                                        style: const TextStyle(
                                            color: Color.fromARGB(
                                                179, 255, 255, 255)),
                                      ),
                                      (dayData['prediction'] == 'Sunny' ||
                                              dayData['prediction'] ==
                                                  'Mid Sunny' ||
                                              dayData['prediction'] ==
                                                  'Cloudy' ||
                                              dayData['prediction'] ==
                                                  'Heavy Cloudy' ||
                                              dayData['prediction'] ==
                                                  'Light drizzle')
                                          ? const Text(
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              "Good to travel",
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color.fromARGB(
                                                      255, 56, 254, 21)),
                                            )
                                          : const Text(
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              "Not good to travel",
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color.fromARGB(
                                                    255,
                                                    238,
                                                    3,
                                                    3,
                                                  )),
                                            ),
                                    ],
                                  ),
                                  trailing: IconButton(
                                      iconSize: 30,
                                      icon: const Icon(Icons.arrow_forward_ios),
                                      color: Colors.white,
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                WeatherPredictionScreen(
                                              city: widget.city,
                                              longitude: widget.longitude,
                                              latitude: widget.latitude,
                                              date: dayData['date'],
                                            ),
                                          ),
                                        );
                                      }),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
