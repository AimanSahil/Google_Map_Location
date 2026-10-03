import 'package:flutter/material.dart';
import 'features/map/presentation/pages/map_page.dart';

class MapsLocationApp extends StatelessWidget {
  const MapsLocationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Maps & Location',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFFF7F8FC),
      ),
      home: const MapPage(),
    );
  }
}
