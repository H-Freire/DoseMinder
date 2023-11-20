import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mqtt_client/mqtt_client.dart';

import 'package:doseminder/service/user_service.dart';
import 'package:doseminder/service/mqtt_service.dart';

// Authentication
final auth          = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);
final userProvider  = ChangeNotifierProvider.autoDispose<UserService>(
    (ref) => UserService()..user = ref.watch(auth).currentUser);
final signInService = Provider<GoogleSignIn>((ref) => GoogleSignIn());

// Firestore Database
final db = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);
final collectionProvider = Provider.autoDispose
    .family<CollectionReference<Map<String, dynamic>>, String>((ref, userId) {
  return ref.watch(db).collection(userId);
});

// MQTT
final payloadBuilder = Provider<MqttClientPayloadBuilder>((ref) => MqttClientPayloadBuilder());
final mqttProvider   = Provider<MqttService>((ref) => MqttService(ref.read(payloadBuilder)));
