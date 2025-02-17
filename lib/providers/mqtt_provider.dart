import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:flutter_mqtt_local_storage_deepseek/services/mqtt_service.dart';

// Provider for MQTTService
final mqttServiceProvider =
    Provider.family<MQTTService, BuildContext>((ref, context) {
  final mqttService = MQTTService(ref, context);
  return mqttService;
});

// Provider for MQTT connection state
final mqttConnectionStateProvider = StateProvider<MqttConnectionState?>((ref) {
  return null;
});

final isConnectedProvider = StateProvider<bool>((ref) => false);
final isConnectingProvider = StateProvider<bool>((ref) => false);

// final mqttConnectionStateProvider = StateProvider<MqttConnectionState>((ref) {
//   return MqttConnectionState.disconnected; // Default state
// });

final receivedMessagesProvider =
    StateProvider<Map<String, List<String>>>((ref) => {});

final isSubscribedProvider = StateProvider<bool>((ref) => false);
