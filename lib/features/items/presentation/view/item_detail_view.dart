import 'package:circle_share/app/constants/api_endpoints.dart';
import 'package:circle_share/features/items/domain/entity/item_entity.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ItemDetailView extends StatefulWidget {
  final String itemId;

  const ItemDetailView({super.key, required this.itemId});

  @override
  State<ItemDetailView> createState() => _ItemDetailViewState();
}

class _ItemDetailViewState extends State<ItemDetailView> {
  bool isLoading = true;
  late ItemEntity item;
  late Map<String, String> locationMap = {};
  late Map<String, String> categoryMap = {};
  late String ownerName = "Unknown";
  final Dio _dio = Dio();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Fetch the item details
      await _fetchItem();

      // Fetch location and category data
      await _fetchLocations();
      await _fetchCategories();

      // Fetch owner details if userId is available
      if (item.userId != null && item.userId!.isNotEmpty) {
        await _fetchOwnerDetails(item.userId!);
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error loading item data: $e');
      setState(() {
        isLoading = false;
      });

      // Show error snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load item details: $e')),
        );
      }
    }
  }

  Future<void> _fetchItem() async {
    try {
      final response = await _dio.get(
          '${ApiEndpoints.baseUrl}${ApiEndpoints.getItemById}${widget.itemId}');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['success'] == true && data['data'] != null) {
          final itemData = data['data'];

          // Extract category ID correctly
          String catId;
          if (itemData['categoryId'] is Map) {
            catId = itemData['categoryId']['_id']?.toString() ?? '';
          } else {
            catId = itemData['categoryId']?.toString() ?? '';
          }

          // Extract location ID correctly
          String locId;
          if (itemData['locationId'] is Map) {
            locId = itemData['locationId']['_id']?.toString() ?? '';
          } else {
            locId = itemData['locationId']?.toString() ?? '';
          }

          // Extract userId correctly
          String? userId;
          if (itemData['userId'] is Map) {
            userId = itemData['userId']['_id']?.toString();
          } else {
            userId = itemData['userId']?.toString();
          }

          item = ItemEntity(
            id: itemData['_id']?.toString() ?? '',
            name: itemData['name']?.toString() ?? '',
            categoryId: catId,
            locationId: locId,
            userId: userId,
            description: itemData['description']?.toString() ?? '',
            availabilityStatus:
                itemData['availabilityStatus']?.toString() ?? 'unknown',
            borrowerId: itemData['borrowerId']?.toString(),
            imageName: itemData['imageName']?.toString() ?? '',
            rulesNotes: itemData['rulesNotes']?.toString() ?? '',
            price: _parsePrice(itemData['price']),
            condition: itemData['condition']?.toString() ?? 'unknown',
            maxBorrowDuration: _parseInt(itemData['maxBorrowDuration']),
          );
        } else {
          throw Exception('Failed to load item data');
        }
      } else {
        throw Exception('Failed to load item data');
      }
    } catch (e) {
      print('Error fetching item: $e');
      rethrow;
    }
  }

  Future<void> _fetchLocations() async {
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
      // Continue without locations rather than failing completely
    }
  }

  Future<void> _fetchCategories() async {
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
      // Continue without categories rather than failing completely
    }
  }

  Future<void> _fetchOwnerDetails(String userId) async {
    try {
      // Get authentication token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        print('No authentication token available');
        setState(() {
          ownerName = 'User $userId';
        });
        return;
      }

      // Log the API call we're about to make
      print('Fetching owner details for userId: $userId');

      // Make API call with authorization
      final response = await _dio.get(
        '${ApiEndpoints.baseUrl}auth/getUser/$userId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      print('Owner details response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;
        print('Owner details data: $data');

        if (data != null && data['data'] != null) {
          final userData = data['data'];

          // Update owner name with username if available
          setState(() {
            if (userData['username'] != null) {
              ownerName = userData['username'];
            } else {
              String fullName =
                  '${userData['fname'] ?? ''} ${userData['lname'] ?? ''}'
                      .trim();
              ownerName = fullName.isNotEmpty ? fullName : 'User $userId';
            }
          });
          print('Owner name set to: $ownerName');
        } else {
          setState(() {
            ownerName = 'User $userId';
          });
        }
      } else {
        print('Failed to fetch owner details: ${response.statusCode}');
        setState(() {
          ownerName = 'User $userId';
        });
      }
    } catch (e) {
      print('Error fetching owner details: $e');
      // Fallback to using userId
      setState(() {
        ownerName = 'User $userId';
      });
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

  // Get location name from ID
  String getLocationName(String? locationId) {
    if (locationId == null || locationId.isEmpty) return '';
    return locationMap[locationId] ?? 'Unknown Location';
  }

  // Get category name from ID
  String getCategoryName(String? categoryId) {
    if (categoryId == null || categoryId.isEmpty) return '';
    return categoryMap[categoryId] ?? 'Unknown Category';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Details'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Item Image
                  Stack(
                    children: [
                      (item.imageName?.isNotEmpty ?? false)
                          ? Image.network(
                              '${ApiEndpoints.baseUrl}items/${item.id}/image',
                              height: 250,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                print(
                                    "Image error: $error for ${item.imageName}");
                                return Container(
                                  height: 250,
                                  width: double.infinity,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.image_not_supported,
                                      size: 80),
                                );
                              },
                            )
                          : Container(
                              height: 250,
                              width: double.infinity,
                              color: Colors.grey[300],
                              child: const Icon(Icons.image, size: 80),
                            ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        left: 0,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.8),
                                Colors.transparent,
                              ],
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  item.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue[700],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '\$${item.price.toStringAsFixed(2)}/day',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Item Info Card
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Owner and Status Row
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.grey,
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Owner: $ownerName',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Text('Member since Jan 2024'),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: item.availabilityStatus == 'available'
                                    ? Colors.green[100]
                                    : Colors.red[100],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                (item.availabilityStatus ?? 'unknown')
                                    .toUpperCase(),
                                style: TextStyle(
                                  color: item.availabilityStatus == 'available'
                                      ? Colors.green[800]
                                      : Colors.red[800],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Description
                        const Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.description ?? 'No description provided',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[800],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Details
                        const Text(
                          'Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildDetailRow(
                            'Category', getCategoryName(item.categoryId)),
                        _buildDetailRow(
                            'Location', getLocationName(item.locationId)),
                        _buildDetailRow('Condition',
                            item.condition?.toUpperCase() ?? 'UNKNOWN'),
                        if (item.maxBorrowDuration != null &&
                            item.maxBorrowDuration! > 0)
                          _buildDetailRow('Max Borrow Duration',
                              '${item.maxBorrowDuration} days'),

                        const SizedBox(height: 24),

                        // Rules & Notes
                        if (item.rulesNotes != null &&
                            item.rulesNotes!.isNotEmpty) ...[
                          const Text(
                            'Rules & Notes',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.amber[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.amber, width: 1),
                            ),
                            child: Text(
                              item.rulesNotes!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.brown[800],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Borrow Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: item.availabilityStatus == 'available'
                                ? () {
                                    // Implement borrow functionality
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text('Borrow request sent!')),
                                    );
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: Colors.blue[700],
                              disabledBackgroundColor: Colors.grey[400],
                            ),
                            child: Text(
                              item.availabilityStatus == 'available'
                                  ? 'REQUEST TO BORROW'
                                  : 'CURRENTLY UNAVAILABLE',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Contact Button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {
                              // Implement contact functionality
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Messaging feature coming soon!')),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: BorderSide(color: Colors.blue[700]!),
                            ),
                            child: Text(
                              'CONTACT OWNER',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.blue[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey[900],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
