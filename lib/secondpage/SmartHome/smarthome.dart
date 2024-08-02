import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:keren_app/secondpage/SmartHome/SH_timepick.dart';
import 'package:keren_app/secondpage/ModalSecond/device_repo.dart';
import 'package:keren_app/main.dart';
import 'package:keren_app/secondpage/Media/mediaview.dart';

class TabBuild extends StatefulWidget {
  const TabBuild({super.key});

  @override
  State<TabBuild> createState() => _TabBuildState();
}

class _TabBuildState extends State<TabBuild> {
  int selected = 0;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
              onTap: (value) {
                setState(() {
                  selected = value;
                });
              },
              tabs: const [
                Tab(icon: Icon(Icons.home)),
                Tab(icon: Icon(Icons.image)),
              ]),
        ),
        body: IndexedStack(
          index: selected,
          children: const [SmartHome(), MediaPage()],
        ),
      ),
    );
  }
}

class SmartHome extends StatefulWidget {
  const SmartHome({super.key});

  @override
  State<SmartHome> createState() => _SmartHomeState();
}

class _SmartHomeState extends State<SmartHome> {
  TimeOfDay? start;
  TimeOfDay? endtime;
  List<Device> devices = [];

  @override
  void initState() {
    super.initState();
    getDevices();
  }

  void getDevices() async {
    devices = await Device.getDevices();
    setState(() {});
  }

  void updateTime(TimeOfDay? newTime, String type) {
    setState(() {
      if (type == 'Start') {
        start = newTime;
      } else {
        endtime = newTime;
      }
    });
  }

  void onDropUpdate(Device device, bool isActive) async {
    await Device.updateDevice(device.label, isActive);
    getDevices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(children: [
          Wrap(
            children: [
              DeviceContainer(
                text: "INACTIVE",
                onDrop: onDropUpdate,
                isActive: false,
                devices: devices,
              ),
              DeviceContainer(
                text: "ACTIVE",
                onDrop: onDropUpdate,
                isActive: true,
                devices: devices,
              ),
            ],
          ),
          TimePick(endTime: endtime, startTime: start, updateTime: updateTime),
          TimerWidget(start: start, endtime: endtime),
        ]),
      ),
    );
  }
}

class DeviceContainer extends StatelessWidget {
  const DeviceContainer({
    super.key,
    required this.text,
    required this.onDrop,
    required this.isActive,
    required this.devices,
  });

  final List<Device> devices;
  final Function(Device, bool) onDrop;
  final String text;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final isLightTheme = Theme.of(context).brightness == Brightness.light;

    return Padding(
      padding: EdgeInsets.all(10.r),
      child: Column(children: [
        Text(text),
        DragTarget(
          onAcceptWithDetails: (device) => onDrop(device as Device, isActive),
          builder: (context, candidateData, rejectedData) => Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: isLightTheme
                    ? ThemeProvider.darkColor
                    : ThemeProvider.lightColor,
              ),
            ),
            height: 200.h,
            width: 300.w,
            child: Wrap(children: [
              for (int i = 0; i < devices.length; i++)
                if (devices[i].isActive == isActive)
                  Padding(
                    padding: const EdgeInsets.all(2),
                    child: Draggable(
                      data: devices[i],
                      feedback: Material(
                        color: Colors.transparent,
                        child: Opacity(
                          opacity: 0.60,
                          child: Chip(
                            label: Text(devices[i].name),
                            backgroundColor: ThemeProvider.highlightColor,
                          ),
                        ),
                      ),
                      child: Chip(
                        label: Text(devices[i].name),
                        backgroundColor: ThemeProvider.highlightColor,
                      ),
                    ),
                  )
            ]),
          ),
        ),
      ]),
    );
  }
}
