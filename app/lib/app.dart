import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:doseminder/view/home_screen.dart';
import 'package:doseminder/view/sign_in_screen.dart';
import 'package:doseminder/providers.dart';
import 'package:doseminder/constants.dart';

class App extends ConsumerWidget {
  const App({super.key});

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
      home: ref.watch(user).isLogged ? const HomeScreen() : const SignInScreen(),
    );
  }
}
