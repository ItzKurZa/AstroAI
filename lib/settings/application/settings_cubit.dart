import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/settings_option_model.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(SettingsState.initial());

  void loadOptions() {
    emit(
      state.copyWith(
        options: [
          SettingsOptionModel(
            id: 'support',
            title: 'Support',
            subtitle: 'Contact support',
            iconPath: 'assets/images/app/icons/support.png',
          ),
          SettingsOptionModel(
            id: 'change_email',
            title: 'Change Email',
            subtitle: 'Update your email address',
            iconPath: 'assets/images/app/icons/email.png',
          ),
          SettingsOptionModel(
            id: 'change_password',
            title: 'Change Password',
            subtitle: 'Update your password',
            iconPath: 'assets/images/app/icons/password.png',
          ),
          SettingsOptionModel(
            id: 'restore_purchase',
            title: 'Restore Purchase',
            subtitle: 'Restore your purchases',
            iconPath: 'assets/images/app/icons/restore.png',
          ),
          SettingsOptionModel(
            id: 'wipe_account',
            title: 'Wipe Account',
            subtitle: 'Delete all your data',
            iconPath: 'assets/images/app/icons/delete.png',
            isDestructive: true,
          ),
          SettingsOptionModel(
            id: 'logout',
            title: 'Log Out',
            subtitle: 'Sign out of your account',
            iconPath: 'assets/images/app/icons/logout.png',
            isDestructive: true,
          ),
        ],
      ),
    );
  }
}
