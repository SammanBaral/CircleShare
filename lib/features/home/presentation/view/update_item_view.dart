import 'dart:io';

import 'package:circle_share/app/constants/api_endpoints.dart';
import 'package:circle_share/app/di/di.dart';
import 'package:circle_share/features/category/domain/entity/category_entity.dart';
import 'package:circle_share/features/items/domain/entity/item_entity.dart';
import 'package:circle_share/features/location/domain/entity/location_entity.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

class UpdateItemScreen extends StatefulWidget {
  final String itemId;

  const UpdateItemScreen({super.key, required this.itemId});

  @override
  State<UpdateItemScreen> createState() => _UpdateItemScreenState();
}

class _UpdateItemScreenState extends State<UpdateItemScreen> {
  final _key = GlobalKey<FormState>();
  late final Dio _dio;

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _rulesController = TextEditingController();
  final _priceController = TextEditingController();
  final _maxBorrowController = TextEditingController();

  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isImageChanged = false;

  // Selected values
  CategoryEntity? _selectedCategory;
  LocationEntity? _selectedLocation;
  String? _selectedCondition;
  String? _selectedStatus;
  String? _currentImageName;
  String? _borrowerId;
  String? _userId;

  // Item data
  ItemEntity? _item;

  // Lists for categories and locations
  List<CategoryEntity> _categories = [];
  List<LocationEntity> _locations = [];

  // Condition & Status enums
  final List<String> _conditions = ["new", "used", "good", "fair"];
  final List<String> _statuses = ["available", "unavailable", "reserved"];

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _dio = getIt<Dio>();

    // Initialize default values
    _selectedCondition = _conditions.first;
    _selectedStatus = _statuses.first;

