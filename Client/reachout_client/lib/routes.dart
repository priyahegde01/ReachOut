import 'package:go_router/go_router.dart';
import 'package:reachout_client/Pages/main_page.dart';

final routes = GoRouter(
    routes: [
      GoRoute(
        path: "/",
        builder: (context, state) => const MainPage(),
      ),
    ],
  );