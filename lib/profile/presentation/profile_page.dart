import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../application/profile_cubit.dart';
import '../application/profile_state.dart';
import '../../core/constants/k_sizes.dart';

class ProfilePage extends StatelessWidget {
  static const String routeName = '/profile';

  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileCubit(),
      child: const ProfileView(),
    );
  }
}

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: EdgeInsets.all(KSizes.margin4x),
        child: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Failed to load profile.'),
                    SizedBox(height: KSizes.margin2x),
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Retry logic
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            final profile = state.profile;
            if (profile == null) {
              return const Center(child: Text('No profile data.'));
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: KSizes.iconM,
                  backgroundImage: profile.photoUrl.isNotEmpty
                      ? NetworkImage(profile.photoUrl)
                      : const AssetImage('assets/images/users/default_user.png')
                            as ImageProvider,
                ),
                SizedBox(height: KSizes.margin4x),
                Text(
                  profile.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(height: KSizes.margin2x),
                Text(profile.email),
                SizedBox(height: KSizes.margin2x),
                Text('Sun Sign: ${profile.sunSign}'),
                SizedBox(height: KSizes.margin2x),
                Text('Date of Birth: ${profile.dob}'),
                SizedBox(height: KSizes.margin4x),
                Text(profile.bio),
                SizedBox(height: KSizes.margin4x),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Edit profile
                  },
                  child: const Text('Edit Profile'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
