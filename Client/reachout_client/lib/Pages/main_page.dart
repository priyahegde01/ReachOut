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
        Padding(
          padding: const EdgeInsets.only(top: DefaultSpacing.medium),
          child: Center(child: RequestBoard()),
        ),
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

    return Container(
      height: 48,
      color: colorTheme.surfaceContainer,
      padding: .symmetric(horizontal: DefaultSpacing.medium),
      child: Row(
        spacing: DefaultSpacing.large,
        children: [
          TextButton(
            onPressed: () {},
            child: StatusIndicator(label: "Light Mode", icon: Icons.light_mode),
          ),
          StatusIndicator(label: "connected", icon: Icons.wifi),
          LabelText("64 points earned", size: .large),
        ],
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
    return Column(
      spacing: DefaultSpacing.extraLarge,
      children: [
        RequestBoardSection(title: "Accepted by me"),
        RequestBoardSection(title: "Requested by me"),
        RequestBoardSection(title: "Others' requests"),
      ],
    );
  }
}

class RequestBoardSection extends StatelessWidget {
  const new({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      spacing: DefaultSpacing.small,
      children: [
        TitleText(title, size: .medium),
        Column(
          spacing: DefaultSpacing.xxs,
          children: [
            RequestListTile(
              title: "Build the helicopter",
              description: "Just build it.",
            ),
            RequestListTile(
              title: "Build the helicopter",
              description: "Just build it.",
            ),
          ],
        ),
      ],
    );
  }
}

class RequestListTile extends StatelessWidget {
  const new({super.key, required this.title, required this.description});
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final colorTheme = Theme.of(context).colorScheme;

    return Container(
      width: 1260,
      height: 60,
      decoration: BoxDecoration(
        // TODO: change color
        color: colorTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: .symmetric(vertical: 10, horizontal: 16),
      child: Row(
        mainAxisAlignment: .spaceBetween,
        children: [
          BodyText(title, size: .large),
          IconWithDefaults(Icons.keyboard_arrow_down),
        ],
      ),
    );
  }
}
