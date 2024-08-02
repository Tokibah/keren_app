import 'dart:async';

import 'package:flutter/material.dart';

class TimePick extends StatelessWidget {
  const TimePick({
    super.key,
    required this.endTime,
    required this.startTime,
    required this.updateTime,
  });

  final Function(TimeOfDay?, String) updateTime;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;

  bool compareTime(TimeOfDay? start, TimeOfDay? end) {
    if (start == null || end == null) return false;
    return start.hour < end.hour ||
        (start.hour == end.hour && start.minute < end.minute);
  }

  @override
  Widget build(BuildContext context) {
    Widget timeButton({
      required String label,
      required Function(TimeOfDay?, String) update,
      required TimeOfDay? oppositeTime,
      required TimeOfDay? selectedTime,
      required bool Function(TimeOfDay?, TimeOfDay?) compare,
      required String errorMessage,
    }) {
      return ElevatedButton(
        onPressed: () async {
          final time = await showTimePicker(
              context: context, initialTime: TimeOfDay.now());
          if (time == null) return;

          if (oppositeTime == null || compare(time, oppositeTime)) {
            update(time, label);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(errorMessage)),
            );
          }
        },
        child:
            Text(selectedTime == null ? label : selectedTime.format(context)),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        timeButton(
          label: 'Start',
          update: updateTime,
          compare: compareTime,
          oppositeTime: endTime,
          selectedTime: startTime,
          errorMessage: 'Start time needs to be earlier',
        ),
        const SizedBox(width: 10),
        const Text('-', style: TextStyle(fontSize: 50)),
        const SizedBox(width: 10),
        timeButton(
          label: 'End',
          update: updateTime,
          compare: (end, start) => compareTime(start, end),
          oppositeTime: startTime,
          selectedTime: endTime,
          errorMessage: 'End time must be later',
        ),
      ],
    );
  }
}

class TimerWidget extends StatefulWidget {
  final TimeOfDay? start;
  final TimeOfDay? endtime;

  const TimerWidget({super.key, this.start, this.endtime});

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  bool timerStart = false;
  bool timerPause = false;
  Duration timerDuration = Duration.zero;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    calculateDuration(widget.start, widget.endtime);
  }

  void calculateDuration(TimeOfDay? start, TimeOfDay? end) {
    if (start != null && end != null) {
      final now = DateTime.now();
      final startTime =
          DateTime(now.year, now.month, now.day, start.hour, start.minute);
      final endTime =
          DateTime(now.year, now.month, now.day, end.hour, end.minute);
      setState(() {
        timerDuration = endTime.difference(startTime);
      });
    }
  }

  void startTimer() {
    if (timerPause || !timerStart) {
      timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (timerDuration.inSeconds > 0) {
          setState(() {
            timerStart = true;
            timerPause = false;
            timerDuration -= const Duration(seconds: 1);
          });
        } else {
          setState(() {
            timerStart = false;
            timerPause = false;
            timer?.cancel();
            calculateDuration(widget.start, widget.endtime);
          });
        }
      });
    } else {
      setState(() {
        timerPause = true;
        timer?.cancel();
      });
    }
  }

  void stopTimer() {
    timer?.cancel();
    setState(() {
      timerStart = false;
      timerPause = false;
      calculateDuration(widget.start, widget.endtime);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(
        '${timerDuration.inHours.toString().padLeft(2, '0')}:${(timerDuration.inMinutes % 60).toString().padLeft(2, '0')}:${(timerDuration.inSeconds % 60).toString().padLeft(2, '0')}',
      ),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        ElevatedButton(
          onPressed: startTimer,
          child: Text(
            timerStart ? (timerPause ? 'Continue' : 'Pause') : 'Begin',
          ),
        ),
        if (timerStart)
          ElevatedButton(
            onPressed: stopTimer,
            child: const Text('Cancel'),
          ),
      ]),
    ]);
  }
}