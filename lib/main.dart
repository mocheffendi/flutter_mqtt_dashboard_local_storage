import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_mqtt_local_storage_deepseek/configs/button_config.dart';
import 'package:flutter_mqtt_local_storage_deepseek/providers/button_config_provider.dart';
import 'package:flutter_mqtt_local_storage_deepseek/providers/mqtt_provider.dart';
import 'package:flutter_mqtt_local_storage_deepseek/providers/server_config_provider.dart';
import 'package:flutter_mqtt_local_storage_deepseek/configs/server_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter MQTT Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MQTTDemo(),
    );
  }
}

class MQTTDemo extends ConsumerStatefulWidget {
  const MQTTDemo({super.key});

  @override
  ConsumerState<MQTTDemo> createState() => _MQTTDemoState();
}

class _MQTTDemoState extends ConsumerState<MQTTDemo> {
  final TextEditingController _messageController = TextEditingController();

  final TextEditingController _buttonNameController = TextEditingController();
  final TextEditingController _subscribeTopicController =
      TextEditingController();
  final TextEditingController _publishTopicController = TextEditingController();
  final TextEditingController _messageOnController = TextEditingController();
  final TextEditingController _messageOffController = TextEditingController();

  bool isSubscribed = false; // Track subscription status

  List<Map<String, dynamic>> buttons = [
    {
      "buttonName": "POWER8",
      "subscribeTopic": "stat/WASISTechOne/POWER8",
      "publishTopic": "cmnd/WASISTechOne/POWER8",
      "messageOnValue": "ON",
      "messageOffValue": "OFF",
      "iconOn": 58988,
      "iconOff": 58987,
      "color": 4289593135,
      "isOn": false
    },
    {
      "buttonName": "POWER7",
      "subscribeTopic": "stat/WASISTechOne/POWER7",
      "publishTopic": "cmnd/WASISTechOne/POWER7",
      "messageOnValue": "ON",
      "messageOffValue": "OFF",
      "iconOn": 58988,
      "iconOff": 58987,
      "color": 4290401747,
      "isOn": false
    },
    {
      "buttonName": "POWER2",
      "subscribeTopic": "stat/WASISTechOne/POWER2",
      "publishTopic": "cmnd/WASISTechOne/POWER2",
      "messageOnValue": "ON",
      "messageOffValue": "OFF",
      "iconOn": 58988,
      "iconOff": 58987,
      "color": 4278254234,
      "isOn": false
    },
    {
      "buttonName": "POWER5",
      "subscribeTopic": "stat/WASISTechOne/POWER5",
      "publishTopic": "cmnd/WASISTechOne/POWER5",
      "messageOnValue": "ON",
      "messageOffValue": "OFF",
      "iconOn": 58988,
      "iconOff": 58987,
      "color": 4284456608,
      "isOn": false
    },
    {
      "buttonName": "POWER3",
      "subscribeTopic": "stat/WASISTechOne/POWER3",
      "publishTopic": "cmnd/WASISTechOne/POWER3",
      "messageOnValue": "ON",
      "messageOffValue": "OFF",
      "iconOn": 58988,
      "iconOff": 58987,
      "color": 4282441936,
      "isOn": false
    },
    {
      "buttonName": "POWER4",
      "subscribeTopic": "stat/WASISTechOne/POWER4",
      "publishTopic": "cmnd/WASISTechOne/POWER4",
      "messageOnValue": "ON",
      "messageOffValue": "OFF",
      "iconOn": 58988,
      "iconOff": 58987,
      "color": 4282168177,
      "isOn": false
    },
    {
      "buttonName": "STATUS1",
      "subscribeTopic": "stat/WASISTechOne/STATUS1",
      "publishTopic": "cmnd/WASISTechOne/STATUS1",
      "messageOnValue": "ON",
      "messageOffValue": "OFF",
      "iconOn": 58988,
      "iconOff": 58987,
      "color": 4294960309,
      "isOn": false
    },
    {
      "buttonName": "STATUS5",
      "subscribeTopic": "stat/WASISTechOne/STATUS5",
      "publishTopic": "cmnd/WASISTechOne/STATUS5",
      "messageOnValue": "ON",
      "messageOffValue": "OFF",
      "iconOn": 58988,
      "iconOff": 58987,
      "color": 4294942842,
      "isOn": false
    },
    {
      "buttonName": "STATUS0",
      "subscribeTopic": "stat/WASISTechOne/STATUS0",
      "publishTopic": "cmnd/WASISTechOne/STATUS0",
      "messageOnValue": "ON",
      "messageOffValue": "OFF",
      "iconOn": 58988,
      "iconOff": 58987,
      "color": 4292664540,
      "isOn": false
    },
    {
      "buttonName": "STATUS3",
      "subscribeTopic": "stat/WASISTechOne/STATUS3",
      "publishTopic": "cmnd/WASISTechOne/STATUS3",
      "messageOnValue": "ON",
      "messageOffValue": "OFF",
      "iconOn": 58988,
      "iconOff": 58987,
      "color": 4294942842,
      "isOn": false
    }
  ];

