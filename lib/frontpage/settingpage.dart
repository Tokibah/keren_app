import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:keren_app/frontpage/ModalFront/setting_repo.dart';
import 'package:keren_app/frontpage/animate_S.dart';
import 'package:keren_app/pagetransition.dart';
import 'package:keren_app/secondpage/sensor.dart';
import 'package:keren_app/secondpage/SmartHome/smarthome.dart';
import 'package:keren_app/main.dart';
import 'package:provider/provider.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool _isDarkMode = false;
  bool _isButtonEnabled = false;
  bool _isBoxRotated = false;

  void _saveSettings() {
    saveSetting(Setting(
      isDarkModeEnabled: _isDarkMode,
      isButtonEnabled: _isButtonEnabled,
      isBoxRotationEnabled: _isBoxRotated,
    ));
  }

  Future<void> _loadSettings() async {
    final loadedSettings = await loadSetting();
    if (loadedSettings != null) {
      setState(() {
        _isDarkMode = loadedSettings.isDarkModeEnabled;
        _isButtonEnabled = loadedSettings.isButtonEnabled;
        _isBoxRotated = loadedSettings.isBoxRotationEnabled;
      });
      if (_isDarkMode) {
        Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false, actions: [
        IconButton(
          onPressed: () async {
            await Navigator.push(context, SlideLeft(page: const TabBuild()));
            if (mounted) {
              ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
            }
          },
          icon: const Icon(Icons.home),
        ),
        IconButton(
          onPressed: () {
            Navigator.push(context, SizeRoute(page: const SensorPage()));
          },
          icon: const Icon(Icons.compass_calibration),
        ),
      ]),
///////////////////////////////////////////////////////////////////
      body: SingleChildScrollView(
        child: Row(children: [
          SizedBox(
            height: 550.h,
            width: 100.w,
            child: Column(children: [
              for (int i = 0; i < 5; i++)
                Padding(
                  padding: EdgeInsets.all(8.r),
                  child: RotatedBox(
                    quarterTurns: _isBoxRotated ? -1 : 0,
                    child: Container(
                      height: 30.h,
                      width: 70.w,
                      color: Colors.amber,
                      child: const Center(
                        child: Text(
                          'Profile',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
            ]),
          ),
///////////////////////////////////////////////////////////////////
          Expanded(
            child: Wrap(spacing: 10, children: [
              SizedBox(
                width: 200.r,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(_isDarkMode ? Icons.nightlight : Icons.sunny),
                            Switch(
                              value: _isDarkMode,
                              onChanged: (value) {
                                setState(() {
                                  _isDarkMode = value;
                                  _saveSettings();
                                });
                                Provider.of<ThemeProvider>(context,
                                        listen: false)
                                    .toggleTheme();
                              },
                            ),
                          ]),
///////////////////////////////////////////////////////////////////
                      Checkbox(
                        value: _isButtonEnabled,
                        onChanged: (value) {
                          setState(() {
                            _isButtonEnabled = value!;
                            _saveSettings();
                          });
                        },
                      ),
                      ElevatedButton(
                        onPressed: _isButtonEnabled
                            ? () {
                                setState(() {
                                  _isBoxRotated = !_isBoxRotated;
                                  _saveSettings();
                                });
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _isButtonEnabled ? null : Colors.grey,
                        ),
                        child: const Text('Rotate'),
                      ),
                    ]),
              ),
///////////////////////////////////////////////////////////////////
              BottomSetting(isButtonEnabled: _isButtonEnabled),
              Container(
                height: 200.h,
                width: 400.w,
                color: Colors.grey,
                child: const AnimatedSetting(),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

class BottomSetting extends StatefulWidget {
  const BottomSetting({super.key, required this.isButtonEnabled});

  final bool isButtonEnabled;

  @override
  State<BottomSetting> createState() => _BottomSettingState();
}

class _BottomSettingState extends State<BottomSetting> {
  int? _expandedTileIndex;

  final formKey = GlobalKey<FormState>();
  final _walletController = TextEditingController(text: "RM0.00");
  final _iamController = TextEditingController();

  void _toggleExpansion(int index) {
    setState(() {
      _expandedTileIndex = _expandedTileIndex == index ? null : index;
    });
  }

  void _formatWalletInput(String input) {
    String filteredInput =
        input.isNotEmpty ? input.replaceAll(RegExp(r'[^0-9]'), '') : '000';

    if (filteredInput.length > 3) {
      filteredInput = filteredInput.replaceFirst('0', '');
    } else if (filteredInput.length < 3) {
      filteredInput = '0${filteredInput.padLeft(2, '0')}';
    }

    _walletController.text =
        'RM${filteredInput.substring(0, filteredInput.length - 2)}.${filteredInput.substring(filteredInput.length - 2)}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.r),
      child: AbsorbPointer(
        absorbing: !widget.isButtonEnabled,
        child: Form(
          key: formKey,
          child: SizedBox(
            width: 310.w,
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text("Ewallet"),
              TextField(
                  onChanged: _formatWalletInput,
                  controller: _walletController,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ]),
///////////////////////////////////////////////////////////////////
              SizedBox(height: 20.h),
              const Text("'I AM'"),
              TextFormField(
                controller: _iamController,
                onChanged: (value) {
                  formKey.currentState!.validate();
                },
                validator: (value) {
                  return value != null && RegExp(r'^I AM').hasMatch(value)
                      ? null
                      : 'Invalid input';
                },
              ),
///////////////////////////////////////////////////////////////////
              Padding(
                padding: EdgeInsets.all(8.r),
                child: ExpansionTile(
                    onExpansionChanged: (_) => _toggleExpansion(0),
                    initiallyExpanded: _expandedTileIndex == 0,
                    title: const Text('ExpansionTile'),
                    children: [
                      Container(
                        color: Colors.grey,
                        height: 100.h,
                        child: PieChart(
                          PieChartData(
                            sections: [
                              PieChartSectionData(
                                value: 20,
                                color: Colors.amber,
                              ),
                              PieChartSectionData(value: 40),
                              PieChartSectionData(value: 30),
                            ],
                          ),
                        ),
                      ),
                      const ListTile(
                        title: Text('Pie Chart'),
                      ),
                    ]),
              ),
///////////////////////////////////////////////////////////////////
              ExpansionTile(
                  onExpansionChanged: (_) => _toggleExpansion(1),
                  initiallyExpanded: _expandedTileIndex == 1,
                  title: const Text('Expand2'),
                  children: [
                    Container(
                      height: 100,
                      color: Colors.grey,
                    ),
                  ]),
            ]),
          ),
        ),
      ),
    );
  }
}
