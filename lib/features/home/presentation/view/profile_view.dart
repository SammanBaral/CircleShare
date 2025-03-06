import 'dart:async';
import 'dart:math';

import 'package:circle_share/app/constants/api_endpoints.dart';
import 'package:circle_share/app/di/di.dart';
import 'package:circle_share/app/shared_prefs/token_shared_prefs.dart';
import 'package:circle_share/core/network/hive_service.dart';
import 'package:circle_share/features/auth/data/data_source/auth_data_source.dart';
import 'package:circle_share/features/auth/data/data_source/remote_data_source/auth_remote_datasource.dart';
import 'package:circle_share/features/auth/domain/entity/auth_entity.dart';
import 'package:circle_share/features/auth/presentation/view/login_view.dart';
import 'package:circle_share/features/auth/presentation/view_model/login/login_bloc.dart';
import 'package:circle_share/features/home/presentation/view/edit_profile_view.dart';
import 'package:circle_share/features/home/presentation/view/update_item_view.dart';
import 'package:circle_share/features/items/domain/entity/item_entity.dart';
import 'package:circle_share/features/items/domain/use_case/get_user_item_usecase.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final IAuthDataSource _authDataSource;
  late final GetUserItemsUseCase _getUserItemsUseCase;
  late final GetBorrowedItemsUseCase _getBorrowedItemsUseCase;
  late final Dio _dio;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  // Shake detection related variables
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  DateTime? _lastShakeTime;
  static const _shakeThreshold =
      20.0; // Adjust this value based on sensitivity needed
  static const _shakeTimeThreshold =
      Duration(milliseconds: 500); // Minimum time between shakes
  static const _logoutShakeCount =
      3; // Number of shakes needed to trigger logout
  int _shakeCount = 0;

  bool isLoading = true;
  late AuthEntity currentUser;
  List<ItemEntity> userItems = [];
  List<ItemEntity> borrowedItems = [];
  Map<String, String> locationMap = {};
  Map<String, String> categoryMap = {};

  @override
  void initState() {
    super.initState();

    // Initialize dependencies
    _initializeDependencies();

    // Set up shake detection
    _setupShakeDetection();

    // Load profile data
    loadUserProfile();
  }

  void _initializeDependencies() {
    print('ProfileScreen: Initializing dependencies');

    try {
      _authDataSource = getIt<AuthRemoteDataSource>();
      print(
          'ProfileScreen: Got _authDataSource: ${_authDataSource.runtimeType}');
    } catch (e) {
      print('ProfileScreen: Error getting AuthRemoteDataSource: $e');
    }

    try {
      _getUserItemsUseCase = getIt<GetUserItemsUseCase>();
      print(
          'ProfileScreen: Got _getUserItemsUseCase: ${_getUserItemsUseCase.runtimeType}');
    } catch (e) {
      print('ProfileScreen: Error getting GetUserItemsUseCase: $e');
    }

    try {
      _getBorrowedItemsUseCase = getIt<GetBorrowedItemsUseCase>();
      print(
          'ProfileScreen: Got _getBorrowedItemsUseCase: ${_getBorrowedItemsUseCase.runtimeType}');
    } catch (e) {
      print('ProfileScreen: Error getting GetBorrowedItemsUseCase: $e');
    }

    try {
      _dio = getIt<Dio>();
      print('ProfileScreen: Got _dio: ${_dio.runtimeType}');
    } catch (e) {
      print('ProfileScreen: Error getting Dio: $e');
    }
  }

  void _setupShakeDetection() {
    print('ProfileScreen: Setting up shake detection');

    _accelerometerSubscription =
        accelerometerEvents.listen((AccelerometerEvent event) {
      _detectShake(event);
    });
  }

  void _detectShake(AccelerometerEvent event) {
    // Calculate acceleration magnitude
    double acceleration =
        sqrt(event.x * event.x + event.y * event.y + event.z * event.z);

    // Check if acceleration exceeds threshold
    if (acceleration > _shakeThreshold) {
      final now = DateTime.now();

      // Check if this is the first shake or if enough time has elapsed since the last shake
      if (_lastShakeTime == null ||
          now.difference(_lastShakeTime!) > _shakeTimeThreshold) {
        _shakeCount++;
        _lastShakeTime = now;

        print('ProfileScreen: Shake detected! Count: $_shakeCount');

        // Show visual feedback for shake (optional)
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Shake detected! $_shakeCount/$_logoutShakeCount'),
              duration: const Duration(milliseconds: 500),
            ),
          );
        }

        // Check if enough shakes for logout
        if (_shakeCount >= _logoutShakeCount) {
          print('ProfileScreen: Shake logout threshold reached!');
          _shakeCount = 0; // Reset counter

          // Perform logout
          _performLogout();
        }
      }
    }
  }

  @override
  void dispose() {
    // Clean up the accelerometer subscription
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  Future<void> loadUserProfile() async {
    print('ProfileScreen: loadUserProfile called');
    setState(() {
      isLoading = true;
    });

    try {
      // 1. Get current user data
      print('ProfileScreen: Getting current user');
      currentUser = await _authDataSource.getCurrentUser();
      print('ProfileScreen: Got current user: ${currentUser.userId}');

      // 2. Fetch locations and categories for item display
      print('ProfileScreen: Fetching locations');
      await fetchLocations();
      print('ProfileScreen: Fetching categories');
      await fetchCategories();

      // 3. Fetch user's items (items they are lending)
      if (currentUser.userId != null) {
        print(
            'ProfileScreen: About to fetch user items with ID: ${currentUser.userId}');
        await directFetchUserItems();
        print(
            'ProfileScreen: About to fetch borrowed items with ID: ${currentUser.userId}');
        await fetchBorrowedItems();
      } else {
        print('ProfileScreen: currentUser.userId is null, not fetching items');
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('ProfileScreen: Error loading profile: $e');
      setState(() {
        isLoading = false;
      });
      // Show error message to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load profile data: $e')),
        );
      }
    }
  }

