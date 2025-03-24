import 'dart:convert';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class WeatherPredictionScreen extends StatefulWidget {
  final String date;
  final String latitude;
  final String longitude;
  final String city;
  const WeatherPredictionScreen(
      {super.key,
      required this.date,
      required this.latitude,
      required this.longitude,
      required this.city});

  @override
  State<WeatherPredictionScreen> createState() =>
      _WeatherPredictionScreenState();
}

class _WeatherPredictionScreenState extends State<WeatherPredictionScreen> {
  String prediction = '';
  String apiKey = '9DGX7CF4675ZQU8EP5ELGRAWN';
  String tempMean = '';
  String tempMax = '';
  String tempMin = '';
  String selectSunrise = '';
  String selectSunset = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    getPrediction();
  }

  double fahrenheitToCelsius(double fahrenheit) {
    return (fahrenheit - 32) * 5 / 9;
  }

//get future temperature and precipitation.
  Future<Map<String, dynamic>> fetchTemperature(
      String date, String longitude, String latitude) async {
    String url =
        'https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline/$longitude,$latitude/$date?key=$apiKey&include=days&elements=datetime,tempmax,tempmin,temp,feelslikemax,feelslikemin,feelslike,precip,sunrise,sunset';
    final Uri uri = Uri.parse(url);

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        //print("done");
        final data = json.decode(response.body);

        // Extract temperature details from the response
        final tempMax = (data['days'][0]['tempmax'] as num).toDouble();
        final tempMin = (data['days'][0]['tempmin'] as num).toDouble();
        final tempMean = (data['days'][0]['temp'] as num).toDouble();
        final apparentTempMax =
            (data['days'][0]['feelslikemax'] as num).toDouble();
        final apparentTempMin =
            (data['days'][0]['feelslikemin'] as num).toDouble();
        final apparentTempMean =
            (data['days'][0]['feelslike'] as num).toDouble();
        final precip = (data['days'][0]['precip'] as num).toDouble();

        // Parse sunrise and sunset to DateTime
        final sunrise = data['days'][0]['sunrise'];
        final sunset = data['days'][0]['sunset'];

        return {
          'tempMax': tempMax,
          'tempMin': tempMin,
          'tempMean': tempMean,
          'apparentTempMax': apparentTempMax,
          'apparentTempMin': apparentTempMin,
          'apparentTempMean': apparentTempMean,
          'precip': precip,
          'sunrise': sunrise,
          'sunset': sunset
        };
      } else {
        throw Exception(
            'Failed to fetch data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      //print('Error fetching data: $e');
      rethrow;
    }
  }

  Future<void> getPrediction() async {
    //if (widget.date == null) return;

    try {
      // print("came here");
      final temperatureData = await fetchTemperature(
          widget.date, widget.latitude, widget.longitude);

      setState(() {
        tempMax = fahrenheitToCelsius(temperatureData['tempMax']!).toString();
        tempMin = fahrenheitToCelsius(temperatureData['tempMin']!).toString();
        tempMean = fahrenheitToCelsius(temperatureData['tempMean']!).toString();
        selectSunrise = temperatureData['sunrise'];
        selectSunset = temperatureData['sunset'];
      });

      final response = await http.post(
        Uri.parse(
            'http://10.33.2.170:5000/predict'), // Replace with your Flask server IP
        headers: {'Content-Type': 'application/json'},

        body: jsonEncode({
          //'date': selectedDate.toString(),
          'latitude': double.parse(widget.latitude),
          'longitude': double.parse(widget.longitude),
          'temperature_2m_max':
              fahrenheitToCelsius(temperatureData['tempMax']!),
          'temperature_2m_min':
              fahrenheitToCelsius(temperatureData['tempMin']!),
          'temperature_2m_mean':
              fahrenheitToCelsius(temperatureData['tempMean']!),
          'apparent_temperature_max':
              fahrenheitToCelsius(temperatureData['apparentTempMax']!),
          'apparent_temperature_min':
              fahrenheitToCelsius(temperatureData['apparentTempMin']!),
          'apparent_temperature_mean':
              fahrenheitToCelsius(temperatureData['apparentTempMean']!),
          'precipitation_sum': temperatureData['precip']! * 25.4,
        }),
      );
      print(double.parse(tempMax));
      print(fahrenheitToCelsius(temperatureData['tempMax']!));
      print(fahrenheitToCelsius(temperatureData['tempMin']!));
      print(fahrenheitToCelsius(temperatureData['tempMean']!));
      print(fahrenheitToCelsius(temperatureData['apparentTempMax']!));
      print(fahrenheitToCelsius(temperatureData['apparentTempMin']!));
      print(fahrenheitToCelsius(temperatureData['apparentTempMean']!));
      print(temperatureData['precip']! * 25.4);
      print(temperatureData['sunrise']);
      print(temperatureData['sunset']);

      //  print("Status code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        setState(() {
          prediction = "${result['weather_code']}";
        });
      } else {
        setState(() {
          prediction = 'Error: ${response.reasonPhrase}';
        });
        //print(prediction);
      }
    } catch (e) {
      setState(() {
        prediction = 'Error: $e';
      });
      //print(prediction);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget displayPrediction(String prediction) {
    switch (prediction) {
      case 'Sunny':
        return Image.asset(
          'assets/predict/sunny.png',
          scale: 1,
        );
      //break;
      case 'Mid Sunny':
        return Image.asset(
          'assets/predict/moderatesunny.png',
          scale: 1,
        );
      //break;
      case 'Cloudy':
        return Image.asset(
          'assets/predict/lightcloudy.png',
          scale: 1,
        );
      // break;
      case 'Heavy Cloudy':
        return Image.asset(
          'assets/predict/heavycloudy.png',
          scale: 1,
        );
      //break;
      case 'Light drizzle':
        return Image.asset(
          'assets/predict/lightdrizle.png',
          scale: 1,
        );
      //break;
      case 'Moderate drizzle':
        return Image.asset(
          'assets/predict/moderatedrizle.png',
          scale: 1,
        );
      //break;
      case 'Heavy drizzle':
        return Image.asset(
          'assets/predict/heavydrizle.png',
          scale: 1,
        );
      //break;
      case 'Light Rain':
        return Image.asset(
          'assets/predict/lightrain.png',
          scale: 1,
        );
      //break;
      case 'Moderate Rain':
        return Image.asset(
          'assets/predict/moderaterain.png',
          scale: 1,
        );
      //break;
      case 'Heavy Rain with Thunder':
        return Image.asset(
          'assets/predict/heavyrain.png',
          scale: 1,
        );
      //break;
      default:
        return const Center(
            child: Text('No prediction yet.',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)));
    }
  }

  //greeting widget
  String getGreeting() {
    int hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Good Morning';
    } else if (hour >= 12 && hour < 16) {
      return 'Good Afternoon';
    } else if (hour >= 16 && hour < 20) {
      return 'Good Evening';
    } else {
      return 'Good Night';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
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
        body: isLoading
            ? const Center(
                child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Colors.white,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Loading...',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ))
            : Padding(
                padding:
                    const EdgeInsets.fromLTRB(40, 1.2 * kToolbarHeight, 40, 20),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // const Text(
                            //   '📍 Weather name',
                            //   style: TextStyle(
                            //       color: Colors.white, fontWeight: FontWeight.w300),
                            // ),
                            const SizedBox(height: 18),
                            Center(
                              child: Text(
                                getGreeting(),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            //getWeatherIcon(state.weather.weatherConditionCode!),
                            // Image.asset(
                            //   'assets/images/2.png',
                            //   scale: 1,
                            // ),
                            displayPrediction(prediction),
                            Center(
                              child: Text(
                                //'mean temp °C',
                                prediction,
                                //"${double.parse(tempMean).toStringAsFixed(2)} °C",
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 35,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            Center(
                              child: Text(
                                widget.city,
                                //"📍"
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 25,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Center(
                              child: Text(
                                widget.date,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w300),
                              ),
                            ),
                            const SizedBox(height: 30),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Image.asset(
                                      'assets/images/11.png',
                                      scale: 8,
                                    ),
                                    const SizedBox(width: 5),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Sunrise',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w300),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          selectSunrise,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                                Row(
                                  children: [
                                    Image.asset(
                                      'assets/images/12.png',
                                      scale: 8,
                                    ),
                                    const SizedBox(width: 5),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Sunset',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w300),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          selectSunset,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 5.0),
                              child: Divider(
                                color: Colors.grey,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(children: [
                                  Image.asset(
                                    'assets/images/13.png',
                                    scale: 8,
                                  ),
                                  const SizedBox(width: 5),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Temp Max',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w300),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        "${double.parse(tempMax).toStringAsFixed(2)} °C",
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  )
                                ]),
                                Row(children: [
                                  Image.asset(
                                    'assets/images/14.png',
                                    scale: 8,
                                  ),
                                  const SizedBox(width: 5),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Temp Min',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w300),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        "${double.parse(tempMin).toStringAsFixed(2)} °C",
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  )
                                ])
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ));
  }
}
