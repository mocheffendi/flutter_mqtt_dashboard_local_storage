import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_mqtt_local_storage_deepseek/providers/button_config_provider.dart';
import 'package:flutter_mqtt_local_storage_deepseek/providers/mqtt_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MQTTService {
  late MqttServerClient client;
  final Ref ref;
  final BuildContext context;
  final Set<String> _subscribedTopics = {}; // Track subscribed topics
  // final ServerModel serverModel;

  MQTTService(this.ref, this.context);

  Future<void> connect(String serverAddress, String clientId, int port,
      bool secureConnection, String username, String password) async {
    // client = MqttServerClient(serverModel.serverAddress, serverModel.clientId);
    // client.port = serverModel.port;
    // client.secure = serverModel.secureConnection;

    final isConnecting = ref.read(isConnectingProvider.notifier);
    final isConnected = ref.read(isConnectedProvider.notifier);

    client = MqttServerClient(serverAddress, clientId);
    client.port = port;
    client.secure = secureConnection;
    client.logging(on: false);
    client.keepAlivePeriod = 60;
    client.setProtocolV311();
    client.keepAlivePeriod = 20;
    client.connectTimeoutPeriod = 2000;
    client.onDisconnected = onDisconnected;
    client.onConnected = onConnected;
    client.onSubscribed = onSubscribed;

    final connMessage = MqttConnectMessage()
        .authenticateAs(username,
            password) // Optional: if your broker requires authentication
        .withWillTopic('willtopic')
        .withWillMessage('Will message')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);

    client.connectionMessage = connMessage;

    isConnecting.state = true;

    try {
      await client.connect();
    } catch (e) {
      print('Exception: $e');
      client.disconnect();
      isConnecting.state = false;
    }

    isConnecting.state = false;

    // if (client.connectionStatus?.state == MqttConnectionState.connected) {
    //   print('MQTT Connected');
    // ref.read(mqttConnectionStateProvider.notifier).state = client.connectionStatus?.state;
    // } else {
    //   print('MQTT Connection Failed');
    //   ref.read(mqttConnectionStateProvider.notifier).state = client.connectionStatus?.state;
    // }
  }

  // Method to check if a topic is already subscribed
  bool isSubscribed(String topic) {
    return _subscribedTopics.contains(topic);
  }

  // In the MQTTService class, update the subscription logic to add messages to the provider:
  Future<void> subscribe(String topic) async {
    if (client.connectionStatus?.state == MqttConnectionState.connected) {
      // if (client.getSubscriptionsStatus(topic) !=
      //     MqttSubscriptionStatus.active) {
      //   print(
      //       'opo iki ${client.getSubscriptionsStatus(topic)}  ${MqttSubscriptionStatus.active}');
      //   client.subscribe(topic, MqttQos.atLeastOnce);
      //   _subscribedTopics.add(topic);
      // } else {
      //   print('Already subscribed to $topic');
      // }
      // if (_subscribedTopics.contains(topic)) {
      // try {
      //   if (isSubscribed(topic)) {
      //     print('Already subscribed to $topic');
      //     return;
      //   } else {
      //     client.subscribe(topic, MqttQos.atLeastOnce);
      //     _subscribedTopics.add(topic);
      //   }
      // } catch (e) {
      //   print('Exception: $e');
      // }
      // print('Subscribing to $topic');
      client.subscribe(topic, MqttQos.atLeastOnce);

      // // Add the topic to the subscribed topics set
      // _subscribedTopics.add(topic);
    } else {
      print('Not connected to MQTT broker');
    }
  }

  void unsubscribe(String topic) {
    if (client.connectionStatus?.state == MqttConnectionState.connected) {
      if (_subscribedTopics.contains(topic)) {
        print('Unsubscribing from $topic');
        client.unsubscribe(topic);
        _subscribedTopics.remove(topic);
      }
    }
  }

  void publish(String topic, String message) async {
    if (client.connectionStatus?.state == MqttConnectionState.connected) {
      final builder = MqttClientPayloadBuilder();
      builder.addString(message);

      print('Publishing message: $message to topic: $topic');
      client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
    } else {
      print('Not connected to MQTT broker');

      try {
        await client.connect();
      } catch (e) {
        print('Exception: $e');
        client.disconnect();
      }
    }
  }

  void disconnect() {
    client.disconnect();
    print('MQTT Disconnected');
    _subscribedTopics.clear();
    ref.read(mqttConnectionStateProvider.notifier).state =
        client.connectionStatus?.state;
  }

  void onSubscribed(String topic) {
    print('MQTTClient::Subscription confirmed for topic $topic');
  }

  void onDisconnected() {
    print('MQTTClient::Disconnected');
    ref.read(mqttConnectionStateProvider.notifier).state =
        client.connectionStatus?.state;
    // disconnect();
    if (client.connectionStatus?.disconnectionOrigin ==
        MqttDisconnectionOrigin.solicited) {
      print('MQTTClient::Disconnected callback is solicited, this is correct');
    } else {
      print(
          'MQTTClient::Disconnected callback is unsolicited or none, this is incorrect');
    }
  }

  void onConnected() {
    print('MQTTClient::Connected');
    client.updates!
        .listen((List<MqttReceivedMessage<MqttMessage>> messages) async {
      for (var message in messages) {
        final publishMessage = message.payload as MqttPublishMessage;
        final payload = MqttPublishPayload.bytesToStringAsString(
            publishMessage.payload.message);

        print('Received message: $payload from topic: ${message.topic}');

        if (message.topic == 'transferData') {
          try {
            // Parse the JSON string back into List<String>
            // List<String> receivedData = List<String>.from(json.decode(payload));

            // Now you can use the receivedData list
            print('Received data before decode: $payload');
            List<String> decodedJsonData =
                List<String>.from(json.decode(payload));

            print('Received data after decode: $decodedJsonData');
            await ref
                .read(buttonConfigProvider.notifier)
                .receiveData(decodedJsonData);
            await ref.read(buttonConfigProvider.notifier).loadConfig();
            // final SharedPreferences prefs =
            //     await SharedPreferences.getInstance();
            // await prefs.setStringList('buttonConfigs', decodedJsonData);
          } catch (e) {
            print('Error parsing message: $e');
          }
        }

        // Add the message to the provider with topic information
        ref.read(receivedMessagesProvider.notifier).update((state) {
          final updatedState = Map<String, List<String>>.from(state);
          if (updatedState.containsKey(message.topic)) {
            updatedState[message.topic]!.add(payload);
          } else {
            updatedState[message.topic] = [payload];
          }
          return updatedState;
        });

        // Update button state based on received message
        ref
            .read(buttonConfigProvider.notifier)
            .updateButtonState(message.topic, payload);
      }
    });

    ref.read(mqttConnectionStateProvider.notifier).state =
        client.connectionStatus?.state;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Connected to MQTT broker')),
    );

    final buttonConfigs = ref.read(buttonConfigProvider);
    for (final config in buttonConfigs) {
      if (isSubscribed(config.subscribeTopic)) {
        print('Already subscribed to ${config.subscribeTopic}');
        return;
      } else {
        subscribe(config.subscribeTopic);

        print('Subscribing to ${config.subscribeTopic}');
        _subscribedTopics.add(config.subscribeTopic);
        print(_subscribedTopics);
      }

      // if (isSubscribed(config.subscribeTopic)) {
      //   print('Already subscribed to ${config.subscribeTopic}');
      //   // Show a message to the user (e.g., using a SnackBar)
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(
      //         content: Text('Already subscribed to ${config.subscribeTopic}')),
      //   );
      // } else {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text('Subscribed to ${config.subscribeTopic}')),
      //   );
      //   print('Subscribed to ${config.subscribeTopic}');
      //   subscribe(config.subscribeTopic);
      //   print(_subscribedTopics);
      // }
    }
  }

  void printSubscribedTopics() {
    print(_subscribedTopics);
  }
}
