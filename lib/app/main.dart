import 'package:flutter/material.dart';
import 'package:pokemondex/core/di.dart';
import 'package:pokemondex/core/router/app_router.dart';
import 'package:pokemondex/ui/detail/pokemon_detail_screen.dart';
import 'package:pokemondex/ui/list/pokemon_list_screen.dart';

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