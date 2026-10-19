import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reachout_client/Pages/components/misc.dart';
import 'package:reachout_client/Pages/components/text.dart';
import 'package:reachout_client/state/models/preferences.dart';
import 'package:reachout_client/state/models/request_board.dart';
import 'package:reachout_client/state/preferences_state.dart';
import 'package:reachout_client/state/request_board_state.dart';

class MainPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: MainPageStructure());
  }
}

/// The overall structure of the main page.
class MainPageStructure extends StatefulWidget {
  const new({super.key});

  @override
  State<MainPageStructure> createState() => _MainPageStructureState();
}

class _MainPageStructureState extends State<MainPageStructure> {
  bool _showRequestCreationDialog = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IgnorePointer(
          ignoring: _showRequestCreationDialog,
          child: Padding(
            padding: .directional(top: DefaultSpacing.large),
            child: Column(
              spacing: DefaultSpacing.small,
              children: [
                Expanded(child: RequestBoard()),
                Align(alignment: .bottomCenter, child: MainPageStatusBar()),
              ],
            ),
          ),
        ),
        Positioned(
          // These are arbitrarily chosen coordinates.
          right: 32,
          bottom: 96,
          child: IgnorePointer(
            ignoring: _showRequestCreationDialog,
            child: FloatingActionButton.extended(
              onPressed: () {
                setState(() {
                  _showRequestCreationDialog = true;
                });
              },
              label: TitleText("Request Help", size: .medium),
              icon: Icon(Icons.add),
            ),
          ),
        ),
        if (_showRequestCreationDialog)
          Positioned.fill(
            child: BackdropFilter(
              filter: .blur(sigmaX: 8, sigmaY: 8),
              child: Center(
                child: NewRequestDialog(
                  onClose: () => setState(() {
                    _showRequestCreationDialog = false;
                  }),
                  // TODO: implement / implement in widget instead.
                  onSubmit: () {},
                ),
              ),
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

    final content = BlocBuilder<PreferencesCubit, PreferencesState>(
      builder: (context, state) {
        return switch (state) {
          PreferencesLoadSuccess() => Row(
            spacing: DefaultSpacing.large,
            children: [
              TextButton(
                onPressed: () {
                  context.read<PreferencesCubit>().switchThemeMode();
                },
                child: StatusIndicator(
                  label: [
                    "System default",
                    "Light",
                    "Dark",
                  ][state.themeMode.index],
                  icon: [
                    Icons.brightness_auto,
                    Icons.light_mode,
                    Icons.dark_mode,
                  ][state.themeMode.index],
                ),
              ),
              StatusIndicator(label: "connected", icon: Icons.wifi),
              LabelText("64 points earned", size: .large),
            ],
          ),
          PreferencesLoadingInProgress() => Row(
            spacing: DefaultSpacing.large,
            children: [
              CircularProgressIndicator(),
              LabelText("Loading preferences", size: .large),
            ],
          ),
          PreferencesLoadFailure() => Row(
            spacing: DefaultSpacing.large,
            children: [
              Icon(Icons.error_outline, color: colorTheme.error),
              LabelText("Failed to load preferences", size: .large),
            ],
          ),
          PreferencesInitial() => SizedBox.shrink(),
        };
      },
    );

    return Container(
      height: 48,
      color: colorTheme.surfaceContainer,
      padding: .symmetric(horizontal: DefaultSpacing.medium),
      child: content,
    );
  }
}

/// Contains the accepted, requested, and requested by others lists.
class RequestBoard extends StatelessWidget {
  const new({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RequestBoardCubit, RequestBoardState>(
      builder: (context, state) {
        return switch (state) {
          RequestBoardLoadSuccess() => FractionallySizedBox(
            widthFactor: 0.7,
            child: CustomScrollView(
              //spacing: DefaultSpacing.extraLarge,
              slivers: [
                RequestBoardSection(
                  title: "Accepted by me",
                  requests: state.accepted,
                ),
                RequestBoardSection(
                  title: "Requested by me",
                  requests: state.requestedByMe,
                ),
                RequestBoardSection(
                  title: "Others' requests",
                  requests: state.requestedByOthers
                      .where((request) => request.type == .requestedByOther)
                      .toList(),
                ),
              ],
            ),
          ),
          RequestBoardEmpty() => Center(
            child: DisplayText("The request board is empty.", size: .large),
          ),
          RequestBoardLoading() => Center(
            child: Row(
              mainAxisAlignment: .center,
              spacing: DefaultSpacing.extraLarge,
              children: [
                CircularProgressIndicator(),
                DisplayText("Loading Requests", size: .large),
              ],
            ),
          ),
          RequestBoardLoadFailure() => Center(
            child: DisplayText("Failed to load Requests.", size: .large),
          ),
        };
      },
    );
  }
}

/// A section of the request board that contains a title and a list of requests.
class RequestBoardSection extends StatelessWidget {
  const new({super.key, required this.title, required this.requests});
  final String title;
  final List<Request> requests;

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
            request: request,
            onExpiry: () {},
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

/// A list tile that represents a request.
///
/// The list tile can be expanded to show more information about the request, such as its description and status.
/// It can also be hovered over to show action buttons, such as "Show location" or "Cancel" (this is also shown in the expanded view).
class RequestListTile extends StatefulWidget {
  const new({
    super.key,
    required this.request,
    required this.onExpiry,
    required this.onPrimaryActionTap,
    this.onSecondaryActionTap,
  });
  final Request request;
  final VoidCallback onExpiry;
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
    final request = widget.request;

