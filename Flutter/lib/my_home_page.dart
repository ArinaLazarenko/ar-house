import 'package:ar_vis/joystick.dart';
import 'package:ar_vis/multiuse_tooltip.dart';
import 'package:ar_vis/my_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_embed_unity/flutter_embed_unity.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:intl/intl.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool? _isUnityArSupportedOnDevice;
  bool _isArSceneActive = false;
  double _rotation = 0;
  double _xDirection = 0.0;
  double _zDirection = 0.0;

  final NumberFormat _fixedLocaleNumberFormatter =
      NumberFormat.decimalPatternDigits(
    locale: 'en_gb',
    decimalDigits: 2,
  );

  String get arStatusMessage {
    if (_isUnityArSupportedOnDevice == null) return "checking...";
    return _isUnityArSupportedOnDevice! ? "supported" : "not supported";
  }

  double _scale = 0.2;
  List<double> scales = [0.1, 0.2, 0.3, 0.5, 0.7, 1.0];

  String _houseInfo = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Builder(
          builder: (context) {
            return Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      // Unity view
                      EmbedUnity(
                        onMessageFromUnity: _handleUnityMessage,
                      ),
                      // Joystick for movement
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: JoystickMove(
                          onChange: (details) {
                            setState(() {
                              _xDirection = details.x;
                              _zDirection = -details.y;
                            });
                            _sendPositionToUnity();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // AR activation
                      Row(
                        children: [
                          Text("AR ($arStatusMessage)"),
                          Switch(
                            value: _isArSceneActive,
                            onChanged: (_isUnityArSupportedOnDevice == true)
                                ? _onArSceneSwitchChanged
                                : null,
                          ),
                        ],
                      ),
                      // Pause/Resume buttons and info
                      Row(
                        children: [
                          MultiuseTooltip(
                            message: _houseInfo,
                            child: const MyButton(
                              iconData: Icons.info_outline,
                            ),
                          ),
                          MyButton(
                            onTap: _onPausePressed,
                            iconData: Icons.pause,
                          ),
                          MyButton(
                            onTap: _onResumePressed,
                            iconData: Icons.play_arrow,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Rotation control slider
                    Expanded(
                      child: Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 16.0),
                            child: Icon(MdiIcons.rotate360),
                          ),
                          Expanded(
                            child: Slider(
                              min: -180,
                              max: 180,
                              value: _rotation,
                              onChanged: _onRotationChanged,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Scale dropdown
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Row(
                        children: [
                          const Icon(MdiIcons.resize),
                          SizedBox(
                            width: 50,
                            child: DropdownButton(
                              value: _scale,
                              items: scales.map((double items) {
                                return DropdownMenuItem(
                                  value: items,
                                  child: Text(items.toString()),
                                );
                              }).toList(),
                              onChanged: (double? newValue) {
                                setState(() => _scale = newValue!);
                                _sendScaleToUnity(_scale);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _handleUnityMessage(String data) {
    if (data == "scene_loaded") {
      _sendRotationToUnity(_rotation);
      _sendScaleToUnity(_scale);
    } else if (data == "ar:true") {
      setState(() => _isUnityArSupportedOnDevice = true);
    } else if (data == "ar:false") {
      setState(() => _isUnityArSupportedOnDevice = false);
    } else if (data.contains("scale")) {
      _setDefaultScale(data);
    // } else if (data.contains("position:")) {
    //   _setDefaultPosition(data);
    } else if (data.contains("info:")) {
      _setMessageInfo(data);
    }
  }

  void _setDefaultScale(String data) {
    setState(() {
      double newScale = double.parse(
          (double.tryParse(data.split(":")[1]) ?? 1.0).toStringAsFixed(1));
      if (!scales.contains(newScale)) {
        scales.add(newScale);
        scales.sort();
      }
      _scale = newScale;
    });
  }

  void _setMessageInfo(String data) {
    String info = data.substring(data.indexOf("info:") + "info:".length).trim();
    setState(() => _houseInfo = info);
  }

  void _onArSceneSwitchChanged(bool value) {
    _enableARControl();
    sendToUnity(
      "SceneSwitcher",
      "SwitchToScene",
      _isArSceneActive
          ? "FlutterEmbedExampleScene"
          : "FlutterEmbedExampleSceneAR",
    );
    setState(() {
      _scale = 0.1;
      _isArSceneActive = value;
    });
  }

  void _onRotationChanged(double value) {
    setState(() => _rotation = value);
    _sendRotationToUnity(value);
  }

  void _onPausePressed() {
    pauseUnity();
    _enableARControl();
  }

  void _onResumePressed() {
    resumeUnity();
    _enableARControl();
  }

  void _sendRotationToUnity(double rotation) {
    sendToUnity(
      "House",
      "SetRotation",
      _fixedLocaleNumberFormatter.format(rotation),
    );
  }

  void _sendPositionToUnity() {
    sendToUnity("House", "SetControlledByFlutter", "true");
    sendToUnity(
        "House", "SetDirection", "$_xDirection,0,$_zDirection");
  }

  void _sendScaleToUnity(double scale) {
    sendToUnity("House", "SetControlledByFlutter", "true");
    sendToUnity(
      "House",
      "SetScale",
      _fixedLocaleNumberFormatter.format(scale),
    );
  }

  void _enableARControl() {
    sendToUnity("House", "SetControlledByFlutter", "false");
  }
}
