import 'package:flutter/material.dart';

class SettingsDialog extends StatelessWidget {
  final bool isDarkMode;
  final double fontSize;
  final VoidCallback onToggleTheme;
  final VoidCallback onIncreaseFontSize;
  final VoidCallback onDecreaseFontSize;

  const SettingsDialog({
    Key? key,
    required this.isDarkMode,
    required this.fontSize,
    required this.onToggleTheme,
    required this.onIncreaseFontSize,
    required this.onDecreaseFontSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Settings'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ThemeToggle(
              isDarkMode: isDarkMode,
              onToggleTheme: () {
                onToggleTheme();
                Navigator.pop(context);
              }),
          const SizedBox(height: 16),
          _FontSizeControls(
            fontSize: fontSize,
            onIncrease: onIncreaseFontSize,
            onDecrease: onDecreaseFontSize,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _ThemeToggle extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  const _ThemeToggle({
    Key? key,
    required this.isDarkMode,
    required this.onToggleTheme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
      title: const Text('Theme'),
      trailing: Switch(
        value: isDarkMode,
        onChanged: (_) => onToggleTheme(),
      ),
    );
  }
}

class _FontSizeControls extends StatelessWidget {
  final double fontSize;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  const _FontSizeControls({
    Key? key,
    required this.fontSize,
    required this.onIncrease,
    required this.onDecrease,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Font Size',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: onDecrease,
            ),
            Text(
              '${fontSize.toInt()}',
              style: const TextStyle(fontSize: 18),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: onIncrease,
            ),
          ],
        ),
      ],
    );
  }
}
