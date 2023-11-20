import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  MqttService(this.builder) {
    connect().then((mqtt) => client = mqtt);
  }

  late MqttServerClient client;
  MqttClientPayloadBuilder builder;

  void publish({required String topic, required String data}) {
    builder.addString(data);
    client.publishMessage(topic, MqttQos.exactlyOnce, builder.payload!);
    builder.clear();
  }

  Future<MqttServerClient> connect() async {
    final client = MqttServerClient.withPort(
      'broker.emqx.io',
      'doseminder',
      1883,
    )
      ..logging(on: true)
      ..onConnected     = onConnected
      ..onDisconnected  = onDisconnected
      ..onUnsubscribed  = onUnsubscribed
      ..onSubscribed    = onSubscribed
      ..onSubscribeFail = onSubscribeFail
      ..pongCallback    = pong
      ..autoReconnect   = true
      ..keepAlivePeriod = 60;

    final connMessage = MqttConnectMessage()
        .authenticateAs('emqx', 'public')
        .withWillTopic('serial_request')
        .withWillMessage('conectei?')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);

    client.connectionMessage = connMessage;

    try {
      await client.connect();
    } catch (e) {
      debugPrint('Exception: $e');
      client.disconnect();
    }

    return client;
  }
}

// connection succeeded
void onConnected() => debugPrint('Connected');

// unconnected
void onDisconnected() => debugPrint('Disconnected');

// subscribe to topic succeeded
void onSubscribed(String topic) => debugPrint('Subscribed topic: $topic');

// subscribe to topic failed
void onSubscribeFail(String topic) => debugPrint('Failed to subscribe $topic');

// unsubscribe succeeded
void onUnsubscribed(String? topic) => debugPrint('Unsubscribed topic: $topic');

// PING response received
void pong() => debugPrint('Ping response client callback invoked');
