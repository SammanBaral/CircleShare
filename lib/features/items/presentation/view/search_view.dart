import 'dart:async';
import 'dart:math';

import 'package:circle_share/app/constants/api_endpoints.dart';
import 'package:circle_share/features/category/domain/entity/category_entity.dart';
import 'package:circle_share/features/category/presentation/view_model/category/category_bloc.dart';
import 'package:circle_share/features/items/domain/entity/item_entity.dart';
import 'package:circle_share/features/items/presentation/view/item_detail_view.dart';
import 'package:circle_share/features/items/presentation/view_model/item/item_bloc.dart';
import 'package:circle_share/features/location/domain/entity/location_entity.dart';
import 'package:circle_share/features/location/presentation/view_model/location/location_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sensors_plus/sensors_plus.dart';

class EquipmentListingPage extends StatefulWidget {
  const EquipmentListingPage({super.key});

  @override
  _EquipmentListingPageState createState() => _EquipmentListingPageState();
}

class _EquipmentListingPageState extends State<EquipmentListingPage> {
  String searchQuery = '';
  bool _isFlipped = false;
  bool _flipDetected = false;
  bool _sensorAvailable = false;
  late StreamSubscription<GyroscopeEvent> _gyroscopeSubscription;
  late StreamSubscription<AccelerometerEvent> _accelerometerSubscription;
  DateTime? _lastRefreshTime;
  final _refreshCooldownDuration = const Duration(seconds: 3);
  int _flipEventsCount = 0;
  
  // Flip detection parameters
  bool _wasUpsideDown = false;
  final double _flipThreshold = 9.0; // Threshold to determine if the device is upside down

  @override
  void initState() {
    super.initState();

    // Debug: Print when component initializes
    print('EquipmentListingPage initializing');

    // Initialize flip detection
    _setupFlipDetection();

    // Load all required data via BLoCs
    _loadData();
  }

