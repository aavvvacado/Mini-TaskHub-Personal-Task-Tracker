import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_trecker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:task_trecker/features/auth/presentation/bloc/auth_event.dart';

import '../../../core/theme/theme_cubit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _SectionHeader(title: 'Appearance'),
          Card(
            child: Column(
              children: [
                _ThemeRadioListTile(
                  title: 'System Default',
                  value: ThemeMode.system,
                ),
                _ThemeRadioListTile(
                  title: 'Light Mode',
                  value: ThemeMode.light,
                ),
                _ThemeRadioListTile(title: 'Dark Mode', value: ThemeMode.dark),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const _SectionHeader(title: 'Account'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
                onTap: () async {
                  // Trigger logout. The Dashboard (parent) listener will handle navigation to login.
                  // We pop settings first to ensure context is clean or let the listener handle it?
                  // Better: Just add event. The listener in Dashboard handles pushNamedAndRemoveUntil.
                  // But if we are in Settings, we might need to pop settings or just let the route replace happen.
                  // Navigator.pushNamedAndRemoveUntil will remove ALL routes, including Settings.
                  context.read<AuthBloc>().add(AuthLogoutRequested());
                },
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _ThemeRadioListTile extends StatelessWidget {
  final String title;
  final ThemeMode value;

  const _ThemeRadioListTile({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    // Access usage of ThemeCubit. Since we didn't wrap MaterialApp yet,
    // we need to make sure this widget can find it if we provide it above.
    // For now assuming we will wrap MaterialApp.
    final themeCubit = context.watch<ThemeCubit>();

    return RadioListTile<ThemeMode>(
      title: Text(title),
      value: value,
      groupValue: themeCubit.state,
      onChanged: (mode) {
        if (mode != null) {
          context.read<ThemeCubit>().updateTheme(mode);
        }
      },
    );
  }
}
