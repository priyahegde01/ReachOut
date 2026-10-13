import 'package:material_ui/material_ui.dart';
import 'package:reachout_client/Pages/components/misc.dart';
import 'package:reachout_client/Pages/components/text.dart';

enum RequestType {
  acceptedByMe,
  requestedByMe,
  requestedByOther
}

class DummyRequest {
  const new({required this.title, required this.description, required this.type, this.accepted = false});
  final String title;
  final String description;
  final RequestType type;
  final bool accepted;
}

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
        Padding(
          padding: .directional(top: DefaultSpacing.large),
          child: Column(
            spacing: DefaultSpacing.small,
            children: [
              Expanded(child: RequestBoard()),
              Align(alignment: .bottomCenter, child: MainPageStatusBar()),
            ],
          ),
        ),
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
  new({super.key});
  // TODO: remove this and provide it through a bloc or cubit.
  final List<DummyRequest> requests = [
    DummyRequest(title: "Burga", description: "This a burga", type: .acceptedByMe),
    DummyRequest(title: "Burga", description: "This a burga", type: .requestedByMe),
    DummyRequest(title: "Burga", description: "This a burga", type: .requestedByOther),
    DummyRequest(title: "Cheese", description: "The moon is made out of it.", type: .requestedByOther),
    DummyRequest(title: "Cheese", description: "The moon is made out of it.", type: .requestedByOther),
    DummyRequest(title: "Cheese", description: "The moon is made out of it.", type: .requestedByOther),
    DummyRequest(title: "Cheese", description: "The moon is made out of it.", type: .requestedByOther),
    DummyRequest(title: "Cheese", description: "The moon is made out of it.", type: .requestedByOther),
    DummyRequest(title: "Cheese", description: "The moon is made out of it.", type: .requestedByOther),
    DummyRequest(title: "Cheese", description: "The moon is made out of it.", type: .requestedByOther),
    DummyRequest(title: "Cheese", description: "The moon is made out of it.", type: .requestedByOther),
    DummyRequest(title: "Cheese", description: "The moon is made out of it.", type: .requestedByOther),
    DummyRequest(title: "Cheese", description: "The moon is made out of it.", type: .requestedByOther),
    DummyRequest(title: "Cheese", description: "The moon is made out of it.", type: .requestedByOther),
    DummyRequest(title: "Cheese", description: "The moon is made out of it.", type: .requestedByOther),
    DummyRequest(title: "Cheese", description: "The moon is made out of it.", type: .requestedByOther),
    DummyRequest(title: "Cheese", description: "The moon is made out of it.", type: .requestedByOther),
    DummyRequest(title: "Cheese", description: "The moon is made out of it.", type: .requestedByOther),
    DummyRequest(title: "Cheese", description: "The moon is made out of it.", type: .requestedByOther),
    DummyRequest(title: "Cheese", description: "The moon is made out of it.", type: .requestedByOther),

  ];

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 0.7,
      child: CustomScrollView(
        //spacing: DefaultSpacing.extraLarge,
        slivers: [
          RequestBoardSection(title: "Accepted by me", requests: requests.where((request) => request.type == .acceptedByMe).toList()),
          RequestBoardSection(title: "Requested by me", requests: requests.where((request) => request.type == .requestedByMe).toList()),
          RequestBoardSection(title: "Others' requests", requests: requests.where((request) => request.type == .requestedByOther).toList()),
        ],
      ),
    );
  }
}

class RequestBoardSection extends StatelessWidget {
  const new({super.key, required this.title, required this.requests});
  final String title;
  final List<DummyRequest> requests; 

  @override
  Widget build(BuildContext context) {
    
    return SliverPadding(
      padding: .only(bottom: DefaultSpacing.extraLarge),
      sliver: SliverList.separated(
        // + 1 since we must account for the title as well.
        itemCount: requests.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) return TitleText(title, size: .medium);
      
          final request = requests[index - 1];
          return RequestListTile(title: request.title, description: request.description);
        },
        separatorBuilder: (context, index) {
          return index == 0 ? const SizedBox(height: DefaultSpacing.small) : const SizedBox(height: DefaultSpacing.xxs);
        },
      ),
    );
  }
}

// TODO: make this expandable, maybe add some fancy animations. Add buttons relevant for each request type shown as well.
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
