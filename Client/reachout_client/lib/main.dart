import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reachout_client/routes.dart';
import 'package:reachout_client/state/models/preferences.dart';
import 'package:reachout_client/state/prefences_state.dart';
import 'package:reachout_client/state/repositories/preference_repository.dart';
import 'package:reachout_client/state/request_board_state.dart';

void main() {
  final preferences = PreferencesRepository();
  final preferencesCubit = PreferencesCubit(preferences);
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider.value(value: preferencesCubit),
        BlocProvider(create:(context) => RequestBoardCubit())
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
          theme: ThemeData.light().copyWith(
            colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF38761D)),
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
