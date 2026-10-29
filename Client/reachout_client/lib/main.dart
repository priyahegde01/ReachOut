import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reachout_client/routes.dart';
import 'package:reachout_client/state/models/preferences.dart';
import 'package:reachout_client/state/repositories/network_repository.dart';
import 'package:reachout_client/state/preferences_state.dart';
import 'package:reachout_client/state/repositories/preference_repository.dart';
import 'package:reachout_client/state/repositories/request_repository.dart';
import 'package:reachout_client/state/request_board_state.dart';

void main() {
  // Must run first: the preferences cubit reads storage as soon as it's created.
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = PreferencesRepository();
  final requests = RequestRepository();
  final networking = NetworkRepository();
  final preferencesCubit = PreferencesCubit(preferences, networking);
  // TODO: get UUID and pass it to requestsCubit. Make sure that it actually has a UUID before passing it.
  // You'll probably need to wait for some event before proceeding.
  
  final requestsCubit = RequestBoardCubit(requests, networking, preferences);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider.value(value: preferencesCubit),
        BlocProvider.value(value: requestsCubit),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PreferencesCubit, PreferencesState>(
      builder: (context, state) {
        return MaterialApp.router(
          title: "ReachOut",
          theme: ThemeData(
            scaffoldBackgroundColor: Colors.white,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF38761D),
            ).copyWith(surface: Colors.white),
          ),
          darkTheme: ThemeData.dark(),
          themeMode: state is PreferencesLoadSuccess
              ? state.themeMode
              // In case the themeMode has not been set before, default to system.
              : ThemeMode.system,
          routerConfig: routes,
        );
      },
    );
  }
}
