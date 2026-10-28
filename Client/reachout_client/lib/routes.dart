import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reachout_client/Pages/login_page.dart';
import 'package:reachout_client/Pages/main_page.dart';
import 'package:reachout_client/state/request_board_state.dart';

final routes = GoRouter(
  routes: [
    GoRoute(
      path: "/",
      builder: (context, state) => LoginPage(
        onRegister: () => _finishAuthentication(
          context,
          context.read<RequestBoardCubit>().registerNewUser,
        ),
        onLogin: (userId) => _finishAuthentication(
          context,
          () => context.read<RequestBoardCubit>().loginWithUserID(userId),
        ),
      ),
    ),
    GoRoute(path: "/board", builder: (context, state) => const MainPage()),
  ],
);

Future<void> _finishAuthentication(
  BuildContext context,
  Future<void> Function() authenticate,
) async {
  try {
    await authenticate();
    if (context.mounted) context.go("/board");
  } catch (error) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(error.toString())));
  }
}