  @override
  void initState() {
    super.initState();

    _loadServerModelAndConnect();
  }

  Future<void> _loadServerModelAndConnect() async {
    await ref.read(serverConfigProvider.notifier).loadServerConfig();
    await ref.read(buttonConfigProvider.notifier).loadConfig();

    final serverConfig = ref.watch(serverConfigProvider);
    if (serverConfig.isEmpty) {
      print('No server configuration available');
      return;
    }

    final mqttService = ref.read(mqttServiceProvider(context));

    await mqttService.connect(
      serverConfig.first.serverAddress,
      serverConfig.first.clientId,
      serverConfig.first.port,
      serverConfig.first.secureConnection,
      serverConfig.first.username ?? '',
      serverConfig.first.password ?? '',
    );

    ref.read(mqttConnectionStateProvider.notifier).state =
        mqttService.client.connectionStatus!.state;
  }

  @override
  void dispose() {
    _messageController.dispose();
    ref.read(mqttServiceProvider(context)).disconnect();
    _buttonNameController.dispose();
    _subscribeTopicController.dispose();
    _publishTopicController.dispose();
    _messageOnController.dispose();
    _messageOffController.dispose();
    super.dispose();
  }

  void subscribeToTopic(String topic) {
    final mqttService = ref.read(mqttServiceProvider(context));
    if (mqttService.isSubscribed(topic)) {
      print('Already subscribed to $topic');
      // Show a message to the user (e.g., using a SnackBar)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Already subscribed to $topic')),
      );
    } else {
      mqttService.subscribe(topic);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Subscribe to $topic')),
      );
    }
  }

  void unSubscribeFromTopic(String topic) {
    final mqttService = ref.read(mqttServiceProvider(context));
    if (mqttService.isSubscribed(topic)) {
      mqttService.unsubscribe(topic);
    } else {
      print('Not subscribed to $topic');
      // Show a message to the user (e.g., using a SnackBar)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Not subscribed to $topic')),
      );
    }
  }

  Future<void> publishData() async {
    final mqttService = ref.watch(mqttServiceProvider(context));
    // Retrieve stored JSON data
    String? jsonData =
        await ref.read(buttonConfigProvider.notifier).transmitData();

    mqttService.publish('transferData', jsonData);
  }

  Future<void> receiveData() async {
    if (isSubscribed) {
      unSubscribeFromTopic('transferData');
      isSubscribed = false;
    } else {
      subscribeToTopic('transferData');
      isSubscribed = true;
    }
  }

  void toggleSubscription(WidgetRef ref) {
    final isSubscribed = ref.read(isSubscribedProvider.notifier);

    if (isSubscribed.state) {
      unSubscribeFromTopic('transferData'); // Your unsubscribe function
    } else {
      subscribeToTopic('transferData'); // Your subscribe function
    }

    isSubscribed.state = !isSubscribed.state;
  }

  @override
  Widget build(BuildContext context) {
    final mqttService = ref.watch(mqttServiceProvider(context));
    final connectionState = ref.watch(mqttConnectionStateProvider);
    // final receivedMessages = ref.watch(receivedMessagesProvider);
    final buttonConfigs = ref.watch(buttonConfigProvider);
    final isSubscribed = ref.watch(isSubscribedProvider);

    final isConnected = ref.watch(isConnectedProvider);
    final isConnecting = ref.watch(isConnectingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter MQTT Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            if (isConnecting)
              const CircularProgressIndicator()
            else
              Text(
                'MQTT Connection State: ${connectionState?.toString().split('.').last ?? "Not connected"}',
                style: const TextStyle(fontSize: 18),
              ),
            // if (connectionState == "Connecting")
            //   const CircularProgressIndicator()
            // else
            //   Text(
            //     'Connection State: ${connectionState ?? "Not connected"}',
            //     style: const TextStyle(fontSize: 18),
            //   ),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    // mqttService.disconnect();
                    ref.read(mqttServiceProvider(context)).disconnect();
                  },
                  child: const Text('Disconnect'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _loadServerModelAndConnect();
                  },
                  child: const Text('Connect'),
                ),
                ElevatedButton(
                  onPressed: () {
                    publishData();
                    // final jsonStringList =
                    //     buttons.map((map) => json.encode(map)).toList();
                    // // Convert the entire List<String> to a single JSON string
                    // final jsonString = json.encode(jsonStringList);
                    // mqttService.publish('transferData', jsonString);
                  },
                  child: const Text('TD'),
                ),
                ElevatedButton(
                  onPressed: () {
                    toggleSubscription(ref);
                    // setState(() {
                    //   if (isSubscribed) {
                    //     unSubscribeFromTopic('transferData');
                    //     isSubscribed = false;
                    //   } else {
                    //     subscribeToTopic('transferData');
                    //     isSubscribed = true;
                    //   }
                    // });
                  },
                  child: Text(isSubscribed ? 'Stop' : 'RD'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Convert List<Map<String, dynamic>> to List<String>
                    final jsonStringList =
                        buttons.map((map) => json.encode(map)).toList();
                    await ref
                        .read(buttonConfigProvider.notifier)
                        .receiveData(jsonStringList);
                    await ref.read(buttonConfigProvider.notifier).loadConfig();
                  },
                  child: const Text('Test'),
                ),
              ],
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  childAspectRatio: 1.5,
                  crossAxisCount: 2,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                itemCount: buttonConfigs.length,
                itemBuilder: (context, index) {
                  final config = buttonConfigs[index];
                  return GestureDetector(
                    onLongPress: () {
                      _showButtonContextMenu(context, index, config);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: GradientBoxBorder(
                          gradient:
                              LinearGradient(colors: [Colors.blue, Colors.red]),
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(32),
                        color: Color(config.color),
                      ),
                      child: InkWell(
                        onTap: () {
                          ref
                              .read(buttonConfigProvider.notifier)
                              .toggleButton(index);
                          final message = config.isOn
                              ? config.messageOnValue
                              : config.messageOffValue;
                          mqttService.publish(config.publishTopic, message);
                        },
                        child: Stack(
                          // mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Positioned(
                              top: 8.0,
                              left: 8.0,
                              child: Container(
                                width: 48, // Adjust the size as needed
                                height: 48, // Adjust the size as needed
                                decoration: BoxDecoration(
                                  color: config.colorIcon, // Background color
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: config.colorIcon, // Border color
                                    width: 2.0, // Border width
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    config.isOn
                                        ? config.iconOff
                                        : config.iconOn,
                                    size: 32,
                                  ),
                                ),
                              ),
                            ),
                            Center(
                              child: Text(
                                config.buttonName,
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddButtonDialog(context);
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        onTap: (index) {
          if (index == 1) {
            _showSettingsModal(context);
          }
        },
      ),
    );
  }

  void _showAddButtonDialog(BuildContext context) {
    IconData selectedIconOn = Icons.toggle_on;
    IconData selectedIconOff = Icons.toggle_off;
    Color selectedColor = pastelColors[0];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Button'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _buttonNameController,
                    decoration: const InputDecoration(labelText: 'Button Name'),
                  ),
                  TextField(
                    controller: _subscribeTopicController,
                    decoration:
                        const InputDecoration(labelText: 'Subscribe Topic'),
                  ),
                  TextField(
                    controller: _publishTopicController,
                    decoration:
                        const InputDecoration(labelText: 'Publish Topic'),
                  ),
                  TextField(
                    controller: _messageOnController,
                    decoration:
                        const InputDecoration(labelText: 'Message On Value'),
                  ),
                  TextField(
                    controller: _messageOffController,
                    decoration:
                        const InputDecoration(labelText: 'Message Off Value'),
                  ),
                  DropdownButton<IconData>(
                    value: selectedIconOn,
                    onChanged: (IconData? newValue) {
                      setState(() {
                        selectedIconOn = newValue!;
                      });
                    },
                    items: <IconData>[
                      Icons.toggle_on,
                      Icons.lightbulb,
                      Icons.power
                    ].map<DropdownMenuItem<IconData>>((IconData value) {
                      return DropdownMenuItem<IconData>(
                        value: value,
                        child: Icon(value),
                      );
                    }).toList(),
                    hint: const Text('Select Icon for ON'),
                  ),
                  DropdownButton<IconData>(
                    value: selectedIconOff,
                    onChanged: (IconData? newValue) {
                      setState(() {
                        selectedIconOff = newValue!;
                      });
                    },
                    items: <IconData>[
                      Icons.toggle_off,
                      Icons.lightbulb_outline,
                      Icons.power_off
                    ].map<DropdownMenuItem<IconData>>((IconData value) {
                      return DropdownMenuItem<IconData>(
                        value: value,
                        child: Icon(value),
                      );
                    }).toList(),
                    hint: const Text('Select Icon for OFF'),
                  ),
                  DropdownButton<Color>(
                    value: selectedColor,
                    onChanged: (Color? newValue) {
                      setState(() {
                        selectedColor = newValue!;
                      });
                    },
                    items: pastelColors
                        .map<DropdownMenuItem<Color>>((Color value) {
                      return DropdownMenuItem<Color>(
                        value: value,
                        child: Container(
                          width: 24,
                          height: 24,
                          color: value,
                        ),
                      );
                    }).toList(),
                    hint: const Text('Select Background Color'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    final config = ButtonConfig(
                      buttonName: _buttonNameController.text,
                      subscribeTopic: _subscribeTopicController.text,
                      publishTopic: _publishTopicController.text,
                      messageOnValue: _messageOnController.text,
                      messageOffValue: _messageOffController.text,
                      iconOn: selectedIconOn,
                      iconOff: selectedIconOff,
                      color: selectedColor.value,
                    );
                    ref.read(buttonConfigProvider.notifier).addButton(config);
                    subscribeToTopic(
                        config.subscribeTopic); // Subscribe to the new topic
                    Navigator.pop(context);
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showButtonContextMenu(
      BuildContext context, int index, ButtonConfig config) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                _showEditButtonDialog(context, index, config);
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Duplicate'),
              onTap: () {
                ref.read(buttonConfigProvider.notifier).duplicateButton(index);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete'),
              onTap: () {
                ref.read(buttonConfigProvider.notifier).deleteButton(index);
                unSubscribeFromTopic(
                    config.subscribeTopic); // Unsubscribe from the topic
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditButtonDialog(
      BuildContext context, int index, ButtonConfig config) {
    _buttonNameController.text = config.buttonName;
    _subscribeTopicController.text = config.subscribeTopic;
    _publishTopicController.text = config.publishTopic;
    _messageOnController.text = config.messageOnValue;
    _messageOffController.text = config.messageOffValue;

    IconData selectedIconOn = Icons.toggle_on;
    IconData selectedIconOff = Icons.toggle_off;
    Color selectedColor = pastelColors[0];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Button'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _buttonNameController,
                    decoration: const InputDecoration(labelText: 'Button Name'),
                  ),
                  TextField(
                    controller: _subscribeTopicController,
                    decoration:
                        const InputDecoration(labelText: 'Subscribe Topic'),
                  ),
                  TextField(
                    controller: _publishTopicController,
                    decoration:
                        const InputDecoration(labelText: 'Publish Topic'),
                  ),
                  TextField(
                    controller: _messageOnController,
                    decoration:
                        const InputDecoration(labelText: 'Message On Value'),
                  ),
                  TextField(
                    controller: _messageOffController,
                    decoration:
                        const InputDecoration(labelText: 'Message Off Value'),
                  ),
                  DropdownButton<IconData>(
                    value: selectedIconOn,
                    onChanged: (IconData? newValue) {
                      setState(() {
                        selectedIconOn = newValue!;
                      });
                    },
                    items: <IconData>[
                      Icons.toggle_on,
                      Icons.lightbulb,
                      Icons.power
                    ].map<DropdownMenuItem<IconData>>((IconData value) {
                      return DropdownMenuItem<IconData>(
                        value: value,
                        child: Icon(value),
                      );
                    }).toList(),
                    hint: const Text('Select Icon for ON'),
                  ),
                  DropdownButton<IconData>(
                    value: selectedIconOff,
                    onChanged: (IconData? newValue) {
                      setState(() {
                        selectedIconOff = newValue!;
                      });
                    },
                    items: <IconData>[
                      Icons.toggle_off,
                      Icons.lightbulb_outline,
                      Icons.power_off
                    ].map<DropdownMenuItem<IconData>>((IconData value) {
                      return DropdownMenuItem<IconData>(
                        value: value,
                        child: Icon(value),
                      );
                    }).toList(),
                    hint: const Text('Select Icon for OFF'),
                  ),
                  DropdownButton<Color>(
                    value: selectedColor,
                    onChanged: (Color? newValue) {
                      setState(() {
                        selectedColor = newValue!;
                      });
                    },
                    items: pastelColors
                        .map<DropdownMenuItem<Color>>((Color value) {
                      return DropdownMenuItem<Color>(
                        value: value,
                        child: Container(
                          width: 24,
                          height: 24,
                          color: value,
                        ),
                      );
                    }).toList(),
                    hint: const Text('Select Background Color'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    final newConfig = ButtonConfig(
                      buttonName: _buttonNameController.text,
                      subscribeTopic: _subscribeTopicController.text,
                      publishTopic: _publishTopicController.text,
                      messageOnValue: _messageOnController.text,
                      messageOffValue: _messageOffController.text,
                      iconOn: selectedIconOn,
                      iconOff: selectedIconOff,
                      isOn: config.isOn,
                      color: selectedColor.value, // Convert color to int
                    );
                    ref
                        .read(buttonConfigProvider.notifier)
                        .editButton(index, newConfig);
                    unSubscribeFromTopic(config
                        .subscribeTopic); // Unsubscribe from the old topic
                    subscribeToTopic(
                        newConfig.subscribeTopic); // Subscribe to the new topic
                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  final List<Color> pastelColors = [
    Color(0xFFFFA07A),
    Color(0xFFFFB6C1),
    Color(0xFFFF69B4),
    Color(0xFFFF4500),
    Color(0xFFDC143C),
    Color(0xFFFF1493),
    Color(0xFFC71585),
    Color(0xFFFF6347),
    Color(0xFFE34234),
    Color(0xFFD70040),
    Color(0xFFFF4040),
    Color(0xFFB22222),
    Color(0xFFFF6F61),
    Color(0xFFEB4C42),
    Color(0xFFD53032),
    Color(0xFFFFD700),
    Color(0xFFFF8C00),
    Color(0xFFFFA500),
    Color(0xFFFFC87C),
    Color(0xFFFFA64F),
    Color(0xFFFFBF69),
    Color(0xFFFF9F80),
    Color(0xFFFFAA33),
    Color(0xFFFFB347),
    Color(0xFFFFCC99),
    Color(0xFFFFD8B1),
    Color(0xFFF28500),
    Color(0xFFE67300),
    Color(0xFFFFE4B5),
    Color(0xFFFFDAB9),
    Color(0xFFFFE0AC),
    Color(0xFFFFFACD),
    Color(0xFFF0E68C),
    Color(0xFFFFEBCD),
    Color(0xFFFFDEAD),
    Color(0xFFFDD835),
    Color(0xFFFFF176),
    Color(0xFFFFE57F),
    Color(0xFFFFEB99),
    Color(0xFFFFD966),
    Color(0xFFFFC300),
    Color(0xFFFFE135),
    Color(0xFFFFF8DC),
    Color(0xFFFFE4C4),
    Color(0xFFF0DC82),
    Color(0xFF32CD32),
    Color(0xFF98FB98),
    Color(0xFFADFF2F),
    Color(0xFF90EE90),
    Color(0xFF00FF7F),
    Color(0xFF3CB371),
    Color(0xFF20B2AA),
    Color(0xFF00FA9A),
    Color(0xFF40E0D0),
    Color(0xFF48D1CC),
    Color(0xFF2E8B57),
    Color(0xFF66CDAA),
    Color(0xFF8FBC8F),
    Color(0xFFB2D8B2),
    Color(0xFF9ACD32),
    Color(0xFFA1C935),
    Color(0xFF4682B4),
    Color(0xFF5F9EA0),
    Color(0xFF7EC8E3),
    Color(0xFF6B8E23),
    Color(0xFF00CED1),
    Color(0xFF1E90FF),
    Color(0xFF87CEFA),
    Color(0xFF87CEEB),
    Color(0xFF6495ED),
    Color(0xFF40A4FF),
    Color(0xFF00BFFF),
    Color(0xFF1CA9C9),
    Color(0xFF6CA6CD),
    Color(0xFF89CFF0),
    Color(0xFF0096FF),
    Color(0xFFDA70D6),
    Color(0xFFDB7093),
    Color(0xFFBA55D3),
    Color(0xFF9370DB),
    Color(0xFF7B68EE),
    Color(0xFF6A5ACD),
    Color(0xFF8A2BE2),
    Color(0xFF9400D3),
    Color(0xFF9932CC),
    Color(0xFFDDA0DD),
    Color(0xFFE6E6FA),
    Color(0xFFF3E5F5),
    Color(0xFFD8BFD8),
    Color(0xFFB39DDB),
    Color(0xFFC0A3E5),
    Color(0xFFAF69EE),
    Color(0xFFFFC0CB),
    Color(0xFFFFA6C9),
    Color(0xFFF8B9D4),
    Color(0xFFFFB3DE),
    Color(0xFFFF91A4),
    Color(0xFFFF85A2),
    Color(0xFFFF778A),
    Color(0xFFF4A6C1),
    Color(0xFFE68FAC),
    Color(0xFFD36E96),
    Color(0xFFC85A7A),
    Color(0xFFEFBBCC),
    Color(0xFFE75480),
    Color(0xFFF5F5DC),
    Color(0xFFFDF5E6),
    Color(0xFFFFFAF0),
    Color(0xFFF8F8FF),
    Color(0xFFDCDCDC),
    Color(0xFFDDA0DD),
    Color(0xFF8B0000),
    Color(0xFF556B2F),
    Color(0xFF8FBC8F),
    Color(0xFF696969),
    Color(0xFF808080),
    Color(0xFFA9A9A9),
    Color(0xFFC0C0C0),
    Color(0xFFD3D3D3),
    Color(0xFFBEBEBE),
    Color(0xFFE0E0E0),
    Color(0xFFFA8072),
    Color(0xFFFFD1D1),
    Color(0xFFFFD6D6),
    Color(0xFFFFCCCC),
    Color(0xFFFFC6C6),
    Color(0xFFFFD8D8),
    Color(0xFFFFE1E1),
    Color(0xFFFFEBEB),
    Color(0xFFFFC5C5),
    Color(0xFFFFCBCB),
    Color(0xFFFFD2D2),
    Color(0xFFFFDADA),
    Color(0xFFFFE0E0),
    Color(0xFFFFE5E5),
    Color(0xFFFFECEC),
    Color(0xFFFFF0F0),
    Color(0xFFFAF0E6),
    Color(0xFFFDF5E6),
    Color(0xFFFFF5EE),
    Color(0xFFFFF8DC),
    Color(0xFFEEE8AA),
    Color(0xFFF5DEB3),
    Color(0xFFE32636),
    Color(0xFFFFBF00),
    Color(0xFFDAA520),
    Color(0xFFB76E79),
    Color(0xFFAF6E4D),
    Color(0xFFCD7F32),
    Color(0xFF8B4513),
    Color(0xFFA0522D),
    Color(0xFF6F4E37),
    Color(0xFF8B0000),
    Color(0xFF8B008B),
    Color(0xFF4B0082),
    Color(0xFF6A5ACD),
    Color(0xFF708090),
    Color(0xFF2F4F4F),
    Color(0xFF191970),
  ];

  void _showSettingsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final serverModels = ref.watch(serverConfigProvider);
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Add Server'),
              onTap: () {
                Navigator.pop(context);
                showAddServerDialog(context);
              },
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: serverModels.length,
              itemBuilder: (context, index) {
                final serverModel = serverModels[index];
                return ListTile(
                  title: Text(serverModel.brokerName),
                  subtitle: Text(serverModel.serverAddress),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          Navigator.pop(context);
                          _showEditServerDialog(context, index, serverModel);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          ref
                              .read(serverConfigProvider.notifier)
                              .deleteServer(index);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditServerDialog(
      BuildContext context, int index, ServerConfig serverConfig) {
    final TextEditingController brokerNameController =
        TextEditingController(text: serverConfig.brokerName);
    final TextEditingController serverAddressController =
        TextEditingController(text: serverConfig.serverAddress);
    final TextEditingController portController =
        TextEditingController(text: serverConfig.port.toString());
    final TextEditingController usernameController =
        TextEditingController(text: serverConfig.username);
    final TextEditingController passwordController =
        TextEditingController(text: serverConfig.password);
    final TextEditingController keepAlivePeriodController =
        TextEditingController(text: serverConfig.keepAlivePeriod.toString());
    final TextEditingController clientIdController =
        TextEditingController(text: serverConfig.clientId);

    bool secureConnection = serverConfig.secureConnection;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Server'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: brokerNameController,
                    decoration: const InputDecoration(labelText: 'Broker Name'),
                  ),
                  TextField(
                    controller: serverAddressController,
                    decoration:
                        const InputDecoration(labelText: 'Server Address'),
                  ),
                  TextField(
                    controller: portController,
                    decoration: const InputDecoration(labelText: 'Port'),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: usernameController,
                    decoration: const InputDecoration(labelText: 'Username'),
                  ),
                  TextField(
                    controller: passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                  ),
                  TextField(
                    controller: clientIdController,
                    decoration: const InputDecoration(labelText: 'ClientId'),
                  ),
                  TextField(
                    controller: keepAlivePeriodController,
                    decoration:
                        const InputDecoration(labelText: 'Keep Alive Period'),
                    keyboardType: TextInputType.number,
                  ),
                  SwitchListTile(
                    title: const Text('Secure Connection'),
                    value: secureConnection,
                    onChanged: (value) {
                      setState(() {
                        secureConnection = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    final updatedServerConfig = ServerConfig(
                      brokerName: brokerNameController.text,
                      serverAddress: serverAddressController.text,
                      port: int.parse(portController.text),
                      username: usernameController.text,
                      password: passwordController.text,
                      clientId: clientIdController.text,
                      secureConnection: secureConnection,
                      keepAlivePeriod:
                          int.parse(keepAlivePeriodController.text),
                    );
                    ref
                        .read(serverConfigProvider.notifier)
                        .updateServerConfig(index, updatedServerConfig);
                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void showAddServerDialog(BuildContext context) {
    final TextEditingController brokerNameController =
        TextEditingController(text: 'HiveMQ');
    final TextEditingController serverAddressController = TextEditingController(
        text: 'e30ec8cdf6ef4746b68cb97c21d1faff.s1.eu.hivemq.cloud');
    final TextEditingController portController =
        TextEditingController(text: '8883');
    final TextEditingController usernameController =
        TextEditingController(text: 'mocheffendi');
    final TextEditingController passwordController =
        TextEditingController(text: 'EVANorma1984');
    final TextEditingController keepAlivePeriodController =
        TextEditingController(text: '60');
    final TextEditingController clientIdController =
        TextEditingController(text: 'MQTTDashboard-888');

    bool secureConnection = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Server'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: brokerNameController,
                      decoration:
                          const InputDecoration(labelText: 'Broker Name'),
                    ),
                    TextField(
                      controller: serverAddressController,
                      decoration:
                          const InputDecoration(labelText: 'Server Address'),
                    ),
                    TextField(
                      controller: portController,
                      decoration: const InputDecoration(labelText: 'Port'),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      controller: usernameController,
                      decoration: const InputDecoration(labelText: 'Username'),
                    ),
                    TextField(
                      controller: passwordController,
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                    ),
                    TextField(
                      controller: clientIdController,
                      decoration: const InputDecoration(labelText: 'ClientId'),
                    ),
                    TextField(
                      controller: keepAlivePeriodController,
                      decoration:
                          const InputDecoration(labelText: 'Keep Alive Period'),
                      keyboardType: TextInputType.number,
                    ),
                    SwitchListTile(
                      title: const Text('Secure Connection'),
                      value: secureConnection,
                      onChanged: (value) {
                        setState(() {
                          secureConnection = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    final serverConfig = ServerConfig(
                      brokerName: brokerNameController.text,
                      serverAddress: serverAddressController.text,
                      port: int.parse(portController.text),
                      username: usernameController.text,
                      password: passwordController.text,
                      clientId: clientIdController.text,
                      secureConnection: secureConnection,
                      keepAlivePeriod:
                          int.parse(keepAlivePeriodController.text),
                    );
                    ref
                        .read(serverConfigProvider.notifier)
                        .addServer(serverConfig);
                    Navigator.pop(context);
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
