import 'dart:convert';
import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:data_management_project/constant.dart';
import 'package:data_management_project/screens/home/views/weather_prediction/weather_prediction_screen.dart';
import 'package:http/http.dart' as http;
import 'package:data_management_project/data/city_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DifferentLocationSameDateScreen extends StatefulWidget {
  final String date;
  final String appBarTitle;
  final List<City> locations;

  const DifferentLocationSameDateScreen(
      {super.key,
      required this.date,
      required this.appBarTitle,
      required this.locations});

  @override
  State<DifferentLocationSameDateScreen> createState() =>
      _DifferentLocationSameDateScreenState();
}

class _DifferentLocationSameDateScreenState
    extends State<DifferentLocationSameDateScreen> {
  final String apiKey = API_KEY;
  final String predictEndpoint = PREDICT_ENDPOINT;
  bool isLoading = true;
  Map<String, String> weatherPredictions = {};
  @override
  void initState() {
    super.initState();
    fetchWeatherForLocations();
  }

  double fahrenheitToCelsius(double fahrenheit) {
    return (fahrenheit - 32) * 5 / 9;
  }

  Future<Map<String, dynamic>> fetchTemperature(City city) async {
    String url =
        'https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline/${city.latitude},${city.longitude}/${widget.date}?key=$apiKey&include=days&elements=datetime,tempmax,tempmin,temp,feelslikemax,feelslikemin,feelslike,precip,sunrise,sunset';

    final Uri uri = Uri.parse(url);

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        return {
          'tempMax': (data['days'][0]['tempmax'] as num).toDouble(),
          'tempMin': (data['days'][0]['tempmin'] as num).toDouble(),
          'tempMean': (data['days'][0]['temp'] as num).toDouble(),
          'apparentTempMax':
              (data['days'][0]['feelslikemax'] as num).toDouble(),
          'apparentTempMin':
              (data['days'][0]['feelslikemin'] as num).toDouble(),
          'apparentTempMean': (data['days'][0]['feelslike'] as num).toDouble(),
          'precip': (data['days'][0]['precip'] as num).toDouble(),
          'sunrise': data['days'][0]['sunrise'],
          'sunset': data['days'][0]['sunset'],
        };
      } else {
        throw Exception('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      return {'error': 'Failed to fetch data'};
    }
  }

  Future<String> getPrediction(City city) async {
    try {
      final temperatureData = await fetchTemperature(city);

      if (temperatureData.containsKey('error')) {
        return 'Error fetching data';
      }

      final response = await http.post(
        Uri.parse(predictEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'latitude': city.latitude,
          'longitude': city.longitude,
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

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        return result['weather_code'];
      } else {
        return 'Error: ${response.reasonPhrase}';
      }
    } catch (e) {
      return 'Error: $e';
    }
  }

  Future<void> fetchWeatherForLocations() async {
    List<Future<void>> requests = widget.locations.map((city) async {
      String prediction = await getPrediction(city);
      setState(() {
        weatherPredictions[city.name] = prediction;
      });
    }).toList();

    await Future.wait(requests); // Fetch all cities in parallel

    setState(() {
      isLoading = false;
    });
  }

  Widget displayPrediction(String prediction) {
    switch (prediction) {
      case 'Sunny':
        return Image.asset('assets/predict/sunny.png', scale: 10);
      case 'Mid Sunny':
        return Image.asset('assets/predict/moderatesunny.png', scale: 10);
      case 'Cloudy':
        return Image.asset('assets/predict/lightcloudy.png', scale: 10);
      case 'Heavy Cloudy':
        return Image.asset('assets/predict/heavycloudy.png', scale: 10);
      case 'Light drizzle':
        return Image.asset('assets/predict/lightdrizle.png', scale: 10);
      case 'Moderate drizzle':
        return Image.asset('assets/predict/moderatedrizle.png', scale: 10);
      case 'Heavy drizzle':
        return Image.asset('assets/predict/heavydrizle.png', scale: 10);
      case 'Light Rain':
        return Image.asset('assets/predict/lightrain.png', scale: 10);
      case 'Moderate Rain':
        return Image.asset('assets/predict/moderaterain.png', scale: 10);
      case 'Heavy Rain with Thunder':
        return Image.asset('assets/predict/heavyrain.png', scale: 10);
      default:
        return const Center(
          child: Text('No prediction yet.',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
        );
    }
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
          widget.appBarTitle,
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
          ? const Center(
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: Colors.white,
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Loading...',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                )
              ],
            ))
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
                    ListView.builder(
                      itemCount: widget.locations.length,
                      itemBuilder: (context, index) {
                        City city = widget.locations[index];
                        String prediction =
                            weatherPredictions[city.name] ?? "Loading...";
                        return Card(
                          color: Colors.transparent,
                          margin: const EdgeInsets.all(8),
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
                              title: AutoSizeText(
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                '${city.name}   [ ${widget.date} ]' ?? 'N/A',
                                style: const TextStyle(
                                    color: Color.fromARGB(255, 255, 255, 255),
                                    fontWeight: FontWeight.bold),
                              ),
                              // Text(city.name,
                              //     style: const TextStyle(fontSize: 18)),
                              subtitle: Row(
                                children: [
                                  displayPrediction(prediction),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(prediction,
                                          style: const TextStyle(
                                              fontSize: 16,
                                              color: Color.fromARGB(
                                                  255, 254, 236, 236))),
                                      (prediction == 'Sunny' ||
                                              prediction == 'Mid Sunny' ||
                                              prediction == 'Cloudy' ||
                                              prediction == 'Heavy Cloudy' ||
                                              prediction == 'Light drizzle')
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
                                          city: city.name,
                                          longitude: city.longitude.toString(),
                                          latitude: city.latitude.toString(),
                                          date: widget.date,
                                        ),
                                      ),
                                    );
                                  }),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
