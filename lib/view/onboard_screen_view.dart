import 'package:flutter/material.dart';

class OnboardingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView(
              children: [
                _buildPage(
                  context,
                  title: "CircleShare",
                  subtitle: "Share More, Own Less",
                  imagePath: "assets/images/image_3.png",
                  description:
                      "Connect with Neighbors\nBuild meaningful connections while sharing resources in your community",
                ),
                _buildPage(
                  context,
                  title: "How It Works",
                  subtitle: "Steps to Share & Borrow",
                  imagePath: "assets/images/onboarding2.jpg",
                  description:
                      "1. Find Items\nBrowse or search for nearby items\n\n2. Connect\nReach out to owners and borrow\n\n3. Share & Rate\nShare your experience and rate others",
                ),
                _buildPage(
                  context,
                  title: "Community Impact",
                  subtitle: "Join and Contribute",
                  imagePath: "assets/images/onboarding3.jpg",
                  description:
                      "✔ 2.5K Items Shared\n✔ 150 Communities Connected\n 50K Saved Together",
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/'); // Navigate to main screen
                  },
                  child: Text("Skip", style: TextStyle(color: Colors.grey[700])),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/'); // Navigate to next screen
                  },
                  child: Text("Next"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(BuildContext context, {
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
          SizedBox(height: 40),
          Text(
            title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (subtitle.isNotEmpty) ...[
            SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
          SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              imagePath,
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 20),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}
