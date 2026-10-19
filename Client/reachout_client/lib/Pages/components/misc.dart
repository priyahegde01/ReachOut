import 'dart:async';

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
  const IconWithDefaults(
    this.icon, {
    super.key,
    this.filled = false,
    this.color,
  });
  final IconData? icon;
  final bool filled;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      weight: 400,
      opticalSize: 24,
      fill: filled ? 1.0 : 0.0,
      color: color ?? Theme.of(context).colorScheme.onSurface,
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
        BodyText(label, size: .medium, color: color),
      ],
    );
  }
}

class ExpireIndicator extends StatefulWidget {
  const new({super.key, required this.startTime, required this.stopTime});
  final DateTime startTime;
  final DateTime stopTime;

  @override
  State<ExpireIndicator> createState() => _ExpireIndicatorState();
}

class _ExpireIndicatorState extends State<ExpireIndicator> {
  Duration _timeLeft = Duration();
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timeLeft = widget.stopTime.isBefore(DateTime.now())
        ? Duration.zero
        : widget.stopTime.difference(DateTime.now());

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timeLeft.inSeconds > 1) {
        setState(() {
          _timeLeft -= const Duration(seconds: 1);
        });
      } else {
        _timer.cancel();
        setState(() {
          _timeLeft = Duration.zero;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme; 
    final time = formatTimestamp(_timeLeft);
    final label = "Expires in $time";
    final color = colorScheme.onSurfaceVariant;

    return _timeLeft == Duration.zero
        ? LabelText("Expired", size: .large, color: colorScheme.error)
        : LabelText(label, size: .large, color: color);
  }

  String formatTimestamp(Duration time) {
    final hours = time.inHours;
    final minutes = time.inMinutes % 60;
    final seconds = time.inSeconds % 60;

    final hoursText = getTimeStampPart(hours);
    final minutesText = getTimeStampPart(minutes);
    final secondsText = getTimeStampPart(seconds);

    if (hours > 0) {
      return "$hoursText:$minutesText:$secondsText";
    }
    return "$minutesText:$secondsText";
  }

  String getTimeStampPart(int value) {
    return value < 10 ? "0$value" : "$value";
  }
}
