import 'package:material_ui/material_ui.dart';
import 'package:reachout_client/Pages/components/misc.dart';
import 'package:reachout_client/Pages/components/text.dart';

class MainPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: MainPageStructure());
  }
}

/// The overall structure of the main page.
class MainPageStructure extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          // These are arbitrarily chosen coordinates.
          right: 80,
          bottom: 100,
          child: FloatingActionButton.extended(
            onPressed: () {},
            label: TitleText("Request Help", size: .medium),
            icon: Icon(Icons.add),
          ),
        ),
        Align(alignment: .bottomCenter, child: MainPageStatusBar()),
      ],
    );
  }
}

/// Contains semi-important status elements.
///
/// Status elements include the theme mode (dark or light theme), connection status
/// and points earned by the user.
class MainPageStatusBar extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final colorTheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 48,
      child: Container(
        color: colorTheme.surfaceContainer,
        child: Row(
          spacing: DefaultSpacing.large,
          children: [
            TextButton(
              onPressed: () {},
              child: StatusIndicator(
                label: "Light Mode",
                icon: Icons.light_mode,
              ),
            ),
            StatusIndicator(label: "connected", icon: Icons.wifi),
            LabelText("64 points earned", size: .large)
          ],
        ),
      ),
    );
  }
}

class StatusIndicator extends StatelessWidget {
  const new({super.key, required this.label, required this.icon});
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorTheme = Theme.of(context).colorScheme;

    return Row(
      spacing: DefaultSpacing.small,
      children: [
        IconWithDefaults(icon, filled: true, color: colorTheme.onSurface),
        LabelText(label, size: .large),
      ],
    );
  }
}

/// Contains the accepted, requested, and requested by others lists.
class RequestBoard extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
