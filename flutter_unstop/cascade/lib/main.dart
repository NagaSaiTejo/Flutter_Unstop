import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cascade/theme.dart';
import 'package:cascade/services/hive_service.dart';
import 'package:cascade/services/video_service.dart';
import 'package:cascade/providers/video_provider.dart';
import 'package:cascade/providers/video_player_provider.dart';
import 'package:cascade/screens/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await HiveService.init();
  
  // Initialize video service with sample data
  await VideoService.init();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => VideoProvider()),
        ChangeNotifierProvider(create: (_) => VideoPlayerProvider()),
      ],
      child: MaterialApp(
        title: 'Cascade - Short Video Feed',
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: ThemeMode.system,
        home: const HomePage(),
      ),
    );
  }
}
