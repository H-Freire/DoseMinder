import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:doseminder/view/home_screen.dart';
import 'package:doseminder/view/sign_in_screen.dart';
import 'package:doseminder/providers.dart';
import 'package:doseminder/constants.dart';

import 'package:doseminder/model/mqtt_connection.dart';

class App extends ConsumerWidget {
  App({super.key});

  // https://cloud-intl.emqx.com/console/deployments/q35f5f23/overview
  //final client = MqttServerClient('q35f5f23.ala.us-east-1.emqxsl.com', ''); // Replace with your broker's address
  final client = connect(); // Replace with a unique client ID

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
