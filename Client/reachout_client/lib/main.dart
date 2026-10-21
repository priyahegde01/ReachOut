import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reachout_client/routes.dart';
import 'package:reachout_client/state/models/preferences.dart';
import 'package:reachout_client/state/preferences_state.dart';
import 'package:reachout_client/state/repositories/preference_repository.dart';
import 'package:reachout_client/state/request_board_state.dart';

void main() {
  // Must run first: the preferences cubit reads storage as soon as it's created.
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = PreferencesRepository();
  final preferencesCubit = PreferencesCubit(preferences);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider.value(value: preferencesCubit),
        BlocProvider(create: (context) => RequestBoardCubit(preferencesCubit)),
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
            useMaterial3: true,
            scaffoldBackgroundColor: Colors.white,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF38761D),
            ).copyWith(
              surface: Colors.white
            ),
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
