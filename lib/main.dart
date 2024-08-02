import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:keren_app/firebase_options.dart';
import 'package:keren_app/pushnavi.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseFirestore.instance.settings =
      const Settings(persistenceEnabled: true);

  runApp(ChangeNotifierProvider(
    create: (context) => ThemeProvider(),
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => ScreenUtilInit(
        designSize: const Size(601, 1007),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) => MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: Provider.of<ThemeProvider>(context).themeData,
            home: child),
        child: const OrientationAwarePage(),
      );
}

class ThemeProvider with ChangeNotifier {
  ThemeData _themeData = _lightMode;
  ThemeData get themeData => _themeData;

  static const Color highlightColor = Color(0xFFED6B86);
  static const Color lightColor = Color(0xFFEBEBEB);
  static const Color darkColor = Color(0xFF24191C);

  void toggleTheme() {
    _themeData = _themeData == _lightMode ? _darkMode : _lightMode;
    notifyListeners();
  }

  static final _lightMode = ThemeData(
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(backgroundColor: highlightColor),
    ),
    textTheme: GoogleFonts.montserratTextTheme(),
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: lightColor,
    colorScheme: const ColorScheme.light(
      surface: lightColor,
      primary: darkColor,
      outline: darkColor,
      tertiary: highlightColor,
      secondary: highlightColor,
    ),
    appBarTheme: const AppBarTheme(color: Colors.transparent),
  );

  static final _darkMode = ThemeData(
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(backgroundColor: highlightColor),
    ),
    textTheme: GoogleFonts.montserratTextTheme(
      const TextTheme(bodyMedium: TextStyle(color: lightColor)),
    ),
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkColor,
    colorScheme: const ColorScheme.dark(
      surface: darkColor,
      primary: lightColor,
      outline: lightColor,
      tertiary: highlightColor,
      secondary: highlightColor,
    ),
    appBarTheme: const AppBarTheme(color: Colors.transparent),
  );
}


//_promotime.duration.inDays
/* Slidable(
  actionPane: SlidableDrawerActionPane(), // Choose an action pane (e.g., drawer, slide, etc.)
  actionExtentRatio: 0.25, // How far the actions extend (0.0 to 1.0)
  child: YourExistingWidget(), // Your existing UI element
  actions: <Widget>[
    IconSlideAction(
      caption: 'Archive',
      color: Colors.blue,
      icon: Icons.archive,
      onTap: () {
        // Handle archive action
      },
    ),
    IconSlideAction(
      caption: 'Share',
      color: Colors.indigo,
      icon: Icons.share,
      onTap: () {
        // Handle share action
      },
    ),
  ],
  secondaryActions: <Widget>[
    IconSlideAction(
      caption: 'More',
      color: Colors.black45,
      icon: Icons.more_horiz,
      onTap: () {
        // Handle more options action
      },
    ),
    IconSlideAction(
      caption: 'Delete',
      color: Colors.red,
      icon: Icons.delete,
      onTap: () {
        // Handle delete action
      },
    ),
  ],
) */

/* TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0),
        weight: 1,
      ),
    ]).animate( */

/* decode - string => json
encode - json => string



Future<void> user_logout() async{
   final prefs = await SharedPreferences.getInstance();
   prefs.remove('token');


Future<List<User>> fetchJson() async {
  final jsonFile = await rootBundle.loadString("assets/user.json");
  final jsonData = jsonDecode(jsonFile)['users'] as List;
  List<User> userdata = jsonData.map((e) => User.fromJson(e)).toList();
  return userdata;
} */