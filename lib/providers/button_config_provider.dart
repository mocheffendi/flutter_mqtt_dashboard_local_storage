import 'dart:convert';

import 'package:flutter_mqtt_local_storage_deepseek/configs/button_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Riverpod Provider for Button Configurations
final buttonConfigProvider =
    StateNotifierProvider<ButtonConfigNotifier, List<ButtonConfig>>((ref) {
  return ButtonConfigNotifier();
});

class ButtonConfigNotifier extends StateNotifier<List<ButtonConfig>> {
  ButtonConfigNotifier() : super([]);

  Future<void> loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final configsJson = prefs.getStringList('buttonConfigs');
    if (configsJson != null) {
      state = configsJson
          .map((jsonString) => ButtonConfig.fromMap(
              Map<String, dynamic>.from(json.decode(jsonString))))
          .toList();
    }
  }

  Future<String> transmitData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String>? configsJson = prefs.getStringList('buttonConfigs');

    String jsonData = json.encode(configsJson);

    // print(jsonData);
    return jsonData;
  }

  Future<void> receiveData(List<String> jsonData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // final configsJson = json.decode(jsonData);
      // state.map((config) => json.encode(config.toMap())).toList();

      print('Saving button configurations: $jsonData');
      await prefs.setStringList('buttonConfigs', jsonData);
    } catch (e) {
      print('Error saving button configurations: $e');
    }
  }

  Future<void> saveConfigs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configsJson =
          state.map((config) => json.encode(config.toMap())).toList();
      // print('Saving button configurations: $configsJson');
      await prefs.setStringList('buttonConfigs', configsJson);
    } catch (e) {
      print('Error saving button configurations: $e');
    }
  }

  void addButton(ButtonConfig config) {
    state = [...state, config];
    saveConfigs();
  }

  void editButton(int index, ButtonConfig newConfig) {
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index) newConfig else state[i],
    ];
    saveConfigs();
  }

  void deleteButton(int index) {
    state = [
      for (int i = 0; i < state.length; i++)
        if (i != index) state[i],
    ];
    saveConfigs();
  }

  void toggleButton(int index) {
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index) state[i].copyWith(isOn: !state[i].isOn) else state[i],
    ];
    saveConfigs();
  }

  void updateButtonState(String topic, String payload) {
    state = [
      for (final config in state)
        if (config.subscribeTopic == topic)
          config.copyWith(isOn: payload == config.messageOffValue)
        else
          config,
    ];
    saveConfigs();
  }

  void duplicateButton(int index) {
    final config = state[index];
    final newConfig = config.copyWith(
      buttonName: '${config.buttonName} Copy',
    );
    addButton(newConfig);
  }
}
