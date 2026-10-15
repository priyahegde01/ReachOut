import 'package:material_ui/material_ui.dart';
import 'package:reachout_client/Pages/components/misc.dart';
import 'package:reachout_client/Pages/components/text.dart';

enum RequestType { acceptedByMe, requestedByMe, requestedByOther }

enum RequestStatus { none, pending, accepted }

class DummyRequest {
  const new({
    required this.title,
    required this.description,
    required this.type,
    this.status = .none,
  });
  final String title;
  final String description;
  final RequestType type;
  final RequestStatus status;
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
  const new({super.key, required this.label, required this.icon, this.color});
  final String label;
  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: DefaultSpacing.small,
      children: [
        IconWithDefaults(icon, filled: true, color: color),
        LabelText(label, size: .large, color: color),
      ],
    );
  }
}

/// Contains the accepted, requested, and requested by others lists.
class RequestBoard extends StatelessWidget {
  new({super.key});
  // TODO: remove this and provide it through a bloc or cubit.
  final List<DummyRequest> requests = [
    DummyRequest(
      title: "Burga",
      description: "This a burga",
      type: .acceptedByMe,
    ),
    DummyRequest(
      title: "Burga",
      description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent semper ipsum a ex vestibulum, sed rutrum sem euismod. Sed molestie elit lorem, vel facilisis magna vulputate in. Integer pharetra tempor quam, vitae viverra mauris rutrum nec. Aliquam quis molestie diam, eu fringilla orci. Quisque ut ante nec justo elementum posuere ut a eros. Aliquam cursus lorem ut purus condimentum, eu lobortis lacus pellentesque. Vestibulum rhoncus enim maximus velit ullamcorper semper.",
      type: .requestedByMe,
      status: .accepted,
    ),
    DummyRequest(
      title: "Burga",
      description: "This a burga",
      type: .requestedByMe,
      status: .pending,
    ),
    DummyRequest(
      title: "Burga",
      description: "This a burga",
      type: .requestedByMe,
      status: .pending,
    ),
    DummyRequest(
      title: "Burga",
      description: "This a burga",
      type: .requestedByOther,
    ),
    DummyRequest(
      title: "Cheese",
      description: "The moon is made out of it.",
      type: .requestedByOther,
    ),
    DummyRequest(
      title: "Cheese",
      description: "The moon is made out of it.",
      type: .requestedByOther,
    ),
    DummyRequest(
      title: "Cheese",
      description: "The moon is made out of it.",
      type: .requestedByOther,
    ),
    DummyRequest(
      title: "Cheese",
      description: "The moon is made out of it.",
      type: .requestedByOther,
    ),
    DummyRequest(
      title: "Cheese",
      description: "The moon is made out of it.",
      type: .requestedByOther,
    ),
    DummyRequest(
      title: "Cheese",
      description: "The moon is made out of it.",
      type: .requestedByOther,
    ),
    DummyRequest(
      title: "Cheese",
      description: "The moon is made out of it.",
      type: .requestedByOther,
    ),
    DummyRequest(
      title: "Cheese",
      description: "The moon is made out of it.",
      type: .requestedByOther,
    ),
    DummyRequest(
      title: "Cheese",
      description: "The moon is made out of it.",
      type: .requestedByOther,
    ),
    DummyRequest(
      title: "Cheese",
      description: "The moon is made out of it.",
      type: .requestedByOther,
    ),
    DummyRequest(
      title: "Cheese",
      description: "The moon is made out of it.",
      type: .requestedByOther,
    ),
    DummyRequest(
      title: "Cheese",
      description: "The moon is made out of it.",
      type: .requestedByOther,
    ),
    DummyRequest(
      title: "Cheese",
      description: "The moon is made out of it.",
      type: .requestedByOther,
    ),
    DummyRequest(
      title: "Cheese",
      description: "The moon is made out of it.",
      type: .requestedByOther,
    ),
    DummyRequest(
      title: "Cheese",
      description: "The moon is made out of it.",
      type: .requestedByOther,
    ),
    DummyRequest(
      title: "Cheese",
      description: "The moon is made out of it.",
      type: .requestedByOther,
    ),
    DummyRequest(
      title: "Cheese",
      description: "The moon is made out of it.",
      type: .requestedByOther,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 0.7,
      child: CustomScrollView(
        //spacing: DefaultSpacing.extraLarge,
        slivers: [
          RequestBoardSection(
            title: "Accepted by me",
            requests: requests
                .where((request) => request.type == .acceptedByMe)
                .toList(),
          ),
          RequestBoardSection(
            title: "Requested by me",
            requests: requests
                .where((request) => request.type == .requestedByMe)
                .toList(),
          ),
          RequestBoardSection(
            title: "Others' requests",
            requests: requests
                .where((request) => request.type == .requestedByOther)
                .toList(),
          ),
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
          return RequestListTile(
            title: request.title,
            description: request.description,
            type: request.type,
            status: request.status,
            expanded: index == 1 || index == 2,
            onPrimaryActionTap: () {},
            onSecondaryActionTap: () {},
          );
        },
        separatorBuilder: (context, index) {
          return index == 0
              ? const SizedBox(height: DefaultSpacing.small)
              : const SizedBox(height: DefaultSpacing.xxs);
        },
      ),
    );
  }
}

