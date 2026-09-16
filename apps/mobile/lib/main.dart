import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const DakkanaApp());
}

class DakkanaApp extends StatelessWidget {
  const DakkanaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'دَكانة',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
        fontFamily: 'sans-serif',
      ),
      home: const Scaffold(
        body: Center(
          child: Text(
            'دَكانة\nكل حساب دَكانتك بإيدك',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
