import 'package:flutter/material.dart';
import 'screens/login_screen.dart'; // Login ekranını import ettiğimizden emin olun

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Sağ üstteki "Debug" bandını kaldırır
      title: 'Teknik Servis',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3:
            false, // Görünüm sorunlarını önlemek için şimdilik false yapabilirsiniz
      ),
      home: LoginScreen(), // <-- BURASI ÇOK ÖNEMLİ: Uygulama buradan başlar
    );
  }
}
