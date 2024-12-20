import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  _DashboardViewState createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  bool _isCommunityUpdateVisible = true;
  int _selectedIndex =
      0; // Track the selected index for the bottom navigation bar

  final List<Map<String, String>> bannerData = [
    {'image': 'assets/images/camera.jpg', 'caption': 'Professional Tools'},
    {'image': 'assets/images/drill.jpg', 'caption': 'Available Nearby'},
    {'image': 'assets/images/tools.png', 'caption': 'Explore Top Gadgets'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            SizedBox(width: 130),
            Image.asset(
              'assets/images/circle_logo.png',
              height: 100,
              width: 110,
            ),
            Spacer(),
            IconButton(
              icon: Icon(Icons.notifications),
              onPressed: () {},
            ),
            CircleAvatar(
              backgroundImage: AssetImage('assets/images/john2.jpg'),
            ),
          ],
        ),
      ),
      body: _selectedIndex == 0
          ? SingleChildScrollView(
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
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  if (_isCommunityUpdateVisible)
                    Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            color: Colors.amber[50],
                            child: ListTile(
                              leading:
                                  Icon(Icons.campaign, color: Colors.orange),
                              title: Text(
                                'Community Update',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                  'New items added in your area! Check out the latest camping gear for your weekend adventures.'),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 12,
                          right: 14,
                          child: IconButton(
                            icon: Icon(Icons.close, color: Colors.black),
                            onPressed: () {
                              setState(() {
                                _isCommunityUpdateVisible =
                                    false; // Hide the update note
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  CarouselSlider(
                    options: CarouselOptions(
                      height: 180,
                      autoPlay: true,
                      enlargeCenterPage: true,
                    ),
                    items: bannerData.map((data) {
                      return Builder(
                        builder: (BuildContext context) {
                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset(
                                  data['image']!,
                                  height: double.infinity,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                bottom: 10,
                                left: 16,
                                child: Text(
                                  data['caption']!,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(
                                        offset: Offset(0, 1),
                                        blurRadius: 4,
                                        color: Colors.black54,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    }).toList(),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Top Community Members',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Text('Top Lenders',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(height: 8),
                                  CircleAvatar(
                                    backgroundImage:
                                        AssetImage('assets/images/john1.jpg'),
                                    radius: 20,
                                  ),
                                  Text('Richard T.'),
                                  Text('24 items shared',
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Text('Top Borrowers',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(height: 8),
                                  CircleAvatar(
                                    backgroundImage:
                                        AssetImage('assets/images/john2.jpg'),
                                    radius: 20,
                                  ),
                                  Text('Mike L.'),
                                  Text('15 items borrowed',
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Categories',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Row(
                        children: [
                          SizedBox(width: 16),
                          _buildCategoryIcon(Icons.build, 'Tools', 142),
                          SizedBox(width: 24),
                          _buildCategoryIcon(Icons.sports_soccer, 'Sports', 89),
                          SizedBox(width: 24),
                          _buildCategoryIcon(Icons.book, 'Books', 235),
                          SizedBox(width: 24),
                          _buildCategoryIcon(Icons.laptop, 'Electronics', 167),
                          SizedBox(width: 16),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Available Nearby',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  _buildItemCard(
                    'Canon EOS 5D Mark IV',
                    'Professional camera with 24-70mm lens',
                    'assets/images/camera.jpg',
                    'Richard Thompson',
                    4.9,
                    0.3,
                  ),
                  _buildItemCard(
                    'DeWalt Power Drill Set',
                    'Complete set with various bits',
                    'assets/images/drill.jpg',
                    'Sarah Chen',
                    4.8,
                    0.5,
                  ),
                ],
              ),
            )
          : Center(
              child:
                  Text('Page $_selectedIndex')), // Placeholder for other pages

      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(
                Icons.home,
                color: _selectedIndex == 0
                    ? const Color.fromARGB(255, 172, 21, 144)
                    : Colors.black,
              ),
              onPressed: () => _onItemTapped(0),
            ),
            IconButton(
              icon: Icon(
                Icons.explore,
                color: _selectedIndex == 1
                    ? const Color.fromARGB(255, 172, 21, 144)
                    : Colors.black,
              ),
              onPressed: () => _onItemTapped(1),
            ),
            SizedBox(width: 40), // Space for the FloatingActionButton
            IconButton(
              icon: Icon(
                Icons.chat,
                color: _selectedIndex == 2
                    ? const Color.fromARGB(255, 172, 21, 144)
                    : Colors.black,
              ),
              onPressed: () => _onItemTapped(2),
            ),
            IconButton(
              icon: Icon(
                Icons.person,
                color: _selectedIndex == 3
                    ? const Color.fromARGB(255, 172, 21, 144)
                    : Colors.black,
              ),
              onPressed: () => _onItemTapped(3),
            ),
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

  // Update selected index and rebuild widget
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Category icon builder
  Widget _buildCategoryIcon(IconData icon, String label, int itemCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            child: Icon(icon, size: 30),
          ),
          SizedBox(height: 8),
          Text(label),
          Text('$itemCount items',
              style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  // Item card builder
  Widget _buildItemCard(String title, String subtitle, String imagePath,
      String owner, double rating, double distance) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                imagePath,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
            ),
            title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(subtitle),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundImage: AssetImage('assets/images/john1.jpg'),
                    ),
                    SizedBox(width: 8),
                    Text(owner,
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    SizedBox(width: 4),
                    Text(rating.toString(), style: TextStyle(fontSize: 12)),
                    SizedBox(width: 16),
                    Icon(Icons.location_on, color: Colors.red, size: 16),
                    SizedBox(width: 4),
                    Text('${distance.toString()} mi',
                        style: TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
