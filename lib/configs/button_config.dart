import 'package:flutter/material.dart';

// ButtonConfig Model
class ButtonConfig {
  final String buttonName;
  final String subscribeTopic;
  final String publishTopic;
  final String messageOnValue;
  final String messageOffValue;
  final IconData iconOn;
  final IconData iconOff;
  final int color;

  bool isOn;

  ButtonConfig({
    required this.buttonName,
    required this.subscribeTopic,
    required this.publishTopic,
    required this.messageOnValue,
    required this.messageOffValue,
    required this.iconOn,
    required this.iconOff,
    required this.color,
    this.isOn = false,
  });

  // Get the button color based on the state
  Color get colorIcon => isOn ? Colors.grey : Colors.green;
  // Color get color => Colors.amber;
  // Convert color string to Color object
  // Color get buttonColor => color;

  ButtonConfig copyWith({
    String? buttonName,
    String? subscribeTopic,
    String? publishTopic,
    String? messageOnValue,
    String? messageOffValue,
    IconData? iconOn,
    IconData? iconOff,
    int? color,
    bool? isOn,
  }) {
    return ButtonConfig(
      buttonName: buttonName ?? this.buttonName,
      subscribeTopic: subscribeTopic ?? this.subscribeTopic,
      publishTopic: publishTopic ?? this.publishTopic,
      messageOnValue: messageOnValue ?? this.messageOnValue,
      messageOffValue: messageOffValue ?? this.messageOffValue,
      iconOn: iconOn ?? this.iconOn,
      iconOff: iconOff ?? this.iconOff,
      color: color ?? this.color,
      isOn: isOn ?? this.isOn,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'buttonName': buttonName,
      'subscribeTopic': subscribeTopic,
      'publishTopic': publishTopic,
      'messageOnValue': messageOnValue,
      'messageOffValue': messageOffValue,
      'iconOn': iconOn.codePoint,
      'iconOff': iconOff.codePoint,
      'color': color,
      'isOn': isOn,
    };
  }

  factory ButtonConfig.fromMap(Map<String, dynamic> map) {
    return ButtonConfig(
      buttonName: map['buttonName'],
      subscribeTopic: map['subscribeTopic'],
      publishTopic: map['publishTopic'],
      messageOnValue: map['messageOnValue'],
      messageOffValue: map['messageOffValue'],
      iconOn: IconData(map['iconOn'], fontFamily: 'MaterialIcons'),
      iconOff: IconData(map['iconOff'], fontFamily: 'MaterialIcons'),
      color: map['color'] ?? 'FFFFFF',
      isOn: map['isOn'],
    );
  }
}
