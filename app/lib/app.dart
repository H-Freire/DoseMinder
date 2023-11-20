import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:doseminder/view/home_screen.dart';
import 'package:doseminder/view/sign_in_screen.dart';
import 'package:doseminder/providers.dart';
import 'package:doseminder/constants.dart';

import 'package:mqtt_client/mqtt_server_client.dart';

class App extends ConsumerWidget {
  App({super.key});

  final client = MqttServerClient('q35f5f23.ala.us-east-1.emqxsl.com', ''); // Replace with your broker's address
  client.connect('flutter_client'); // Replace with a unique client ID

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'DoseMinder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(dmPrimary),
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.montserratTextTheme(),
        useMaterial3: true,
      ),
      home: ref.watch(user).isLogged
          ? HomeScreen(client: client)
          : const SignInScreen(),
    );
  }
}