// Fetch items created by the current user using direct Dio call
  Future<void> fetchUserItems() async {
    print('ProfileScreen: fetchUserItems called with direct Dio');
    try {
      // Check if userId is null before making the request
      if (currentUser.userId == null) {
        print('ProfileScreen: Error: User ID is null');
        return;
      }

      print('ProfileScreen: Making direct API call to fetch user items');
      final response = await _dio.get(
        '${ApiEndpoints.baseUrl}items/user/${currentUser.userId}',
      );
      print(
          'ProfileScreen: Direct API response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['success'] == true && data['data'] != null) {
          final itemsData = data['data'] as List<dynamic>;
          print('ProfileScreen: Received ${itemsData.length} items directly');

          List<ItemEntity> tempList = [];
          for (var item in itemsData) {
            // Parse category ID
            String catId;
            if (item['categoryId'] is Map) {
              catId = item['categoryId']['_id']?.toString() ?? '';
            } else {
              catId = item['categoryId']?.toString() ?? '';
            }

            // Parse location ID
            String locId;
            if (item['locationId'] is Map) {
              locId = item['locationId']['_id']?.toString() ?? '';
            } else {
              locId = item['locationId']?.toString() ?? '';
            }

            // Parse userId
            String userId;
            if (item['userId'] is Map) {
              userId = item['userId']['_id']?.toString() ?? '';
            } else {
              userId = item['userId']?.toString() ?? '';
            }

            tempList.add(ItemEntity(
              id: item['_id']?.toString() ?? '',
              name: item['name']?.toString() ?? '',
              categoryId: catId,
              locationId: locId,
              userId: userId,
              description: item['description']?.toString() ?? '',
              availabilityStatus:
                  item['availabilityStatus']?.toString() ?? 'unknown',
              borrowerId: item['borrowerId']?.toString(),
              imageName: item['imageName']?.toString() ?? '',
              rulesNotes: item['rulesNotes']?.toString() ?? '',
              price: _parsePrice(item['price']),
              condition: item['condition']?.toString() ?? 'unknown',
              maxBorrowDuration: _parseInt(item['maxBorrowDuration']),
            ));
          }

          setState(() {
            userItems = tempList;
            print(
                'ProfileScreen: updated userItems list, now has ${userItems.length} items');
          });
        }
      }
    } catch (e) {
      print('ProfileScreen: Exception in direct fetchUserItems: $e');
    }
  }

  Future<void> directFetchUserItems() async {
    print("Direct fetch user items called with ID: ${currentUser.userId}");
    try {
      final response = await _dio.get(
          "${ApiEndpoints.baseUrl}${ApiEndpoints.getUserItems}${currentUser.userId}");

      print(
          "Direct API call response: ${response.statusCode}, data: ${response.data}");

      if (response.statusCode == 200 && response.data['success'] == true) {
        final itemsData = response.data['data'] as List<dynamic>;
        List<ItemEntity> items = itemsData
            .map((item) => ItemEntity(
                  id: item['_id'],
                  name: item['name'],
                  categoryId: item['categoryId'] is Map
                      ? item['categoryId']['_id']
                      : item['categoryId'],
                  locationId: item['locationId'] is Map
                      ? item['locationId']['_id']
                      : item['locationId'],
                  userId: item['userId'] is Map
                      ? item['userId']['_id']
                      : item['userId'],
                  description: item['description'] ?? '',
                  price: _parsePrice(item['price']),
                  availabilityStatus: item['availabilityStatus'] ?? 'unknown',
                  imageName: item['imageName'],
                ))
            .toList();

        setState(() {
          userItems = items;
          print("Set user items to ${items.length} items");
        });
      }
    } catch (e) {
      print("Error in direct fetch: $e");
    }
  }

