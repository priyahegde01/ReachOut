import 'package:material_ui/material_ui.dart';

class LoginPage extends StatefulWidget {
  const new({super.key, required this.onRegister, required this.onLogin});

  final VoidCallback onRegister;
  final ValueChanged<String> onLogin;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _userIdController = TextEditingController();

  @override
  void dispose() {
    _userIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 16,
              children: [
                Text(
                  "Welcome to ReachOut",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                TextField(
                  controller: _userIdController,
                  decoration: const InputDecoration(
                    labelText: "User ID",
                    border: OutlineInputBorder(),
                  ),
                ),
                FilledButton(
                  onPressed: widget.onRegister,
                  child: const Text("Create a new account"),
                ),
                OutlinedButton(
                  onPressed: () {
                    final userId = _userIdController.text.trim();
                    if (userId.isNotEmpty) {
                      widget.onLogin(userId);
                    }
                  },
                  child: const Text("Log in with user ID"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