  void _setupFlipDetection() {
    print('Setting up flip detection');
    try {
      // Check if sensors are available
      accelerometerEvents.first.then((_) {
        print('✅ Accelerometer is available on this device');
        gyroscopeEvents.first.then((_) {
          print('✅ Gyroscope is available on this device');
          if (mounted) {
            setState(() {
              _sensorAvailable = true;
            });
          }
        }).catchError((e) {
          print('❌ Gyroscope is NOT available: $e');
        });
      }).catchError((e) {
        print('❌ Accelerometer is NOT available: $e');
        if (mounted) {
          setState(() {
            _sensorAvailable = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Motion sensors not available on this device'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      });
      
      // Use accelerometer to detect when phone is upside down
      _accelerometerSubscription = accelerometerEvents.listen((AccelerometerEvent event) {
        // If z-axis is negative, phone is upside down
        bool isUpsideDown = event.z < -_flipThreshold;
        
        // Detect flip sequence (phone was upside down, and now it's not)
        if (_wasUpsideDown && !isUpsideDown) {
          _flipEventsCount++;
          print('📱 Flip detected! Flip count: $_flipEventsCount');
          
          // Check cooldown period
          final now = DateTime.now();
          if (_lastRefreshTime == null || 
              now.difference(_lastRefreshTime!) > _refreshCooldownDuration) {
            
            setState(() {
              _flipDetected = true;
            });
            
            _refreshWithFlip();
            _lastRefreshTime = now;
            
            // Reset flip detection visual after a short delay
            Future.delayed(const Duration(milliseconds: 800), () {
              if (mounted) {
                setState(() {
                  _flipDetected = false;
                });
              }
            });
          } else {
            print('⏳ Ignoring flip refresh - within cooldown period');
          }
        }
        
        // Update flip state visualization
        if (isUpsideDown != _isFlipped && mounted) {
          setState(() {
            _isFlipped = isUpsideDown;
          });
        }
        
        // Save current state for next comparison
        _wasUpsideDown = isUpsideDown;
      });
      
      // Also listen to gyroscope for more responsive detection (optional)
      _gyroscopeSubscription = gyroscopeEvents.listen((GyroscopeEvent event) {
        // This is just for additional data, main detection is in accelerometer
        double rotationRate = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
        if (rotationRate > 10.0) {
          print('🔄 High rotation rate detected: $rotationRate');
        }
      });
    } catch (e) {
      print('❌ Error setting up flip detection: $e');
      setState(() {
        _sensorAvailable = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to initialize motion sensors: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _refreshWithFlip() {
    print('Refreshing via flip gesture');
    _refresh();

    // Show snackbar notification
    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Content refreshed with flip gesture!'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    // Cancel sensor subscriptions
    _accelerometerSubscription.cancel();
    _gyroscopeSubscription.cancel();
    super.dispose();
  }

  // Method to load all data
  void _loadData() {
    print('Loading all data for equipment page');
    context.read<ItemBloc>().add(LoadItems());
    context.read<CategoryBloc>().add(LoadCategories());
    context.read<LocationBloc>().add(LoadLocations());
  }

  // Manual refresh method
  void _refresh() {
    print('Manually refreshing all data');
    _loadData();
  }

  // Get location name from ID using the location bloc state
  String getLocationName(String? locationId, List<LocationEntity> locations) {
    if (locationId == null || locationId.isEmpty) return '';

    final location = locations.firstWhere(
      (loc) => loc.id == locationId,
      orElse: () => LocationEntity(id: '', name: ''),
    );

    return location.name;
  }

  // Get category name from ID using the category bloc state
  String getCategoryName(String? categoryId, List<CategoryEntity> categories) {
    if (categoryId == null || categoryId.isEmpty) return '';

    final category = categories.firstWhere(
      (cat) => cat.categoryId == categoryId,
      orElse: () => CategoryEntity(categoryId: '', name: ''),
    );

    return category.name;
  }

  // Filter listings based on search query
  List<ItemEntity> getFilteredListings(List<ItemEntity> listings) {
    print('Filtering listings. Original count: ${listings.length}');

    if (searchQuery.isEmpty) {
      return listings;
    }

    final filtered = listings
        .where((item) =>
            item.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
            (item.description?.toLowerCase() ?? '')
                .contains(searchQuery.toLowerCase()))
        .toList();

    print('After filtering: ${filtered.length} items match search query');
    return filtered;
  }

  void _showSensorInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Flip-to-Refresh Feature'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                    'Flip your phone face down and then back up to refresh the content.\n\n'
                    'This feature uses your device\'s motion sensors to detect when you flip your phone.'),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isFlipped ? Icons.screen_rotation : Icons.screen_lock_portrait,
                        color: _isFlipped ? Colors.orange : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _sensorAvailable 
                              ? (_isFlipped 
                                  ? 'Phone is currently upside down!' 
                                  : 'Phone is right side up.')
                              : 'Motion sensors are not available on this device.',
                          style: TextStyle(
                            color: _isFlipped ? Colors.orange : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Total flips detected: $_flipEventsCount',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Got it'),
              ),
              TextButton(
                onPressed: _sensorAvailable ? () {
                  // This will refresh the StatefulBuilder with the latest sensor state
                  setState(() {});
                } : null,
                child: const Text('Refresh Status'),
              ),
            ],
          );
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Equipment Listings'),
        actions: [
          // Add flip indicator icon with feedback
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _flipDetected ? Colors.green.withOpacity(0.3) : 
                     _isFlipped ? Colors.orange.withOpacity(0.3) : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                _flipDetected
                    ? const Icon(Icons.refresh, color: Colors.green)
                    : _isFlipped
                        ? const Icon(Icons.screen_rotation, color: Colors.orange)
                        : Icon(
                            _sensorAvailable ? Icons.screen_rotation : Icons.sensors_off,
                            color: _sensorAvailable ? Colors.grey : Colors.red,
                          ),
                if (_flipDetected) 
                  const Text(' FLIP', 
                    style: TextStyle(
                      color: Colors.green, 
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                if (_isFlipped && !_flipDetected) 
                  const Text(' FLIPPED', 
                    style: TextStyle(
                      color: Colors.orange, 
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          // Add a refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
            tooltip: 'Refresh',
          ),
          // Add info button
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showSensorInfoDialog,
            tooltip: 'How to use flip-to-refresh',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search field
            TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'What equipment are you looking for?',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 20),

            // Main content with BLoC builders
            Expanded(
              child: MultiBlocListener(
                listeners: [
                  BlocListener<ItemBloc, ItemState>(
                    listener: (context, state) {
                      // Debug state changes
                      print(
                          'Item state changed - isLoading: ${state.isLoading}, success: ${state.isSuccess}, items: ${state.items.length}');

                      if (state.error != null) {
                        print('Item error: ${state.error}');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: ${state.error}')),
                        );
                      }

                      // Print each item for debugging
                      if (!state.isLoading && state.items.isNotEmpty) {
                        print('Items loaded from state:');
                        for (var item in state.items) {
                          print('- Item: ${item.id} - ${item.name}');
                        }
                      }
                    },
                  ),
                  BlocListener<CategoryBloc, CategoryState>(
                    listener: (context, state) {
                      if (state.error != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: ${state.error}')),
                        );
                      }
                    },
                  ),
                  BlocListener<LocationBloc, LocationState>(
                    listener: (context, state) {
                      if (state.error != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: ${state.error}')),
                        );
                      }
                    },
                  ),
                ],
                child: BlocBuilder<ItemBloc, ItemState>(
                  builder: (context, itemState) {
                    // Debug BlocBuilder rendering
                    print(
                        'ItemBloc builder called with ${itemState.items.length} items, isLoading: ${itemState.isLoading}');

                    return BlocBuilder<CategoryBloc, CategoryState>(
                      builder: (context, categoryState) {
                        return BlocBuilder<LocationBloc, LocationState>(
                          builder: (context, locationState) {
                            // Show loading if any data is still loading
                            if (itemState.isLoading ||
                                categoryState.isLoading ||
                                locationState.isLoading) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            // Filter listings based on search query
                            final filteredListings =
                                getFilteredListings(itemState.items);

                            // Show empty state if no items found
                            if (filteredListings.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'No items found',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                    const SizedBox(height: 20),
                                    // Add a refresh button
                                    ElevatedButton.icon(
                                      onPressed: _refresh,
                                      icon: const Icon(Icons.refresh),
                                      label: const Text('Refresh'),
                                    ),
                                    const SizedBox(height: 10),
                                    _sensorAvailable
                                        ? const Text(
                                            'or flip your phone face down and back up',
                                            style: TextStyle(
                                                fontSize: 14, color: Colors.grey),
                                          )
                                        : const Text(
                                            'Motion sensors not available on this device',
                                            style: TextStyle(
                                                fontSize: 14, color: Colors.red),
                                          ),
                                    // Add debug info
                                    const SizedBox(height: 20),
                                    Text(
                                      'Debug - All items: ${itemState.items.length}',
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12),
                                    ),
                                  ],
                                ),
                              );
                            }

                            // Show the list of items
                            return RefreshIndicator(
                              onRefresh: () async {
                                _refresh();
                              },
                              child: ListView.builder(
                                itemCount: filteredListings.length,
                                itemBuilder: (context, index) {
                                  final item = filteredListings[index];

                                  // Get location and category names
                                  final locationName = getLocationName(
                                      item.locationId, locationState.locations);
                                  final categoryName = getCategoryName(
                                      item.categoryId,
                                      categoryState.categories);

                                  return Card(
                                    elevation: 3,
                                    margin: const EdgeInsets.only(bottom: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        // Navigate to ItemDetailView when tapped
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ItemDetailView(
                                              itemId: item.id ?? '',
                                            ),
                                          ),
                                        ).then((_) {
                                          // Refresh when returning
                                          _refresh();
                                        });
                                      },
                                      borderRadius: BorderRadius.circular(12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Item Image
                                          ClipRRect(
                                            borderRadius:
                                                const BorderRadius.vertical(
                                              top: Radius.circular(12),
                                            ),
                                            child: (item.imageName
                                                        ?.isNotEmpty ??
                                                    false)
                                                ? Image.network(
                                                    '${ApiEndpoints.baseUrl}items/${item.id}/image',
                                                    height: 180,
                                                    width: double.infinity,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context,
                                                        error, stackTrace) {
                                                      return Container(
                                                        height: 180,
                                                        width: double.infinity,
                                                        color: Colors.grey[300],
                                                        child: const Icon(
                                                            Icons
                                                                .image_not_supported,
                                                            size: 50),
                                                      );
                                                    },
                                                  )
                                                : Container(
                                                    height: 180,
                                                    width: double.infinity,
                                                    color: Colors.grey[300],
                                                    child: const Icon(
                                                        Icons.image,
                                                        size: 50),
                                                  ),
                                          ),

                                          // Item Details
                                          Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        item.name,
                                                        style: const TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 10,
                                                        vertical: 5,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.blue[100],
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                      ),
                                                      child: Text(
                                                        '\$${item.price.toStringAsFixed(2)}/day',
                                                        style: TextStyle(
                                                          color:
                                                              Colors.blue[800],
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  item.description ??
                                                      'No description available',
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 16),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    if (locationName.isNotEmpty)
                                                      Expanded(
                                                        child: Row(
                                                          children: [
                                                            Icon(
                                                                Icons
                                                                    .location_on,
                                                                size: 16,
                                                                color: Colors
                                                                    .grey[600]),
                                                            const SizedBox(
                                                                width: 4),
                                                            Expanded(
                                                              child: Text(
                                                                'Location: $locationName',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                            .grey[
                                                                        600]),
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    const SizedBox(width: 8),
                                                    if (categoryName.isNotEmpty)
                                                      Expanded(
                                                        child: Row(
                                                          children: [
                                                            Icon(Icons.category,
                                                                size: 16,
                                                                color: Colors
                                                                    .grey[600]),
                                                            const SizedBox(
                                                                width: 4),
                                                            Expanded(
                                                              child: Text(
                                                                'Category: $categoryName',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                            .grey[
                                                                        600]),
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                Row(
                                                  children: [
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 8,
                                                        vertical: 4,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            item.availabilityStatus ==
                                                                    'available'
                                                                ? Colors
                                                                    .green[100]
                                                                : Colors
                                                                    .red[100],
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4),
                                                      ),
                                                      child: Text(
                                                        (item.availabilityStatus ??
                                                                'unknown')
                                                            .capitalize(),
                                                        style: TextStyle(
                                                          color:
                                                              item.availabilityStatus ==
                                                                      'available'
                                                                  ? Colors.green[
                                                                      800]
                                                                  : Colors
                                                                      .red[800],
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 8,
                                                        vertical: 4,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            Colors.orange[100],
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4),
                                                      ),
                                                      child: Text(
                                                        'Condition: ${(item.condition ?? 'unknown').capitalize()}',
                                                        style: TextStyle(
                                                          color: Colors
                                                              .orange[800],
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Extension to capitalize strings
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}