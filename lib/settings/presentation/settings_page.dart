import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../application/settings_cubit.dart';
import '../application/settings_state.dart';
import '../../core/constants/k_sizes.dart';

class SettingsPage extends StatelessWidget {
  static const String routeName = '/settings';

  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SettingsCubit()..loadOptions(),
      child: const SettingsView(),
    );
  }
}

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: EdgeInsets.all(KSizes.margin4x),
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, state) {
            if (state.options.isEmpty) {
              return const Center(child: Text('No settings available.'));
            }
            return ListView.separated(
              itemCount: state.options.length,
              separatorBuilder: (_, __) => SizedBox(height: KSizes.margin2x),
              itemBuilder: (context, index) {
                final option = state.options[index];
                return ListTile(
                  leading: option.iconPath.isNotEmpty
                      ? Image.asset(
                          option.iconPath,
                          width: KSizes.iconM,
                          height: KSizes.iconM,
                        )
                      : null,
                  title: Text(option.title),
                  subtitle: option.subtitle.isNotEmpty
                      ? Text(option.subtitle)
                      : null,
                  trailing: option.isDestructive
                      ? const Icon(Icons.warning, color: Colors.red)
                      : null,
                  onTap: () {
                    // TODO: Implement action for each setting
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
