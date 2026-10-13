import 'package:material_ui/material_ui.dart';

enum TextSize { small, medium, large }

class TitleText extends StatelessWidget {
  const new(this.text, {super.key, required this.size});
  final String text;
  final TextSize size;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final styles = [textTheme.titleSmall, textTheme.titleMedium, textTheme.titleLarge]; 

    return Text(text, style: styles[size.index]);
  }
}

class LabelText extends StatelessWidget {
  const new(this.text, {super.key, required this.size});
  final String text;
  final TextSize size;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final styles = [textTheme.labelSmall, textTheme.labelMedium, textTheme.labelLarge]; 

    return Text(text, style: styles[size.index]);
  }
}

class BodyText extends StatelessWidget {
  const new(this.text, {super.key, required this.size});
  final String text;
  final TextSize size;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final styles = [textTheme.bodySmall, textTheme.bodyMedium, textTheme.bodyLarge]; 

    return Text(text, style: styles[size.index]);
  }
}