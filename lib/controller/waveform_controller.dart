import 'package:flutter/material.dart';
import 'package:siri_wave/siri_wave.dart';

class WaveformController {
  final controller = IOS9SiriWaveformController(
    amplitude: 0.9,
    color1: const Color(0xFF00FFFF),
    color2: const Color(0xFFFF00FF),
    color3: const Color(0xFF00FF00),
    speed: 0.15,
  );
}
