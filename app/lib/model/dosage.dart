import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class Dosage {
  const Dosage({required this.name, required this.dose, this.recipient = 0});

  final String name;
  final int recipient;
  final int dose;

  factory Dosage.fromJson(Map<String, dynamic> data) {
    if (data
        case {
          'name': String name,
          'dose': int dose,
          'recipient': int recipient
        }) {
      return Dosage(name: name, dose: dose, recipient: recipient);
    } else {
      throw FormatException('Invalid JSON: $data');
    }
  }

  static List<Dosage> fromCollection(
          List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) =>
      docs.map((doc) => Dosage.fromJson(doc.data())).toList();

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dose': dose,
      'recipient': recipient,
    };
  }

  @override
  String toString() => json.encode(toJson());
}
