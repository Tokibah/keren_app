import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:keren_app/frontpage/Cafe/cafepage.dart';
import 'package:keren_app/secondpage/sensor.dart';
import 'package:keren_app/frontpage/settingpage.dart';
import 'package:keren_app/secondpage/SmartHome/smarthome.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quick_actions/quick_actions.dart';

class OrientationAwarePage extends StatefulWidget {
  const OrientationAwarePage({super.key});

  @override
  State<OrientationAwarePage> createState() => _OrientationAwarePageState();
}

class _OrientationAwarePageState extends State<OrientationAwarePage> {
  final _firebaseMessaging = FirebaseMessaging.instance;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _requestNotificationPermission();
    _initializeFirebaseMessaging();
    _setupQuickActions();
  }

  void _requestNotificationPermission() async {
    await Permission.notification.request();
  }

  void _initializeFirebaseMessaging() {
    _firebaseMessaging.getToken().then((String? token) {
      assert(token != null);
      print('Token: $token');
    });
  }

  void _setupQuickActions() {
    const QuickActions().initialize(_handleQuickAction);
    const QuickActions().setShortcutItems([
      const ShortcutItem(
        type: '1',
        localizedTitle: 'Compass',
        icon: "assets/gambar/kerenicon.png",
      ),
      const ShortcutItem(
        type: '2',
        localizedTitle: 'Smart Home',
      ),
    ]);
  }

  void _handleQuickAction(String type) {
    if (type == '1') {
      _navigateTo(const SensorPage());
    } else if (type == '2') {
      _navigateTo(const TabBuild());
    }
  }

  void _navigateTo(Widget page) {
    Navigator.of(context).canPop()
        ? Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => page))
        : Navigator.push(
            context, MaterialPageRoute(builder: (context) => page));
  }

  void _onNavigationItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;

    return Scaffold(
      body: OrientationBuilder(builder: (context, orientation) {
        return Row(children: [
          orientation == Orientation.landscape && !keyboardVisible
              ? NavigationRail(
                  labelType: NavigationRailLabelType.selected,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.coffee),
                      label: Text('Cafe'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.settings),
                      label: Text('Settings'),
                    ),
                  ],
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: _onNavigationItemSelected,
                )
              : const SizedBox.shrink(),
///////////
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: const [CafePage(), Settings()],
            ),
          ),
        ]);
      }),
///////////
      bottomNavigationBar: OrientationBuilder(
        builder: (context, orientation) {
          return orientation == Orientation.portrait
              ? NavigationBar(
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.coffee),
                      label: 'Cafe',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.settings),
                      label: 'Settings',
                    ),
                  ],
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: _onNavigationItemSelected,
                )
              : const SizedBox.shrink();
        },
      ),
    );
  }
}
