import 'package:material_ui/material_ui.dart';
import 'package:reachout_client/Pages/components/text.dart';


class DefaultSpacing {
  DefaultSpacing._(); // Prevents instantiation

  static const double none = 0.0;
  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double small = 8.0;
  static const double medium = 16.0;
  static const double large = 24.0;
  static const double extraLarge = 32.0;
  static const double xxl = 48.0;
}

/// An Icon widget with default weight and optical size.
class IconWithDefaults extends StatelessWidget {
  const IconWithDefaults(this.icon, {super.key, this.filled = false, this.color});
  final IconData? icon;
  final bool filled;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Icon(icon, weight: 400, opticalSize: 24, fill: filled ? 1.0 : 0.0, color: color ?? Theme.of(context).colorScheme.onSurface);
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