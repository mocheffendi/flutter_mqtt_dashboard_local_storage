class ServerConfig {
  final String brokerName;
  final String serverAddress;
  final int port;
  final String clientId;
  final String? username;
  final String? password;
  final bool secureConnection;
  final int keepAlivePeriod;

  ServerConfig({
    required this.brokerName,
    required this.serverAddress,
    required this.port,
    required this.clientId,
    this.username,
    this.password,
    required this.secureConnection,
    required this.keepAlivePeriod,
  });

  ServerConfig copyWith({
    String? brokerName,
    String? serverAddress,
    int? port,
    String? clientId,
    String? username,
    String? password,
    bool? secureConnection,
    int? keepAlivePeriod,
  }) {
    return ServerConfig(
      brokerName: brokerName ?? this.brokerName,
      serverAddress: serverAddress ?? this.serverAddress,
      port: port ?? this.port,
      clientId: clientId ?? this.clientId,
      username: username ?? this.username,
      password: password ?? this.password,
      secureConnection: secureConnection ?? this.secureConnection,
      keepAlivePeriod: keepAlivePeriod ?? this.keepAlivePeriod,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'brokerName': brokerName,
      'serverAddress': serverAddress,
      'port': port,
      'clientId': clientId,
      'username': username,
      'password': password,
      'secureConnection': secureConnection,
      'keepAlivePeriod': keepAlivePeriod,
    };
  }

  factory ServerConfig.fromMap(Map<String, dynamic> map) {
    return ServerConfig(
      brokerName: map['brokerName'],
      serverAddress: map['serverAddress'],
      port: map['port'],
      clientId: map['clientId'],
      username: map['username'],
      password: map['password'],
      secureConnection: map['secureConnection'],
      keepAlivePeriod: map['keepAlivePeriod'],
    );
  }
}
