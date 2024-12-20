import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class DashboardView extends StatelessWidget {
  final List<String> bannerImages = [
    './assets/images/camera.jpg',
    './assets/images/drill.jpg',
    './assets/images/image_2.jpg',
  ];

  DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Removes the back arrow
        // backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            // Left Image (Logo) aligned to the center
            Align(
              alignment: Alignment.center,
              child: Image.asset(
                'assets/images/circle_logo.png',
                height: 100,
                width: 100,
              ),
            ),

            Spacer(),

            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: Icon(Icons.notifications, color: Colors.black),
                onPressed: () {
                },
              ),
            ),

            Align(
              alignment: Alignment.topRight,
              child: CircleAvatar(
                backgroundImage: AssetImage(
                    './assets/images/image_1.png'), // Replace with your image path
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search items to borrow...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
            ),
            CarouselSlider(
              options: CarouselOptions(
                height: 180,
                autoPlay: true,
                enlargeCenterPage: true,
                aspectRatio: 16 / 9,
                viewportFraction: 0.9,
              ),
              items: bannerImages.map((imagePath) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: AssetImage(imagePath),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Container(
                        alignment: Alignment.bottomLeft,
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Professional tools\nAvailable nearby',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Categories',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCategoryIcon(Icons.build, 'Tools'),
                  _buildCategoryIcon(Icons.sports_soccer, 'Sports'),
                  _buildCategoryIcon(Icons.book, 'Books'),
                  _buildCategoryIcon(Icons.laptop, 'Electronics'),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Available Nearby',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _buildItemCard(
              'Canon EOS 5D Mark IV',
              'Professional camera with 24-70mm lens',
              './assets/images/camera.jpg', // Replace with your image path
              'Richard Thompson',
              4.9,
              0.3,
            ),
            _buildItemCard(
              'DeWalt Power Drill Set',
              'Complete set with various bits',
              './assets/images/drill.jpg', // Replace with your image path
              'Sarah Chen',
              4.8,
              0.5,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(icon: Icon(Icons.home), onPressed: () {}),
            IconButton(icon: Icon(Icons.explore), onPressed: () {}),
            SizedBox(width: 40), // Space for the FAB
            IconButton(icon: Icon(Icons.chat), onPressed: () {}),
            IconButton(icon: Icon(Icons.person), onPressed: () {}),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildCategoryIcon(IconData icon, String label) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.grey[200],
          child: Icon(
            icon,
            size: 30,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8),
        Text(label),
      ],
    );
  }

  Widget _buildItemCard(String title, String subtitle, String imagePath,
      String owner, double rating, double distance) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Image.asset(
          imagePath,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
        ),
        title: Text(title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subtitle),
            SizedBox(height: 4),
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundImage: AssetImage(
                      './assets/images/image_2.jpg'), // Replace with your image path
                ),
                SizedBox(width: 8),
                Text(owner),
                Spacer(),
                Icon(Icons.star, color: Colors.amber, size: 16),
                SizedBox(width: 4),
                Text(rating.toString()),
              ],
            ),
          ],
        ),
        trailing: Text('$distance mi'),
      ),
    );
  }
}
