import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sensors_plus/sensors_plus.dart';

class SensorPage extends StatefulWidget {
  const SensorPage({super.key});

  @override
  State<SensorPage> createState() => _SensorPageState();
}

class _SensorPageState extends State<SensorPage> {
  double xPosition = 100, yPosition = 100;
  double heading = 0;
  StreamSubscription<MagnetometerEvent>? magnetometerSubscription;
  StreamSubscription<GyroscopeEvent>? gyroscopeSubscription;

  bool isGyroAvailable = true;
  bool isMagnetometerAvailable = true;

  @override
  void initState() {
    super.initState();
    initializeGyroscope();
    initializeMagnetometer();
  }

  void initializeMagnetometer() async {
    try {
      await magnetometerEventStream().first;
      magnetometerSubscription = magnetometerEventStream().listen((event) {
        setState(() {
          heading = (atan2(event.y, event.x) * (180 / pi)).clamp(0, 360);
        });
      });
    } catch (e) {
      setState(() {
        isMagnetometerAvailable = false;
      });
    }
  }

  void initializeGyroscope() async {
    try {
      await gyroscopeEventStream().first;
      gyroscopeSubscription = gyroscopeEventStream().listen((event) {
        setState(() {
          xPosition = (xPosition + event.y * 0.5).clamp(-1, 1);
          yPosition = (yPosition + event.x * 0.5).clamp(-1, 1);
        });
      });
    } catch (e) {
      setState(() {
        isGyroAvailable = false;
      });
    }
  }

  @override
  void dispose() {
    gyroscopeSubscription?.cancel();
    magnetometerSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.home),
        ),
      ),
///////////////////////////////////////////////////////////////////
      body: Wrap(children: [
        Container(
          color: Colors.grey,
          height: 400.r,
          width: 600.r,
          child: isGyroAvailable
              ? Stack(
                  children: [
                    Positioned(
                      top: (yPosition + 1) * 200,
                      left: (xPosition + 1) * 300,
                      child: const CircleAvatar(radius: 20),
                    ),
                  ],
                )
              : const Center(child: Text('Gyroscope unavailable')),
        ),
///////////////////////////////////////////////////////////////////
        Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.amber,
          ),
          height: 480.h,
          width: 450.w,
          child: isMagnetometerAvailable
              ? Transform.rotate(
                  angle: heading * (pi / 180),
                  child: Image.asset(
                    'assets/gambar/compass.png',
                    height: 200.sp,
                    width: 200.sp,
                  ),
                )
              : const Center(child: Text('Magnetometer unavailable')),
        ),
      ]),
    );
  }
}
