import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:doseminder/providers.dart';

Future<void> signUp(BuildContext context, WidgetRef ref) async {
  final GoogleSignInAccount? account = await ref.read(signInService).signIn();

  if (account != null) {
    final GoogleSignInAuthentication authentication =
        await account.authentication;
    final AuthCredential authCredential = GoogleAuthProvider.credential(
      idToken: authentication.idToken,
      accessToken: authentication.accessToken,
    );

    // Retrieve user's credentials
    UserCredential credentials =
        await ref.read(auth).signInWithCredential(authCredential);

    ref.read(user).user = credentials.user;
  }
}

class SignInScreen extends ConsumerWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Image(
                image: AssetImage('assets/icon.png'),
                height: 250,
                fit: BoxFit.scaleDown),
            Text('DoseMinder',
                style: Theme.of(context)
                    .textTheme
                    .displayMedium!
                    .copyWith(color: Colors.white70)),
            const SizedBox(height: 75),
            ElevatedButton(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 50,
                    width: 30,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/google.png'),
                        fit: BoxFit.contain,
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 20),
                  const Text("Entrar com uma conta Google")
                ],
              ),
              onPressed: () => signUp(context, ref),
            ),
          ],
        ),
      ),
    );
  }
}