    // Load data
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await Future.wait([
        _loadItemDetails(),
        _loadCategories(),
        _loadLocations(),
      ]);
    } catch (e) {
      print("Error loading data: $e");
      if (mounted) {
        setState(() {
          _errorMessage = "Error loading data: $e";
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _rulesController.dispose();
    _priceController.dispose();
    _maxBorrowController.dispose();
    super.dispose();
  }

  // Load item details
  Future<void> _loadItemDetails() async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.baseUrl}items/${widget.itemId}',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final itemData = response.data['data'];

        // Safely parse fields
        String? catId;
        String? locId;
        String? userId;

        try {
          // Parse category ID
          if (itemData['categoryId'] is Map) {
            catId = itemData['categoryId']['_id']?.toString();
          } else {
            catId = itemData['categoryId']?.toString();
          }

          // Parse location ID
          if (itemData['locationId'] is Map) {
            locId = itemData['locationId']['_id']?.toString();
          } else {
            locId = itemData['locationId']?.toString();
          }

          // Parse userId
          if (itemData['userId'] is Map) {
            userId = itemData['userId']['_id']?.toString();
          } else {
            userId = itemData['userId']?.toString();
          }
        } catch (e) {
          print("Error parsing nested IDs: $e");
        }

        // Create item entity
        final ItemEntity item = ItemEntity(
          id: itemData['_id']?.toString(),
          name: itemData['name']?.toString() ?? '',
          categoryId: catId,
          locationId: locId,
          userId: userId,
          description: itemData['description']?.toString(),
          availabilityStatus:
              itemData['availabilityStatus']?.toString() ?? 'available',
          borrowerId: itemData['borrowerId']?.toString(),
          imageName: itemData['imageName']?.toString(),
          rulesNotes: itemData['rulesNotes']?.toString(),
          price: _parsePrice(itemData['price']),
          condition: itemData['condition']?.toString(),
          maxBorrowDuration: _parseInt(itemData['maxBorrowDuration']),
        );

        // Store the item
        _item = item;

        // Populate form
        if (mounted) {
          setState(() {
            _nameController.text = item.name;
            _descriptionController.text = item.description ?? '';
            _rulesController.text = item.rulesNotes ?? '';
            _priceController.text = item.price.toString();
            _maxBorrowController.text =
                (item.maxBorrowDuration ?? 0).toString();
            _selectedCondition = item.condition ?? _conditions.first;
            _selectedStatus = item.availabilityStatus ?? 'available';
            _currentImageName = item.imageName;
            _borrowerId = item.borrowerId;
            _userId = item.userId;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage =
                "Failed to load item details: ${response.data['message'] ?? 'Unknown error'}";
          });
        }
      }
    } catch (e) {
      print("Error in _loadItemDetails: $e");
      if (mounted) {
        setState(() {
          _errorMessage = "Error loading item details: $e";
        });
      }
    }
  }

  // Load categories
  Future<void> _loadCategories() async {
    try {
      final response = await _dio.get(
        ApiEndpoints.baseUrl + ApiEndpoints.getAllCategories,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final categoriesData = response.data['data'] as List<dynamic>;

        List<CategoryEntity> tempCategories = [];
        for (var cat in categoriesData) {
          tempCategories.add(CategoryEntity(
            categoryId: cat['_id']?.toString() ?? '',
            name: cat['name']?.toString() ?? '',
          ));
        }

        if (mounted) {
          setState(() {
            _categories = tempCategories;
          });
        }
      } else {
        print(
            "Error loading categories: ${response.data['message'] ?? 'Unknown error'}");
      }
    } catch (e) {
      print("Exception loading categories: $e");
    }
  }

  // Load locations
  Future<void> _loadLocations() async {
    try {
      final response = await _dio.get(
        ApiEndpoints.baseUrl + ApiEndpoints.getAllLocations,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final locationsData = response.data['data'] as List<dynamic>;

        List<LocationEntity> tempLocations = [];
        for (var loc in locationsData) {
          tempLocations.add(LocationEntity(
            id: loc['_id']?.toString() ?? '',
            name: loc['name']?.toString() ?? '',
          ));
        }

        if (mounted) {
          setState(() {
            _locations = tempLocations;
          });
        }
      } else {
        print(
            "Error loading locations: ${response.data['message'] ?? 'Unknown error'}");
      }
    } catch (e) {
      print("Exception loading locations: $e");
    }
  }

  // Update UI after all data is loaded
  void _updateUIAfterDataLoaded() {
    if (_item == null || !mounted) return;

    try {
      // Handle category selection
      if (_item!.categoryId != null &&
          _item!.categoryId!.isNotEmpty &&
          _categories.isNotEmpty) {
        for (var category in _categories) {
          if (category.categoryId == _item!.categoryId) {
            _selectedCategory = category;
            break;
          }
        }
      }

      // Default category if none matched
      if (_selectedCategory == null && _categories.isNotEmpty) {
        _selectedCategory = _categories.first;
      }

      // Handle location selection
      if (_item!.locationId != null &&
          _item!.locationId!.isNotEmpty &&
          _locations.isNotEmpty) {
        for (var location in _locations) {
          if (location.id == _item!.locationId) {
            _selectedLocation = location;
            break;
          }
        }
      }

      // Default location if none matched
      if (_selectedLocation == null && _locations.isNotEmpty) {
        _selectedLocation = _locations.first;
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print("Error in _updateUIAfterDataLoaded: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // If all data is loaded but UI hasn't been updated yet
    if (_item != null &&
        _categories.isNotEmpty &&
        _locations.isNotEmpty &&
        _isLoading) {
      _updateUIAfterDataLoaded();
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

  // Pick image
  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        if (!mounted) return;

        setState(() {
          _image = File(pickedFile.path);
          _isImageChanged = true;
        });

        // Upload image directly
        await _uploadImage(_image!);
      }
    } catch (e) {
      print("Error picking image: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error selecting image: $e')),
        );
      }
    }
  }

  // Upload image
  Future<void> _uploadImage(File file) async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Get file extension - default to jpg if not found
      String extension = 'jpg';
      try {
        if (file.path.contains('.')) {
          extension = file.path.split('.').last.toLowerCase();
        }
      } catch (e) {
        print("Error getting file extension: $e");
      }

      // Generate a safe filename
      String filename =
          "image_${DateTime.now().millisecondsSinceEpoch}.$extension";

      // Determine correct MIME type
      String mimeType = 'image/jpeg'; // default
      if (extension == 'png') mimeType = 'image/png';
      if (extension == 'gif') mimeType = 'image/gif';

      // Create MultipartFile with correct content type
      final imageFile = await MultipartFile.fromFile(
        file.path,
        filename: filename,
        contentType: MediaType.parse(mimeType),
      );

      // Create form data
      final formData = FormData.fromMap({
        'image': imageFile,
      });

      // Try upload endpoints (try both possible endpoints)
      Response? response;
      try {
        // First try uploadImage endpoint
        response = await _dio.post(
          '${ApiEndpoints.baseUrl}items/uploadImage',
          data: formData,
        );
      } catch (e) {
        print("Error with first upload endpoint, trying alternate: $e");
        // If that fails, try the upload endpoint
        response = await _dio.post(
          '${ApiEndpoints.baseUrl}items/upload',
          data: formData,
        );
      }

      if (response.statusCode == 200 && response.data['success'] == true) {
        print("Upload response: ${response.data}");

        // Extract image name from response
        String imageName = "";
        try {
          if (response.data['data'] != null) {
            final data = response.data['data'];
            if (data is Map) {
              // Try different possible field names
              imageName = data['filename']?.toString() ??
                  data['imageName']?.toString() ??
                  data['name']?.toString() ??
                  filename;
            } else if (data is String) {
              imageName = data;
            }
          }
        } catch (e) {
          print("Error extracting image name: $e");
        }

        // Fallback to original filename if extraction failed
        if (imageName.isEmpty) {
          imageName = filename;
        }

        if (mounted) {
          setState(() {
            _currentImageName = imageName;
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image uploaded successfully')),
          );
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Failed to upload image: ${response.data['message'] ?? 'Unknown error'}')),
          );
        }
      }
    } catch (e) {
      print("Error uploading image: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading image: $e')),
        );
      }
    }
  }

  // Submit form
  Future<void> _submitUpdateForm() async {
    if (_key.currentState!.validate()) {
      try {
        setState(() {
          _isLoading = true;
        });

        // Prepare data for update
        final Map<String, dynamic> updateData = {
          'name': _nameController.text,
          'categoryId': _selectedCategory?.categoryId, // Now nullable
          'description': _descriptionController.text,
          'availabilityStatus': _selectedStatus ?? 'available',
          'locationId': _selectedLocation?.id, // Now nullable
          'rulesNotes': _rulesController.text,
          'price': double.tryParse(_priceController.text) ?? 0.0,
          'condition': _selectedCondition ?? 'good',
          'maxBorrowDuration': int.tryParse(_maxBorrowController.text) ?? 0,
        };

        // Only include imageName if image was changed
        if (_isImageChanged &&
            _currentImageName != null &&
            _currentImageName!.isNotEmpty) {
          updateData['imageName'] = _currentImageName;
        }

        // Keep borrowerId if it exists
        if (_borrowerId != null && _borrowerId!.isNotEmpty) {
          updateData['borrowerId'] = _borrowerId;
        }

        // Make the update request
        final response = await _dio.put(
          '${ApiEndpoints.baseUrl}items/${widget.itemId}',
          data: updateData,
        );

        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          if (response.statusCode == 200 && response.data['success'] == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Item updated successfully!'),
                backgroundColor: Colors.green,
              ),
            );

            // Navigate back after success
            Future.delayed(const Duration(seconds: 1), () {
              if (mounted) {
                Navigator.pop(
                    context, true); // Return true to indicate successful update
              }
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Failed to update item: ${response.data['message'] ?? 'Unknown error'}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        print("Error submitting update: $e");
        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating item: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if we have all the data and can update the UI
    if (_item != null &&
        _categories.isNotEmpty &&
        _locations.isNotEmpty &&
        _isLoading) {
      _updateUIAfterDataLoaded();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Item'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isLoading = true;
                              _errorMessage = null;
                            });
                            _loadData();
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _key,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image Upload Field
                          InkWell(
                            onTap: _pickImage,
                            child: Container(
                              height: 150,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: _image != null
                                  ? Image.file(_image!, fit: BoxFit.cover)
                                  : (_currentImageName != null &&
                                          _currentImageName!.isNotEmpty)
                                      ? Image.network(
                                          '${ApiEndpoints.baseUrl}items/${widget.itemId}/image',
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            print(
                                                "Error loading image: $error");
                                            return const Center(
                                              child: Icon(
                                                  Icons.image_not_supported,
                                                  size: 40,
                                                  color: Colors.grey),
                                            );
                                          },
                                        )
                                      : const Center(
                                          child: Icon(Icons.upload,
                                              size: 40, color: Colors.grey)),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Item Name
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Item Name',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) => value == null || value.isEmpty
                                ? 'Enter item name'
                                : null,
                          ),
                          const SizedBox(height: 16),

                          // Category Dropdown
                          DropdownButtonFormField<CategoryEntity>(
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Category',
                              border: OutlineInputBorder(),
                            ),
                            hint: const Text('Select a category'),
                            items: _categories.map((category) {
                              return DropdownMenuItem<CategoryEntity>(
                                value: category,
                                child: Text(category.name),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedCategory = value;
                              });
                            },
                            value: _selectedCategory,
                            validator: (value) =>
                                value == null ? 'Select a category' : null,
                          ),
                          const SizedBox(height: 16),

                          // Description
                          TextFormField(
                            controller: _descriptionController,
                            decoration: const InputDecoration(
                              labelText: 'Description',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 3,
                            validator: (value) => value == null || value.isEmpty
                                ? 'Enter description'
                                : null,
                          ),
                          const SizedBox(height: 16),

                          // Availability Status Dropdown
                          DropdownButtonFormField<String>(
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Availability Status',
                              border: OutlineInputBorder(),
                            ),
                            items: _statuses
                                .map((e) => DropdownMenuItem(
                                    value: e, child: Text(_capitalizeText(e))))
                                .toList(),
                            onChanged: (value) =>
                                setState(() => _selectedStatus = value),
                            value: _selectedStatus,
                            validator: (value) =>
                                value == null ? 'Select status' : null,
                          ),
                          const SizedBox(height: 16),

                          // Location Dropdown
                          DropdownButtonFormField<LocationEntity>(
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Location',
                              border: OutlineInputBorder(),
                            ),
                            hint: const Text('Select a location'),
                            items: _locations.map((location) {
                              return DropdownMenuItem<LocationEntity>(
                                value: location,
                                child: Text(location.name),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedLocation = value;
                              });
                            },
                            value: _selectedLocation,
                            validator: (value) =>
                                value == null ? 'Select a location' : null,
                          ),
                          const SizedBox(height: 16),

                          // Rules & Notes
                          TextFormField(
                            controller: _rulesController,
                            decoration: const InputDecoration(
                              labelText: 'Rules & Notes',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 2,
                          ),
                          const SizedBox(height: 16),

                          // Price (per day)
                          TextFormField(
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Price (per day)',
                              prefixText: '\$ ',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) => value == null || value.isEmpty
                                ? 'Enter price'
                                : null,
                          ),
                          const SizedBox(height: 16),

                          // Condition Dropdown
                          DropdownButtonFormField<String>(
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Condition',
                              border: OutlineInputBorder(),
                            ),
                            items: _conditions
                                .map((e) => DropdownMenuItem(
                                    value: e, child: Text(_capitalizeText(e))))
                                .toList(),
                            onChanged: (value) =>
                                setState(() => _selectedCondition = value),
                            value: _selectedCondition,
                            validator: (value) =>
                                value == null ? 'Select condition' : null,
                          ),
                          const SizedBox(height: 16),

                          // Max Borrow Duration
                          TextFormField(
                            controller: _maxBorrowController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Maximum Borrow Duration (days)',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) => value == null || value.isEmpty
                                ? 'Enter duration'
                                : null,
                          ),
                          const SizedBox(height: 24),

                          // Update Button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _submitUpdateForm,
                              child: const Text('Update Item',
                                  style: TextStyle(fontSize: 16)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }

  // Safe capitalize function that handles empty strings
  String _capitalizeText(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