    final primaryLabel = [
      "Cancel",
      request.status == .accepted ? "Mark complete" : "Cancel",
      "Take request",
    ][request.type.index];

    final secondaryLabel = [
      null,
      request.status == .accepted ? "Cancel" : null,
      null,
    ][request.type.index];

    final actionButtons = Row(
      spacing: DefaultSpacing.small,
      children: [
        if (secondaryLabel != null) ...[
          FilledButton.tonalIcon(
            onPressed: widget.onSecondaryActionTap,
            label: LabelText(secondaryLabel, size: .large),
          ),
        ],
        FilledButton.icon(
          onPressed: widget.onSecondaryActionTap,
          label: LabelText(
            primaryLabel,
            size: .large,
            color: colorTheme.onPrimary,
          ),
        ),
      ],
    );

    final acceptanceIndicators = request.status == .accepted
        ? StatusIndicator(
            label: "Accepted",
            icon: Icons.done_outline,
            color: colorTheme.primary,
          )
        : Row(
            spacing: DefaultSpacing.medium,
            children: [
              StatusIndicator(
                label: "Pending",
                icon: Icons.pending_outlined,
                color: colorTheme.primary,
              ),
              if (hoveredOver || expanded)
                ExpireIndicator(
                  startTime: request.created,
                  stopTime: request.expires,
                ),
            ],
          );

    final expandedContent = request.status == .none
        ? Align(
            alignment: .centerStart,
            child: BodyText(request.description, size: .large),
          )
        : Column(
            spacing: DefaultSpacing.medium,
            children: [
              Align(
                alignment: .centerStart,
                child: BodyText(request.description, size: .large),
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
                ? BodyText(request.title, size: .large)
                : TitleText(request.title, size: .medium),
            if (request.status != .none && !expanded) acceptanceIndicators,
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

class NewRequestDialog extends StatefulWidget {
  const new({super.key, required this.onClose, required this.onSubmit});
  final VoidCallback onClose;
  final VoidCallback onSubmit;

  @override
  State<NewRequestDialog> createState() => _NewRequestDialogState();
}

class _NewRequestDialogState extends State<NewRequestDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<RequestBoardCubit>().sendRequest(
        _titleController.text,
        _locationController.text,
        _descriptionController.text,
      );
      widget.onClose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final header = Row(
      mainAxisAlignment: .spaceBetween,
      children: [
        HeadlineText("New Request", size: .small),
        IconButton(
          onPressed: widget.onClose,
          icon: IconWithDefaults(Icons.close),
        ),
      ],
    );

    final body = Form(
      key: _formKey,
      child: Column(
        spacing: 8,
        children: [
          RequestTextField(hintText: "Title", controller: _titleController),
          RequestTextField(
            maxInputLength: 100,
            hintText: "Location",
            controller: _locationController,
          ),
          Expanded(
            child: RequestTextField(
              maxInputLength: 1000,
              hintText: "Description",
              controller: _descriptionController,
              showUnderLine: false,
              onlyOneLine: false,
            ),
          ),
        ],
      ),
    );

    final actionButtons = Row(
      spacing: DefaultSpacing.small,
      children: [
        SizedBox(
          height: 40,
          child: OutlinedButton(
            onPressed: widget.onClose,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: colorScheme.outlineVariant, width: 1.5),
            ),
            child: LabelText(
              "Cancel",
              size: .large,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        SizedBox(
          height: 40,
          child: FilledButton(
            onPressed: _submit,
            child: LabelText(
              "Send Request",
              size: .large,
              color: colorScheme.onPrimary,
            ),
          ),
        ),
      ],
    );

    final footer = Row(
      mainAxisAlignment: .spaceBetween,
      children: [
        StatusIndicator(
          label: "Expires five minutes after sending.",
          icon: Icons.info_outline,
          color: colorScheme.outline,
        ),
        actionButtons,
      ],
    );

    final container = FractionallySizedBox(
      widthFactor: 0.7,
      child: Padding(
        padding: const .symmetric(vertical: DefaultSpacing.extraLarge),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          elevation: 2.0,
          color: colorScheme.surfaceContainerLowest,
          child: Padding(
            padding: const .symmetric(
              vertical: DefaultSpacing.medium,
              horizontal: DefaultSpacing.large,
            ),
            child: Column(
              spacing: DefaultSpacing.medium,
              children: [
                header,
                Expanded(child: body),
                footer,
              ],
            ),
          ),
        ),
      ),
    );

    return container;
  }
}

class RequestTextField extends StatelessWidget {
  const new({
    super.key,
    required this.hintText,
    required this.controller,
    this.showUnderLine = true,
    this.onlyOneLine = true,
    this.maxInputLength = 50,
  });
  final String hintText;
  final TextEditingController controller;
  final bool showUnderLine;
  final bool onlyOneLine;
  final int maxInputLength;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final border = showUnderLine
        ? UnderlineInputBorder(
            borderSide: BorderSide(
              color: colorScheme.outlineVariant,
              width: 1.0,
            ),
          )
        : InputBorder.none;

    return TextFormField(
      validator: (value) {
        final emptyValueError = "This field cannot be empty.";

        return value == null || value.trim().isEmpty ? emptyValueError : null;
      },
      decoration: InputDecoration(
        hint: BodyText(hintText, size: .large, color: colorScheme.outline),
        enabledBorder: border,
        focusedBorder: border,
        contentPadding: const .symmetric(vertical: 8),
      ),
      maxLines: onlyOneLine ? 1 : null,
      maxLength: maxInputLength,
      maxLengthEnforcement: .enforced,
      controller: controller,
    );
  }
}