// Fetch items borrowed by the current user using the use case
  Future<void> fetchBorrowedItems() async {
    print('ProfileScreen: fetchBorrowedItems called');
    try {
      // Check if userId is null before calling the use case
      if (currentUser.userId == null) {
        print('ProfileScreen: Error: User ID is null');
        return;
      }

      // Now we can safely use the non-null userId
      print(
          'ProfileScreen: Calling _getBorrowedItemsUseCase with ID: ${currentUser.userId}');
      final result = await _getBorrowedItemsUseCase(currentUser.userId!);
      print('ProfileScreen: _getBorrowedItemsUseCase returned');

      result.fold(
        (failure) {
          print(
              'ProfileScreen: Error fetching borrowed items: ${failure.message}');
        },
        (items) {
          print('ProfileScreen: Received ${items.length} borrowed items');
          setState(() {
            borrowedItems = items;
          });
        },
      );
    } catch (e) {
      print('ProfileScreen: Exception in fetchBorrowedItems: $e');
    }
  }

  // Fetch categories for mapping category IDs to names
  Future<void> fetchCategories() async {
    try {
      final response =
          await _dio.get(ApiEndpoints.baseUrl + ApiEndpoints.getAllCategories);

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['success'] == true && data['data'] != null) {
          final categoriesData = data['data'] as List<dynamic>;

          Map<String, String> tempMap = {};
          for (var category in categoriesData) {
            String id = category['_id']?.toString() ?? '';
            String name = category['name']?.toString() ?? 'Unknown';
            tempMap[id] = name;
          }

          setState(() {
            categoryMap = tempMap;
          });
        }
      }
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  // Fetch locations for mapping location IDs to names
  Future<void> fetchLocations() async {
    try {
      final response =
          await _dio.get(ApiEndpoints.baseUrl + ApiEndpoints.getAllLocations);

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['success'] == true && data['data'] != null) {
          final locationsData = data['data'] as List<dynamic>;

          Map<String, String> tempMap = {};
          for (var location in locationsData) {
            String id = location['_id']?.toString() ?? '';
            String name = location['name']?.toString() ?? 'Unknown';
            tempMap[id] = name;
          }

          setState(() {
            locationMap = tempMap;
          });
        }
      }
    } catch (e) {
      print('Error fetching locations: $e');
    }
  }

  // Helper methods for parsing numeric values
  double _parsePrice(dynamic value) {
    if (value == null) return 0.0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) {
      try {
        return double.parse(value);
      } catch (_) {
        return 0.0;
      }
    }
    return 0.0;
  }

  int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      try {
        return int.parse(value);
      } catch (_) {
        return 0;
      }
    }
    return 0;
  }

  String getLocationName(String? locationId) {
    if (locationId == null || locationId.isEmpty) return '';
    return locationMap[locationId] ?? '';
  }

  String getCategoryName(String? categoryId) {
    if (categoryId == null || categoryId.isEmpty) return '';
    return categoryMap[categoryId] ?? '';
  }

  // Logout function
  Future<void> _performLogout() async {
    try {
      print('ProfileScreen: Logging out...');

      // Get the token preferences to clear stored token
      final tokenPrefs = getIt<TokenSharedPrefs>();
      final tokenResult = await tokenPrefs.clearToken();

      tokenResult.fold(
          (failure) =>
              print('ProfileScreen: Failed to clear token: ${failure.message}'),
          (_) => print('ProfileScreen: Token cleared successfully'));

      // Get the login bloc to reset authentication state
      try {
        final loginBloc = getIt<LoginBloc>();
        loginBloc.add(LogoutRequested());
        print('ProfileScreen: Logout event dispatched to LoginBloc');
      } catch (e) {
        print('ProfileScreen: Error getting LoginBloc: $e');
        // Continue with logout even if we can't get the bloc
      }

      // Clear any cached user data from Hive
      try {
        final hiveService = getIt<HiveService>();
        await hiveService.clearUser();
        print('ProfileScreen: User data cleared from Hive');
      } catch (e) {
        print('ProfileScreen: Error clearing user data: $e');
        // Continue with logout even if we can't clear the data
      }

      // Cancel any subscriptions before navigating
      _accelerometerSubscription?.cancel();

      // Navigate to login screen
      if (mounted) {
        print('ProfileScreen: Navigating to login screen');
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => LoginView()),
          (route) => false,
        );
      }
    } catch (e) {
      print('ProfileScreen: Error during logout: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // Show an info dialog about shake-to-logout feature
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Shake to Logout'),
                  content: const Text(
                      'Shake your device three times in succession to log out quickly.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Got it'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: loadUserProfile,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : currentUser == null
                ? const Center(
                    child: Text('Unable to load profile. Please log in again.'))
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    physics:
                        const AlwaysScrollableScrollPhysics(), // Important for RefreshIndicator to work
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile Header
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundImage: currentUser.image != null &&
                                      currentUser.image!.isNotEmpty
                                  ? NetworkImage(
                                      '${ApiEndpoints.baseUrl}auth/${currentUser.userId}/image')
                                  : const AssetImage(
                                          'assets/images/profile.jpg')
                                      as ImageProvider,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${currentUser.fName} ${currentUser.lName}',
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Statistics
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStats(
                                userItems.length.toString(), 'Items Shared'),
                            _buildStats(
                                userItems
                                    .where((i) => i.borrowerId != null)
                                    .length
                                    .toString(),
                                'Borrowers'),
                            _buildStats(
                                userItems
                                    .where((i) =>
                                        i.availabilityStatus == 'reserved')
                                    .length
                                    .toString(),
                                'Active Shares'),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Lending & Borrowing Tabs
                        DefaultTabController(
                          length: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const TabBar(
                                labelColor: Colors.black,
                                indicatorColor: Colors.black,
                                tabs: [
                                  Tab(text: 'Lending'),
                                  Tab(text: 'Borrowing'),
                                ],
                              ),
                              SizedBox(
                                height:
                                    userItems.isEmpty && borrowedItems.isEmpty
                                        ? 100
                                        : userItems.length > 2 ||
                                                borrowedItems.length > 2
                                            ? 350
                                            : 250,
                                child: TabBarView(
                                  children: [
                                    userItems.isEmpty
                                        ? const Center(
                                            child: Text('No items shared yet',
                                                style: TextStyle(
                                                    color: Colors.grey)))
                                        : _buildItemList(userItems),
                                    borrowedItems.isEmpty
                                        ? const Center(
                                            child: Text('No borrowed items',
                                                style: TextStyle(
                                                    color: Colors.grey)))
                                        : _buildItemList(borrowedItems,
                                            isBorrowed: true),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Settings
                        const Text('Settings',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),

                        const SizedBox(height: 10),

                        _buildSettingOption(Icons.edit, 'Edit Profile', () {
                          // Navigate to profile edit screen
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => UpdateUserView()));
                        }),
                        _buildSettingOption(
                            Icons.logout, 'Logout', _performLogout),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildStats(String value, String label) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildItemList(List<ItemEntity> items, {bool isBorrowed = false}) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildItemCard(
          item.name,
          isBorrowed
              ? 'Borrowed from ${item.userId ?? "Unknown"}'
              : item.borrowerId != null
                  ? 'Borrowed by ${item.borrowerId}'
                  : 'Available',
          item.price > 0 ? 'Price: \$${item.price.toStringAsFixed(2)}' : 'Free',
          item.id ?? '',
          item.imageName ?? '',
        );
      },
    );
  }

  Widget _buildItemCard(String title, String borrower, String status,
      String itemId, String imageName) {
    final Color statusColor = status.toLowerCase().contains('available')
        ? Colors.green
        : status.toLowerCase().contains('reserved')
            ? Colors.orange
            : Colors.red;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        onTap: () {
          // Navigate to update item screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UpdateItemScreen(itemId: itemId),
            ),
          ).then((refreshNeeded) {
            // Refresh data when coming back from update screen if update was successful
            if (refreshNeeded == true) {
              loadUserProfile();
            }
          });
        },
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: imageName.isNotEmpty
              ? Image.network(
                  '${ApiEndpoints.baseUrl}items/$itemId/image',
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported, size: 30),
                    );
                  },
                )
              : Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image, size: 30),
                ),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(borrower),
            Text(status,
                style:
                    TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingOption(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
