import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:star_assistant/controller/speech_controller.dart';
import 'package:star_assistant/controller/tts_controller.dart';
import 'package:star_assistant/pages/star_home.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Error loading .env file: $e");
    // Continue running app even if .env fails to load,
    // AI service will use default keys or handle missing keys
  }

  // Wrap app in error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    debugPrint('Flutter error: ${details.exception}');
    debugPrint('Stack trace: ${details.stack}');
  };

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TTSController()),
        ChangeNotifierProxyProvider<TTSController, SpeechController>(
          create: (context) => SpeechController(
            Provider.of<TTSController>(context, listen: false),
          ),
          update: (context, tts, previous) => previous ?? SpeechController(tts),
        ),
      ],
      child: const StarApp(),
    ),
  );
}

class StarApp extends StatelessWidget {
  const StarApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Color.fromARGB(0, 0, 0, 0)));
    return MaterialApp(
      title: 'STAR AI Assistant',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const StarHome(),
    );
  }
}
