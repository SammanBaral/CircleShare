import 'package:circle_share/view/login_view.dart';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
    int _currentPage = 0;
  final PageController _pageController = PageController(); // Add this

  final List<Map<String, String>> _onboardingData = [
    {
      "title": "CircleShare",
      "subtitle": "Share More, Own Less",
      "imagePath": "./assets/images/image_3.png",
      "description": "Connect with Neighbors\nBuild meaningful connections while sharing resources in your community",
    },
    {
      "title": "How It Works",
      "subtitle": "Steps to Share & Borrow",
      "imagePath": "./assets/images/image_3.png",
      "description": "1. Find Items\nBrowse or search for nearby items\n\n2. Connect\nReach out to owners and borrow\n\n3. Share & Rate\nShare your experience and rate others",
    },
    {
      "title": "Community Impact",
      "subtitle": "Join and Contribute",
      "imagePath": "./assets/images/image_3.png",
      "description": "✔ 2.5K Items Shared\n✔ 150 Communities Connected\n✔ 50K Saved Together",
    },
    {
      "title": "Safe Transactions",
      "subtitle": "Trust & Security",
      "imagePath": "./assets/images/image_3.png",
      "description": "Secure in-app messaging and verified profiles ensure trust within the community.",
    },
    {
      "title": "Start Sharing",
      "subtitle": "Join Now",
      "imagePath": "./assets/images/image_3.png",
      "description": "Join a community that shares. Reduce waste, save money, and build connections.",
    },
  ];

  @override
  void dispose() {
    _pageController.dispose(); // Dispose of the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController, // Use the controller here
              itemCount: _onboardingData.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                final page = _onboardingData[index];
                return _buildPage(
                  context,
                  title: page["title"]!,
                  subtitle: page["subtitle"]!,
                  imagePath: page["imagePath"]!,
                  description: page["description"]!,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginView()),
                    ); 
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
                    if (_currentPage == _onboardingData.length - 1) {
                     Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginView()),
                    ); 
                    } else {
                      _pageController.nextPage( 
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: Text(_currentPage == _onboardingData.length - 1 ? "Finish" : "Next"),
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