import 'package:flutter/material.dart';
import 'package:pokemondex/core/di.dart';
import 'package:pokemondex/core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDI();

  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      routerConfig: AppRouter.router,
    );
  }
}