// TODO: make this expandable, maybe add some fancy animations. Add buttons relevant for each request type shown as well.
class RequestListTile extends StatefulWidget {
  const new({
    super.key,
    required this.title,
    required this.description,
    required this.type,
    this.status = .none,
    this.expanded = false,
    this.time,
    required this.onPrimaryActionTap,
    this.onSecondaryActionTap,
  });
  final String title;
  final String description;
  final RequestType type;
  final RequestStatus status;
  final bool expanded;
  final Duration? time;
  final VoidCallback onPrimaryActionTap;
  final VoidCallback? onSecondaryActionTap;

  @override
  State<RequestListTile> createState() => _RequestListTileState();
}

class _RequestListTileState extends State<RequestListTile> {
  bool expanded = false;
  bool hoveredOver = false;

  @override
  Widget build(BuildContext context) {
    final colorTheme = Theme.of(context).colorScheme;

    final primaryLabel = [
      "Show location",
      widget.status == .accepted ? "Mark complete" : "Cancel",
      "Take request",
    ][widget.type.index];

    final secondaryLabel = [
      "Cancel",
      widget.status == .accepted ? "Cancel" : null,
      null,
    ][widget.type.index];

    final actionButtons = Row(
      spacing: DefaultSpacing.small,
      children: [
        if (secondaryLabel != null) ...[
          // TODO: change to an OutlinedButton.icon with a custom style to make the border the color onSurfaceVariant.
          FilledButton.tonalIcon(
            onPressed: widget.onSecondaryActionTap,
            label: LabelText(secondaryLabel, size: .large),
            icon: Icon(Icons.cancel_outlined),
          ),
        ],
        FilledButton.icon(
          onPressed: widget.onSecondaryActionTap,
          label: LabelText(
            primaryLabel,
            size: .large,
            color: colorTheme.onPrimary,
          ),
          icon: Icon(Icons.location_on_outlined),
        ),
      ],
    );

    final acceptanceIndicators = widget.status == .accepted
        ? StatusIndicator(
            label: "Accepted",
            icon: Icons.done_outline,
            color: colorTheme.primary,
          )
        : Row(
            spacing: DefaultSpacing.medium,
            children: [
              // TODO: provide the actual duration it expires in.
              StatusIndicator(
                label: "Pending",
                icon: Icons.pending_outlined,
                color: colorTheme.primary,
              ),
              if (hoveredOver || expanded) StatusIndicator(
                label: "Expires in 04:32",
                icon: Icons.info_outline,
                color: colorTheme.onSurfaceVariant,
              ),
            ],
          );

    final expandedContent = widget.status == .none
        ? Align(
            alignment: .centerStart,
            child: BodyText(widget.description, size: .large),
          )
        : Column(
            spacing: DefaultSpacing.medium,
            children: [
              Align(
                alignment: .centerStart,
                child: BodyText(widget.description, size: .large),
              ),
              acceptanceIndicators,
            ],
          );

    final nonExpandedcontent = Row(
      mainAxisAlignment: .spaceBetween,
      spacing: 12,
      children: [
        Row(
          spacing: DefaultSpacing.large,
          children: [
            !expanded
                ? BodyText(widget.title, size: .large)
                : TitleText(widget.title, size: .medium),
            if (widget.status != .none && !expanded) acceptanceIndicators,
          ],
        ),
        Row(
          spacing: DefaultSpacing.medium,
          children: [
            if (hoveredOver || expanded) actionButtons,
            SizedBox(
              height: 40,
              child: expanded
                  ? IconWithDefaults(Icons.keyboard_arrow_up)
                  : IconWithDefaults(Icons.keyboard_arrow_down),
            ),
          ],
        ),
      ],
    );

    final content = Column(
      children: [
        nonExpandedcontent,
        if (expanded) ...[expandedContent],
      ],
    );

    return MouseRegion(
      onEnter: (event) => setState(() {
        hoveredOver = true;
      }),
      onExit: (event) => setState(() {
        hoveredOver = false;
      }),
      child: GestureDetector(
        onTap: () => setState(() {
          expanded = !expanded;
        }),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: 60),
          child: Container(
            decoration: BoxDecoration(
              color: hoveredOver
                  ? colorTheme.surfaceContainer
                  : colorTheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: .symmetric(vertical: 10, horizontal: 16),
            child: content,
          ),
        ),
      ),
    );
  }
}
