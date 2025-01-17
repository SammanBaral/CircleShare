import 'package:circle_share/features/auth/presentation/view/login_view.dart';
import 'package:circle_share/features/on_board/presentation/view_model/onboard_screen_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OnboardingView extends StatelessWidget {
  final List<Map<String, String>> onboardingData = [
    {
      "title": "CircleShare",
      "subtitle": "Share More, Own Less",
      "imagePath": "./assets/images/image_3.png",
      "description":
          "Connect with Neighbors\nBuild meaningful connections while sharing resources in your community",
    },
    {
      "title": "How It Works",
      "subtitle": "Steps to Share & Borrow",
      "imagePath": "./assets/images/image_3.png",
      "description":
          "1. Find Items\nBrowse or search for nearby items\n\n2. Connect\nReach out to owners and borrow\n\n3. Share & Rate\nShare your experience and rate others",
    },
    {
      "title": "Community Impact",
      "subtitle": "Join and Contribute",
      "imagePath": "./assets/images/image_3.png",
      "description":
          "✔ 2.5K Items Shared\n✔ 150 Communities Connected\n✔ 50K Saved Together",
    },
    {
      "title": "Safe Transactions",
      "subtitle": "Trust & Security",
      "imagePath": "./assets/images/image_3.png",
      "description":
          "Secure in-app messaging and verified profiles ensure trust within the community.",
    },
    {
      "title": "Start Sharing",
      "subtitle": "Join Now",
      "imagePath": "./assets/images/image_3.png",
      "description":
          "Join a community that shares. Reduce waste, save money, and build connections.",
    },
  ];

  OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OnboardingCubit(onboardingData.length),
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: BlocBuilder<OnboardingCubit, OnboardingState>(
                builder: (context, state) {
                  final cubit = context.read<OnboardingCubit>();
                  return PageView.builder(
                    controller: cubit.pageController,
                    itemCount: onboardingData.length,
                    onPageChanged: cubit.onPageChanged,
                    itemBuilder: (context, index) {
                      final page = onboardingData[index];
                      return _buildPage(
                        context,
                        title: page["title"]!,
                        subtitle: page["subtitle"]!,
                        imagePath: page["imagePath"]!,
                        description: page["description"]!,
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: BlocBuilder<OnboardingCubit, OnboardingState>(
                builder: (context, state) {
                  final cubit = context.read<OnboardingCubit>();
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          cubit.skipOnboarding();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginView()),
                          );
                        },
                        child: Text("Skip",
                            style: TextStyle(color: Colors.grey[700])),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          if (state.isLastPage) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginView()),
                            );
                          } else {
                            cubit.goToNextPage();
                          }
                        },
                        child: Text(state.isLastPage ? "Finish" : "Next"),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String imagePath,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Text(
            title,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              imagePath,
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[800]),
          ),
        ],
      ),
    );
  }
}
