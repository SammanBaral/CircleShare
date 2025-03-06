import 'package:carousel_slider/carousel_slider.dart';
import 'package:circle_share/app/di/di.dart';
import 'package:circle_share/features/category/presentation/view_model/category/category_bloc.dart';
import 'package:circle_share/features/home/presentation/view/profile_view.dart';
import 'package:circle_share/features/home/presentation/view_model/home_cubit.dart';
import 'package:circle_share/features/items/presentation/view/search_view.dart';
import 'package:circle_share/features/items/presentation/view_model/item/item_bloc.dart';
import 'package:circle_share/features/location/presentation/view_model/location/location_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<HomeCubit>()),
        BlocProvider(
            create: (_) => getIt<CategoryBloc>()..add(LoadCategories())),
        BlocProvider(
            create: (_) => getIt<LocationBloc>()..add(LoadLocations())),
        BlocProvider(create: (_) => getIt<ItemBloc>()..add(LoadItems())),
      ],
      child: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          // Get screen size for responsive layout
          final Size screenSize = MediaQuery.of(context).size;
          final bool isTablet = screenSize.width > 600;

          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              toolbarHeight: isTablet ? 80 : 60,
              title: Row(
                children: [
                  const Spacer(),
                  Image.asset(
                    'assets/images/circle_logo.png',
                    height: isTablet ? 130 : 100,
                    width: isTablet ? 140 : 110,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      Icons.notifications,
                      size: isTablet ? 30 : 24,
                    ),
                    onPressed: () {},
                  ),
                  CircleAvatar(
                    backgroundImage:
                        const AssetImage('assets/images/john2.jpg'),
                    radius: isTablet ? 24 : 18,
                  ),
                ],
              ),
            ),
            body: IndexedStack(
              index: state.selectedIndex,
              children: [
                _buildHomeContent(context, state, isTablet), // Index 0: Home
                EquipmentListingPage(), // Index 1: Equipment Listings
                Center(child: Text('Chat Page')), // Index 2: Chat (Placeholder)
                ProfileScreen(), // Index 3: Profile
              ],
            ),
            bottomNavigationBar: BottomNavBar(isTablet: isTablet),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                context.read<HomeCubit>().navigateToAddItemView(context);
              },
              child: Icon(
                Icons.add,
                size: isTablet ? 32 : 24,
              ),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
          );
        },
      ),
    );
  }

  Widget _buildHomeContent(
      BuildContext context, HomeState state, bool isTablet) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: isTablet ? 16.0 : 8.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (state.isCommunityUpdateVisible)
              _buildCommunityUpdate(context, isTablet),
            _buildCarousel(isTablet),
            _buildSectionTitle(context, 'Top Community Members', isTablet),
            _buildTopMembers(context, isTablet),
            _buildSectionTitle(context, 'Categories', isTablet),
            _buildCategories(context, isTablet),
            _buildSectionTitle(context, 'Available Nearby', isTablet),
            _buildAvailableNearby(context, isTablet),
            // Add extra padding at bottom for floating action button
            SizedBox(height: isTablet ? 80 : 60),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunityUpdate(BuildContext context, bool isTablet) {
    final cubit = context.read<HomeCubit>();

    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.all(isTablet ? 20.0 : 16.0),
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: Colors.amber[50],
            child: ListTile(
              contentPadding: EdgeInsets.all(isTablet ? 16.0 : 12.0),
              leading: Icon(
                Icons.campaign,
                color: Colors.orange,
                size: isTablet ? 32 : 24,
              ),
              title: Text(
                'Community Update',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isTablet ? 18 : 16,
                ),
              ),
              subtitle: Text(
                'New items added in your area! Check them out now.',
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: isTablet ? 16 : 12,
          right: isTablet ? 18 : 14,
          child: IconButton(
            icon: Icon(
              Icons.close,
              color: Colors.black,
              size: isTablet ? 24 : 20,
            ),
            onPressed: cubit.toggleCommunityUpdateVisibility,
          ),
        ),
      ],
    );
  }

  Widget _buildCarousel(bool isTablet) {
    final List<Map<String, String>> bannerData = [
      {'image': 'assets/images/camera.jpg', 'caption': 'Professional Tools'},
      {'image': 'assets/images/drill.jpg', 'caption': 'Available Nearby'},
      {'image': 'assets/images/tools.png', 'caption': 'Explore Top Gadgets'},
    ];

    return CarouselSlider(
      options: CarouselOptions(
        height: isTablet ? 240 : 180,
        autoPlay: true,
        enlargeCenterPage: true,
        viewportFraction: isTablet ? 0.85 : 0.9,
      ),
      items: bannerData.map((data) {
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
              bottom: isTablet ? 20 : 10,
              left: isTablet ? 24 : 16,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 12.0 : 8.0,
                  vertical: isTablet ? 8.0 : 4.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  data['caption']!,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isTablet ? 20 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, bool isTablet) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 24.0 : 16.0,
        vertical: isTablet ? 20.0 : 16.0,
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: isTablet ? 24 : 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTopMembers(BuildContext context, bool isTablet) {
    return BlocBuilder<ItemBloc, ItemState>(
      builder: (context, state) {
        // For debugging
        print(
            'ItemBloc state: isLoading=${state.isLoading}, itemCount=${state.items.length}');

        if (state.isLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        // For tablets, we can show more content side by side
        if (isTablet) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              children: [
                Expanded(
                  child: _buildMemberCard(
                      'Top Lenders',
                      'Richard T.',
                      '${state.items.length} items shared',
                      'assets/images/john1.jpg',
                      isTablet),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMemberCard('Top Borrowers', 'Mike L.',
                      '15 items borrowed', 'assets/images/john2.jpg', isTablet),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMemberCard('New Members', 'Sarah K.',
                      'Joined 2 days ago', 'assets/images/john1.jpg', isTablet),
                ),
              ],
            ),
          );
        }

        // For phones, show just two cards in a row
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Expanded(
                child: _buildMemberCard(
                    'Top Lenders',
                    'Richard T.',
                    '${state.items.length} items shared',
                    'assets/images/john1.jpg',
                    isTablet),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMemberCard('Top Borrowers', 'Mike L.',
                    '15 items borrowed', 'assets/images/john2.jpg', isTablet),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategories(BuildContext context, bool isTablet) {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        // For debugging
        print(
            'CategoryBloc state: isLoading=${state.isLoading}, categoryCount=${state.categories.length}');

        if (state.isLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state.categories.isEmpty) {
          // Default categories if empty
          final defaultCategories = [
            {'icon': Icons.build, 'name': 'Tools', 'count': 142},
            {'icon': Icons.sports_soccer, 'name': 'Sports', 'count': 89},
            {'icon': Icons.book, 'name': 'Books', 'count': 235},
            {'icon': Icons.laptop, 'name': 'Electronics', 'count': 167},
          ];

          return SizedBox(
            height: isTablet ? 150 : 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 16.0 : 8.0,
              ),
              itemCount: defaultCategories.length,
              itemBuilder: (context, index) {
                final category = defaultCategories[index];
                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 24.0 : 16.0,
                  ),
                  child: _buildCategoryIcon(
                    category['icon'] as IconData,
                    category['name'] as String,
                    category['count'] as int,
                    isTablet,
                  ),
                );
              },
            ),
          );
        }

        // Display actual categories from state
        return SizedBox(
          height: isTablet ? 150 : 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 16.0 : 8.0,
            ),
            itemCount: state.categories.length,
            itemBuilder: (context, index) {
              final category = state.categories[index];
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 24.0 : 16.0,
                ),
                child: _buildCategoryIcon(
                  _getCategoryIcon(category.name),
                  category.name,
                  0, // You could fetch count from backend if available
                  isTablet,
                ),
              );
            },
          ),
        );
      },
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    // Map category names to appropriate icons
    switch (categoryName.toLowerCase()) {
      case 'electronics':
        return Icons.laptop;
      case 'tools':
        return Icons.build;
      case 'sports':
        return Icons.sports_soccer;
      case 'books':
        return Icons.book;
      case 'kitchen':
        return Icons.kitchen;
      default:
        return Icons.category;
    }
  }

  Widget _buildAvailableNearby(BuildContext context, bool isTablet) {
    return BlocBuilder<ItemBloc, ItemState>(
      builder: (context, state) {
        // For debugging
        print('Building available nearby with state: ${state.toString()}');
        print(
            'ItemBloc state for nearby: isLoading=${state.isLoading}, itemCount=${state.items.length}');

        if (state.isLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Responsive grid for tablets, list for phones
        if (isTablet) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildItemCard(
                  'Digital Camera',
                  'Professional DSLR camera',
                  '\$25.00/day',
                  Icons.camera_alt,
                  isTablet,
                ),
                _buildItemCard(
                  'Power Drill',
                  'Cordless power drill with accessories',
                  '\$15.00/day',
                  Icons.build,
                  isTablet,
                ),
                _buildItemCard(
                  'Bicycle',
                  'Mountain bike, good condition',
                  '\$20.00/day',
                  Icons.pedal_bike,
                  isTablet,
                ),
                _buildItemCard(
                  'Camping Tent',
                  '4-person camping tent',
                  '\$30.00/day',
                  Icons.holiday_village,
                  isTablet,
                ),
              ],
            ),
          );
        }

        // List view for phones
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildItemListTile(
                'Digital Camera',
                'Professional DSLR camera',
                '\$25.00/day',
                Icons.camera_alt,
                isTablet,
              ),
              _buildItemListTile(
                'Power Drill',
                'Cordless power drill with accessories',
                '\$15.00/day',
                Icons.build,
                isTablet,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildItemCard(String title, String description, String price,
      IconData icon, bool isTablet) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 30),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  price,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to item detail
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                  ),
                  child: const Text('View'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemListTile(String title, String description, String price,
      IconData icon, bool isTablet) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 60,
            height: 60,
            color: Colors.grey[300],
            child: Icon(icon, size: 30),
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(description),
            const SizedBox(height: 4),
            Text(
              price,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () {
            // Navigate to item detail
          },
          child: const Text('View'),
        ),
      ),
    );
  }

  Widget _buildCategoryIcon(
      IconData icon, String label, int itemCount, bool isTablet) {
    return Column(
      children: [
        CircleAvatar(
          radius: isTablet ? 40 : 30,
          child: Icon(
            icon,
            size: isTablet ? 40 : 30,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: isTablet ? 16 : 14,
          ),
        ),
        Text(
          '$itemCount items',
          style: TextStyle(
            fontSize: isTablet ? 14 : 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildMemberCard(String title, String name, String details,
      String imagePath, bool isTablet) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 16.0 : 8.0),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isTablet ? 16 : 14,
              ),
            ),
            SizedBox(height: isTablet ? 12 : 8),
            CircleAvatar(
              backgroundImage: AssetImage(imagePath),
              radius: isTablet ? 30 : 20,
            ),
            SizedBox(height: isTablet ? 8 : 4),
            Text(
              name,
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
              ),
            ),
            Text(
              details,
              style: TextStyle(
                fontSize: isTablet ? 14 : 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Updated BottomNavBar to be responsive
class BottomNavBar extends StatelessWidget {
  final bool isTablet;

  const BottomNavBar({
    super.key,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        return BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 8.0,
          child: SizedBox(
            height: isTablet ? 70.0 : 60.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  context,
                  Icons.home,
                  'Home',
                  0,
                  state.selectedIndex,
                  isTablet,
                ),
                _buildNavItem(
                  context,
                  Icons.search,
                  'Search',
                  1,
                  state.selectedIndex,
                  isTablet,
                ),
                // Empty space for the FAB
                const SizedBox(width: 40),
                _buildNavItem(
                  context,
                  Icons.chat,
                  'Chat',
                  2,
                  state.selectedIndex,
                  isTablet,
                ),
                _buildNavItem(
                  context,
                  Icons.person,
                  'Profile',
                  3,
                  state.selectedIndex,
                  isTablet,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label,
      int index, int selectedIndex, bool isTablet) {
    final bool isSelected = selectedIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => context.read<HomeCubit>().setSelectedIndex(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.blue : Colors.grey,
              size: isTablet ? 30 : 24,
            ),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.blue : Colors.grey,
                fontSize: isTablet ? 14 : 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
