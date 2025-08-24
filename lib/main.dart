import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong_to_osgrid/latlong_to_osgrid.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(title: 'OS Coordinate Finder'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Your Current OS Coordinates:",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            SizedBox(height: 20),
            // 👇 This is where the converter widget lives
            LocationToGrid(),
          ],
        ),
      ),
    );
  }
}

class LocationToGrid extends StatefulWidget {
  const LocationToGrid({super.key});

  @override
  State<LocationToGrid> createState() => _LocationToGridState();
}

class _LocationToGridState extends State<LocationToGrid> {
  String result = "";
  final converter = LatLongConverter();

  // Helper: converts OSRef to 6-figure reference
  String toSixFigure(OSRef osRef) {
    final letters = osRef.letterRef.substring(0, 2); // e.g., "SP"
    final easting = (osRef.easting % 100000 ~/ 100).toString().padLeft(3, '0');
    final northing = (osRef.northing % 100000 ~/ 100).toString().padLeft(3, '0');
    return "$letters $easting $northing";
  }

  Future<void> _getOsGrid() async {
    try {
      LocationPermission p = await Geolocator.checkPermission();
      if (p == LocationPermission.denied) {
        p = await Geolocator.requestPermission();
        if (p == LocationPermission.denied) {
          setState(() => result = "❌ Permission denied");
          return;
        }
      }
      if (p == LocationPermission.deniedForever) {
        setState(() => result = "❌ Permission permanently denied");
        return;
      }

      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final osRef = converter.getOSGBfromDec(pos.latitude, pos.longitude);

      setState(() {
        result = "${toSixFigure(osRef)}";
      });
    } catch (e) {
      setState(() => result = "⚠️ Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(result, textAlign: TextAlign.center, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _getOsGrid,
          child: const Text("Get Location & Convert"),
        ),
      ],
    );
  }
}
