import 'package:flutter/material.dart';
import '../main.dart';
import '../utils/app_colors.dart';

class ThemeSettingsPage extends StatefulWidget {
  const ThemeSettingsPage({super.key});

  @override
  State<ThemeSettingsPage> createState() => _ThemeSettingsPageState();
}

class _ThemeSettingsPageState extends State<ThemeSettingsPage> {
  ThemeMode _mode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _mode = appKey.currentState?.themeMode ?? ThemeMode.system;
  }

  void _apply(ThemeMode mode) {
    appKey.currentState?.setThemeMode(mode);
    setState(() {
      _mode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Theme',
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: AppColors.themedPrimaryGradient(context),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _ThemeOption(
              title: 'System default',
              value: ThemeMode.system,
              groupValue: _mode,
              onChanged: _apply,
              icon: Icons.settings_suggest,
            ),
            const SizedBox(height: 8),
            _ThemeOption(
              title: 'Light',
              value: ThemeMode.light,
              groupValue: _mode,
              onChanged: _apply,
              icon: Icons.light_mode,
            ),
            const SizedBox(height: 8),
            _ThemeOption(
              title: 'Dark',
              value: ThemeMode.dark,
              groupValue: _mode,
              onChanged: _apply,
              icon: Icons.dark_mode,
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.icon,
  });

  final String title;
  final ThemeMode value;
  final ThemeMode groupValue;
  final void Function(ThemeMode) onChanged;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selected = value == groupValue;
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? theme.colorScheme.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            Radio<ThemeMode>(
              value: value,
              groupValue: groupValue,
              onChanged: (_) => onChanged(value),
            ),
          ],
        ),
      ),
    );
  }
}
