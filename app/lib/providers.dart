import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doseminder/model/user_change_notifier.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

final db = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);
final auth = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);
final user = ChangeNotifierProvider.autoDispose<UserChangeNotifier>(
    (ref) => UserChangeNotifier()..user = ref.watch(auth).currentUser);
final collectionProvider = FutureProvider.autoDispose
    .family<CollectionReference<Map<String, dynamic>>, String>(
        (ref, userId) async {
  return ref.watch(db).collection(userId);
});
final signInService = Provider<GoogleSignIn>((ref) => GoogleSignIn());
