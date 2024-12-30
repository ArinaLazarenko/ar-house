import 'package:flutter/material.dart';
import 'package:flutter_embed_unity/flutter_embed_unity.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const ArAppWidget());
}

class ArAppWidget extends StatefulWidget {
  const ArAppWidget({super.key});

  @override
  State<ArAppWidget> createState() => _ArAppState();
}

class _ArAppState extends State<ArAppWidget> {
  static final _fixedLocaleNumberFormatter = NumberFormat.decimalPatternDigits(
    locale: 'en_gb',
    decimalDigits: 2,
  );

  bool? _isUnityArSupportedOnDevice;
  bool _isArSceneActive = false;
  double _rotation = 30;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
      ),
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Home visualization'),
        ),
        body: SafeArea(
          child: Builder(
            builder: (context) {
              final bool? isUnityArSupportedOnDevice =
                  _isUnityArSupportedOnDevice;
              final String arStatusMessage;

              if (isUnityArSupportedOnDevice == null) {
                arStatusMessage = "checking...";
              } else if (isUnityArSupportedOnDevice) {
                arStatusMessage = "supported";
              } else {
                arStatusMessage = "not supported on this device";
              }

              return Column(
                children: [
                  Expanded(
                    child: EmbedUnity(
                      onMessageFromUnity: (String data) {
                        // A message has been received from a Unity script
                        if (data == "scene_loaded") {
                          _sendRotationToUnity(_rotation);
                        } else if (data == "ar:true") {
                          setState(() {
                            _isUnityArSupportedOnDevice = true;
                          });
                        } else if (data == "ar:false") {
                          setState(() {
                            _isUnityArSupportedOnDevice = false;
                          });
                        }
                      },
                    ),
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.all(16),
                  //   child: Text(
                  //     "Flutter logo has been touched $_numberOfTaps times",
                  //     textAlign: TextAlign.center,
                  //     style: theme.textTheme.titleMedium,
                  //   ),
                  // ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Text("Activate AR ($arStatusMessage)"),
                        Switch(
                          value: _isArSceneActive,
                          onChanged: isUnityArSupportedOnDevice != null &&
                                  isUnityArSupportedOnDevice
                              ? (value) {
                                  sendToUnity(
                                    "SceneSwitcher",
                                    "SwitchToScene",
                                    _isArSceneActive
                                        ? "StartScene"
                                        : "ArScene",
                                  );
                                  setState(() {
                                    _isArSceneActive = value;
                                  });
                                }
                              : null,
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 16),
                        child: Text(
                          "Rotation",
                        ),
                      ),
                      Expanded(
                        child: Slider(
                          min: -200,
                          max: 200,
                          value: _rotation,
                          onChanged: (value) {
                            setState(() {
                              _rotation = value;
                            });
                            _sendRotationToUnity(value);
                          },
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              pauseUnity();
                            },
                            child: const Text("Pause"),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              resumeUnity();
                            },
                            child: const Text("Resume"),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _sendRotationToUnity(double rotation) {
    sendToUnity(
      "House",
      "SetRotation",
      _fixedLocaleNumberFormatter.format(rotation),
    );
  }
}
