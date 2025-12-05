import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../application/home_cubit.dart';
import '../application/home_state.dart';
import '../../core/constants/k_sizes.dart';
import '../../core/theme/app_theme.dart';

class HomePage extends StatelessWidget {
  static const String routeName = '/home';

  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit()..initialize(),
      child: const HomeView(),
    );
  }
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  String _getPlanetImage(String planet) {
    final planetMap = {
      'sun': 'assets/images/app/planets/sun.png',
      'moon': 'assets/images/app/planets/moon.png',
      'mars': 'assets/images/app/planets/mars.png',
      'mercury': 'assets/images/app/planets/mercury.png',
      'jupiter': 'assets/images/app/planets/jupiter.png',
      'venus': 'assets/images/app/planets/venus.png',
      'saturn': 'assets/images/app/planets/saturn.png',
    };
    return planetMap[planet.toLowerCase()] ??
        'assets/images/app/planets/venus.png';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.light.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(KSizes.margin4x),
            child: BlocBuilder<HomeCubit, HomeState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height * 0.8,
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }
                // if (state.hasError) {
                //   return SizedBox(
                //     height: MediaQuery.of(context).size.height * 0.8,
                //     child: Center(
                //       child: Column(
                //         mainAxisAlignment: MainAxisAlignment.center,
                //         children: [
                //           const Text('Failed to load prediction.'),
                //           SizedBox(height: KSizes.margin2x),
                //           ElevatedButton(
                //             onPressed: () {
                //               context.read<HomeCubit>().initialize();
                //             },
                //             child: const Text('Retry'),
                //           ),
                //         ],
                //       ),
                //     ),
                //   );
                // }

                final prediction = state.prediction;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // User info (name + zodiac signs)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          'Martin Lee',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          '♌ Leo',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          '☽ Virgo',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          '♎ Libra',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    SizedBox(height: KSizes.margin8x),
                    // Calendar
                    Container(
                      padding: EdgeInsets.all(KSizes.margin4x),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A1F4D),
                        borderRadius: BorderRadius.circular(
                          KSizes.radiusDefault,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Mo Tu We Th Fr Sa Su',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: Colors.white70),
                          ),
                          SizedBox(height: KSizes.margin2x),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(7, (index) {
                              final day = 18 + index;
                              final isToday = day == 22;
                              return Container(
                                alignment: Alignment.center,
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: isToday
                                      ? const Color(0xFFB9A4F4)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '$day',
                                  style: TextStyle(
                                    color: isToday
                                        ? Colors.black
                                        : Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: KSizes.margin8x),
                    // Planets Today
                    Text(
                      'Planets Today',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: KSizes.margin8x),
                    // Planet Card
                    Container(
                      padding: EdgeInsets.all(KSizes.margin4x),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B2B6B),
                        borderRadius: BorderRadius.circular(
                          KSizes.radiusDefault,
                        ),
                        border: Border.all(
                          color: const Color(0xFFB9A4F4),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Image.asset(
                            _getPlanetImage(prediction?.sunSign ?? 'venus'),
                            width: 120,
                            height: 120,
                          ),
                          SizedBox(height: KSizes.margin4x),
                          Text(
                            (prediction?.sunSign ?? 'VENUS').toUpperCase(),
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: const Color(0xFFB9A4F4),
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          SizedBox(height: KSizes.margin2x),
                          Text(
                            'In the Sign: ♈, 18°38"',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(color: Colors.white70),
                          ),
                          SizedBox(height: KSizes.margin4x),
                          Text(
                            prediction?.prediction ?? 'Loading prediction...',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.white70),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: KSizes.margin8x),
                    // Try Premium Banner
                    Container(
                      padding: EdgeInsets.all(KSizes.margin4x),
                      decoration: BoxDecoration(
                        color: const Color(0xFFB9A4F4).withOpacity(0.3),
                        borderRadius: BorderRadius.circular(
                          KSizes.radiusDefault,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'ADVISOR',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: const Color(0xFFB9A4F4)),
                          ),
                          SizedBox(height: KSizes.margin2x),
                          Text(
                            'Try Premium',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: KSizes.margin2x),
                          Text(
                            '-30% DISCOUNT',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: KSizes.margin8x),
                    // You Today
                    Text(
                      'You Today',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: KSizes.margin4x),
                    // Health Card
                    _buildAspectCard(
                      context,
                      'HEALTH',
                      'Influential planets:\n○ → ♀, 30° 14"\n☿ → ♂, 20°, 24° 04"\n♀ → ☋, 21°, 16° 38"',
                      'General Characteristics\nThis day would be best to devote yourself to yoga and meditation. Even if this happens at home, create a unique atmosphere of harmony for yourself and choose the right...',
                    ),
                    SizedBox(height: KSizes.margin4x),
                    // Finance Card
                    _buildAspectCard(
                      context,
                      'FINANCE',
                      'Influential planets:\n♀ → ♀, 00°, 51° 37"\n☿ → ♂, 20°, 24° 04"\n♎ → ☊, 05°, 42° 19"',
                      'General Characteristics\nFirst of all, this applies to executives, managers and civil servants. Your organizational skill will increase significantly. If you are expecting a prom...',
                    ),
                    SizedBox(height: KSizes.margin4x),
                    // Relationship Card
                    _buildAspectCard(
                      context,
                      'RELATIONSHIP',
                      'Influential planets:\n♎ → ♀, 00°, 00° 00"\n♂ → ♀, 00°, 00° 00"\n♀ → ♀, 00°, 00° 00"',
                      'General Characteristics\nToday your significant other will want something from you that is incomprehensible even to her. Like in the good old fairy tales: go, I don\'t know...',
                    ),
                    SizedBox(height: KSizes.margin8x),
                    // Tip for the day
                    Container(
                      padding: EdgeInsets.all(KSizes.margin4x),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B2B6B),
                        borderRadius: BorderRadius.circular(
                          KSizes.radiusDefault,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Tip for the day',
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(color: const Color(0xFFB9A4F4)),
                          ),
                          SizedBox(height: KSizes.margin4x),
                          Text(
                            '"Brave against sheep, but himself a sheep against the brave"',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAspectCard(
    BuildContext context,
    String title,
    String planets,
    String characteristics,
  ) {
    return Container(
      padding: EdgeInsets.all(KSizes.margin4x),
      decoration: BoxDecoration(
        color: const Color(0xFF3B2B6B),
        borderRadius: BorderRadius.circular(KSizes.radiusDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: KSizes.margin2x),
          Text(
            planets,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: Colors.white70),
          ),
          SizedBox(height: KSizes.margin4x),
          Text(
            characteristics,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: Colors.white70),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
