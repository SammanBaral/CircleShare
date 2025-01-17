import 'package:carousel_slider/carousel_slider.dart';
import 'package:circle_share/features/home/presentation/view_model/home_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeCubit(),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              const Spacer(),
              Image.asset(
                'assets/images/circle_logo.png',
                height: 100,
                width: 110,
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {},
              ),
              const CircleAvatar(
                backgroundImage: AssetImage('assets/images/john2.jpg'),
              ),
            ],
          ),
        ),
        body: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            return _buildHomeContent(context, state);
          },
        ),
        bottomNavigationBar: _buildBottomNavigationBar(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: const Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }

  Widget _buildHomeContent(BuildContext context, HomeState state) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchBar(),
          if (state.isCommunityUpdateVisible) _buildCommunityUpdate(context),
          _buildCarousel(),
          _buildSectionTitle(context, 'Top Community Members'),
          _buildTopMembers(),
          _buildSectionTitle(context, 'Categories'),
          _buildCategories(),
          _buildSectionTitle(context, 'Available Nearby'),
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
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search items to borrow...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildCommunityUpdate(BuildContext context) {
    final cubit = context.read<HomeCubit>();

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: Colors.amber[50],
            child: const ListTile(
              leading: Icon(Icons.campaign, color: Colors.orange),
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
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: cubit.toggleCommunityUpdateVisibility,
          ),
        ),
      ],
    );
  }

  Widget _buildCarousel() {
    final List<Map<String, String>> bannerData = [
      {'image': 'assets/images/camera.jpg', 'caption': 'Professional Tools'},
      {'image': 'assets/images/drill.jpg', 'caption': 'Available Nearby'},
      {'image': 'assets/images/tools.png', 'caption': 'Explore Top Gadgets'},
    ];

    return CarouselSlider(
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
                    style: const TextStyle(
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
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }

  Widget _buildTopMembers() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: _buildMemberCard('Top Lenders', 'Richard T.',
                '24 items shared', 'assets/images/john1.jpg'),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildMemberCard('Top Borrowers', 'Mike L.',
                '15 items borrowed', 'assets/images/john2.jpg'),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCard(
      String title, String name, String details, String imagePath) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            CircleAvatar(
              backgroundImage: AssetImage(imagePath),
              radius: 20,
            ),
            Text(name),
            Text(details,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          children: [
            const SizedBox(width: 24),
            _buildCategoryIcon(Icons.build, 'Tools', 142),
            const SizedBox(width: 40),
            _buildCategoryIcon(Icons.sports_soccer, 'Sports', 89),
            const SizedBox(width: 40),
            _buildCategoryIcon(Icons.book, 'Books', 235),
            const SizedBox(width: 40),
            _buildCategoryIcon(Icons.laptop, 'Electronics', 167),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryIcon(IconData icon, String label, int itemCount) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          child: Icon(icon, size: 30),
        ),
        const SizedBox(height: 8),
        Text(label),
        Text('$itemCount items',
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

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
            title: Text(title,
                style: const TextStyle(fontWeight: FontWeight.bold)),
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
                    const CircleAvatar(
                      radius: 12,
                      backgroundImage: AssetImage('assets/images/john1.jpg'),
                    ),
                    const SizedBox(width: 8),
                    Text(owner,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(rating.toString(),
                        style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 16),
                    const Icon(Icons.location_on, color: Colors.red, size: 16),
                    const SizedBox(width: 4),
                    Text('${distance.toString()} mi',
                        style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final cubit = context.read<HomeCubit>();

        return BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 8.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(
                  Icons.home,
                  color: state.selectedIndex == 0
                      ? const Color.fromARGB(255, 172, 21, 144)
                      : Colors.black,
                ),
                onPressed: () => cubit.setSelectedIndex(0),
              ),
              IconButton(
                icon: Icon(
                  Icons.explore,
                  color: state.selectedIndex == 1
                      ? const Color.fromARGB(255, 172, 21, 144)
                      : Colors.black,
                ),
                onPressed: () => cubit.setSelectedIndex(1),
              ),
              const SizedBox(width: 40),
              IconButton(
                icon: Icon(
                  Icons.chat,
                  color: state.selectedIndex == 2
                      ? const Color.fromARGB(255, 172, 21, 144)
                      : Colors.black,
                ),
                onPressed: () => cubit.setSelectedIndex(2),
              ),
              IconButton(
                icon: Icon(
                  Icons.account_circle,
                  color: state.selectedIndex == 3
                      ? const Color.fromARGB(255, 172, 21, 144)
                      : Colors.black,
                ),
                onPressed: () => cubit.setSelectedIndex(3),
              ),
            ],
          ),
        );
      },
    );
  }
}
