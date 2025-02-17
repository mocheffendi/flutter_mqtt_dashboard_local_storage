// Provider for ServerModel
import 'dart:convert';

import 'package:flutter_mqtt_local_storage_deepseek/configs/server_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provider for ServerModel
final serverConfigProvider =
    StateNotifierProvider<ServerConfigNotifier, List<ServerConfig>>((ref) {
  return ServerConfigNotifier();
});

class ServerConfigNotifier extends StateNotifier<List<ServerConfig>> {
  ServerConfigNotifier() : super([]);

  Future<void> loadServerConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final configsJson = prefs.getStringList('serverConfigs');
    if (configsJson != null) {
      state = configsJson
          .map((jsonString) => ServerConfig.fromMap(
              Map<String, dynamic>.from(json.decode(jsonString))))
          .toList();
    }
  }

  Future<void> saveServerConfigs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configsJson =
          state.map((config) => json.encode(config.toMap())).toList();
      await prefs.setStringList('serverConfigs', configsJson);
    } catch (e) {
      print('Error saving server configurations: $e');
    }
  }

  void addServer(ServerConfig config) {
    state = [...state, config];
    saveServerConfigs();
  }

  void editServer(int index, ServerConfig newConfig) {
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index) newConfig else state[i],
    ];
    saveServerConfigs();
  }

  void deleteServer(int index) {
    state = [
      for (int i = 0; i < state.length; i++)
        if (i != index) state[i],
    ];
    saveServerConfigs();
  }

  void updateServerConfig(int index, ServerConfig updatedConfig) {
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index) updatedConfig else state[i]
    ];
    saveServerConfigs();
  }

  void duplicateServer(int index) {
    final config = state[index];
    final newConfig = config.copyWith(
      brokerName: '${config.brokerName} Copy',
    );
    addServer(newConfig);
  }
}
