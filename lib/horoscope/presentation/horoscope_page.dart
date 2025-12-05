import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../application/horoscope_cubit.dart';
import '../application/horoscope_state.dart';
import '../../core/constants/k_sizes.dart';

class HoroscopePage extends StatelessWidget {
  static const String routeName = '/horoscope';

  const HoroscopePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HoroscopeCubit()..fetchNews(),
      child: const HoroscopeView(),
    );
  }
}

class HoroscopeView extends StatelessWidget {
  const HoroscopeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Horoscope News')),
      body: Padding(
        padding: EdgeInsets.all(KSizes.margin4x),
        child: BlocBuilder<HoroscopeCubit, HoroscopeState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Failed to load news.'),
                    SizedBox(height: KSizes.margin2x),
                    ElevatedButton(
                      onPressed: () {
                        context.read<HoroscopeCubit>().fetchNews();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            if (state.news.isEmpty) {
              return const Center(child: Text('No news available.'));
            }
            return ListView.separated(
              itemCount: state.news.length,
              separatorBuilder: (_, __) => SizedBox(height: KSizes.margin4x),
              itemBuilder: (context, index) {
                final article = state.news[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(KSizes.radiusDefault),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(KSizes.margin4x),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (article.imageUrl.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(
                              KSizes.radiusDefault,
                            ),
                            child: Image.network(
                              article.imageUrl,
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        SizedBox(height: KSizes.margin2x),
                        Text(
                          article.title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        SizedBox(height: KSizes.margin2x),
                        Text(
                          article.summary,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        SizedBox(height: KSizes.margin2x),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(article.source),
                            Text(article.publishedAt),
                          ],
                        ),
                        SizedBox(height: KSizes.margin2x),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              // TODO: Open article.url in browser
                            },
                            child: const Text('Read More'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
