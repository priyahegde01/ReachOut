import 'package:material_ui/material_ui.dart';
import 'package:reachout_client/routes.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: routes,
      themeMode: .light,
      theme: ThemeData.light().copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF38761D)),
      ),
      darkTheme: ThemeData.dark()
    );
  }
}
