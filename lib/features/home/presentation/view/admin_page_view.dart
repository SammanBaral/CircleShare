import 'package:circle_share/app/constants/api_endpoints.dart';
import 'package:circle_share/app/di/di.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage>
    with SingleTickerProviderStateMixin {
  late final Dio _dio;
  bool _isLoading = true;
  String? _errorMessage;

  // Data lists
  List<dynamic> _users = [];
  List<dynamic> _items = [];
  List<dynamic> _categories = [];
  List<dynamic> _locations = [];

  // Tab controller
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _dio = getIt<Dio>();
    _tabController = TabController(length: 4, vsync: this);

    // Load initial data
    _loadAllData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Load all data
  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load data in parallel
      await Future.wait([
        _loadUsers(),
        _loadItems(),
        _loadCategories(),
        _loadLocations(),
      ]);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Error loading data: $e";
      });
    }
  }

  // Load users
  Future<void> _loadUsers() async {
    try {
      final response =
          await _dio.get('${ApiEndpoints.baseUrl}auth/getAllUsers');

      if (response.statusCode == 200 && response.data['success'] == true) {
        setState(() {
          _users = response.data['data'] ?? [];
        });
      } else {
        print(
            "Error loading users: ${response.data['message'] ?? 'Unknown error'}");
      }
    } catch (e) {
      print("Exception loading users: $e");
    }
  }

  // Load items
  Future<void> _loadItems() async {
    try {
      final response =
          await _dio.get('${ApiEndpoints.baseUrl}items/getAllItems');

      if (response.statusCode == 200 && response.data['success'] == true) {
        setState(() {
          _items = response.data['data'] ?? [];
        });
      } else {
        print(
            "Error loading items: ${response.data['message'] ?? 'Unknown error'}");
      }
    } catch (e) {
      print("Exception loading items: $e");
    }
  }

  // Load categories
  Future<void> _loadCategories() async {
    try {
      final response = await _dio
          .get('${ApiEndpoints.baseUrl}${ApiEndpoints.getAllCategories}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        setState(() {
          _categories = response.data['data'] ?? [];
        });
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
      final response = await _dio
          .get('${ApiEndpoints.baseUrl}${ApiEndpoints.getAllLocations}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        setState(() {
          _locations = response.data['data'] ?? [];
        });
      } else {
        print(
            "Error loading locations: ${response.data['message'] ?? 'Unknown error'}");
      }
    } catch (e) {
      print("Exception loading locations: $e");
    }
  }

  // Delete a user
  Future<void> _deleteUser(String userId) async {
    try {
      final response =
          await _dio.delete('${ApiEndpoints.baseUrl}auth/deleteUser/$userId');

      if (response.statusCode == 200 && response.data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User deleted successfully')),
        );
        _loadUsers(); // Reload users
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Failed to delete user: ${response.data['message'] ?? ''}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting user: $e')),
      );
    }
  }

  // Delete an item
  Future<void> _deleteItem(String itemId) async {
    try {
      final response =
          await _dio.delete('${ApiEndpoints.baseUrl}items/$itemId');

      if (response.statusCode == 200 && response.data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item deleted successfully')),
        );
        _loadItems(); // Reload items
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Failed to delete item: ${response.data['message'] ?? ''}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting item: $e')),
      );
    }
  }

  // Delete a category
  Future<void> _deleteCategory(String categoryId) async {
    try {
      final response =
          await _dio.delete('${ApiEndpoints.baseUrl}categories/$categoryId');

      if (response.statusCode == 200 && response.data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category deleted successfully')),
        );
        _loadCategories(); // Reload categories
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Failed to delete category: ${response.data['message'] ?? ''}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting category: $e')),
      );
    }
  }

  // Delete a location
  Future<void> _deleteLocation(String locationId) async {
    try {
      final response =
          await _dio.delete('${ApiEndpoints.baseUrl}locations/$locationId');

      if (response.statusCode == 200 && response.data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location deleted successfully')),
        );
        _loadLocations(); // Reload locations
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Failed to delete location: ${response.data['message'] ?? ''}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting location: $e')),
      );
    }
  }

  // Add new category dialog
  Future<void> _showAddCategoryDialog() async {
    final TextEditingController nameController = TextEditingController();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Category'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Category Name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  await _addCategory(nameController.text);
                  if (mounted) Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  // Add new location dialog
  Future<void> _showAddLocationDialog() async {
    final TextEditingController nameController = TextEditingController();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Location'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Location Name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  await _addLocation(nameController.text);
                  if (mounted) Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  // Add category
  Future<void> _addCategory(String name) async {
    try {
      final response = await _dio.post(
        '${ApiEndpoints.baseUrl}categories/createCategory',
        data: {'name': name},
      );

      if (response.statusCode == 201 && response.data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category added successfully')),
        );
        _loadCategories(); // Reload categories
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Failed to add category: ${response.data['message'] ?? ''}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding category: $e')),
      );
    }
  }

  // Add location
  Future<void> _addLocation(String name) async {
    try {
      final response = await _dio.post(
        '${ApiEndpoints.baseUrl}locations/createLocation',
        data: {'name': name},
      );

      if (response.statusCode == 201 && response.data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location added successfully')),
        );
        _loadLocations(); // Reload locations
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Failed to add location: ${response.data['message'] ?? ''}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding location: $e')),
      );
    }
  }

  // Build User List
  Widget _buildUserList() {
    return ListView.builder(
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final user = _users[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: ListTile(
            leading: CircleAvatar(
              child: Text(user['image']?[0] ?? '?'),
            ),
            title: Text('${user['fname'] ?? 'Unknown'} ${user['lname'] ?? ''}'),
            subtitle: Text(user['phone'] ?? 'No phoneNo'),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                // Show confirmation dialog
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete User'),
                    content: const Text(
                        'Are you sure you want to delete this user?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _deleteUser(user['_id']);
                        },
                        child: const Text('Delete',
                            style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  // Build Item List
  Widget _buildItemList() {
    return ListView.builder(
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
              child: item['imageName'] != null
                  ? Image.network(
                      '${ApiEndpoints.baseUrl}items/${item['_id']}/image',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.image_not_supported),
                    )
                  : const Icon(Icons.image),
            ),
            title: Text(item['name'] ?? 'Unnamed Item'),
            subtitle: Text(
              '${item['description'] != null ? (item['description'].length > 30 ? '${item['description'].substring(0, 30)}...' : item['description']) : 'No description'}\n'
              'Status: ${item['availabilityStatus'] ?? 'Unknown'}',
            ),
            isThreeLine: true,
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                // Show confirmation dialog
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Item'),
                    content: const Text(
                        'Are you sure you want to delete this item?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _deleteItem(item['_id']);
                        },
                        child: const Text('Delete',
                            style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  // Build Category List
  Widget _buildCategoryList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton.icon(
            onPressed: _showAddCategoryDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add Category'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(40),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: ListTile(
                  title: Text(category['name'] ?? 'Unnamed Category'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      // Show confirmation dialog
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Category'),
                          content: const Text(
                              'Are you sure you want to delete this category? This might affect items using this category.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _deleteCategory(category['_id']);
                              },
                              child: const Text('Delete',
                                  style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Build Location List
  Widget _buildLocationList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton.icon(
            onPressed: _showAddLocationDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add Location'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(40),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _locations.length,
            itemBuilder: (context, index) {
              final location = _locations[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: ListTile(
                  title: Text(location['name'] ?? 'Unnamed Location'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      // Show confirmation dialog
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Location'),
                          content: const Text(
                              'Are you sure you want to delete this location? This might affect items using this location.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _deleteLocation(location['_id']);
                              },
                              child: const Text('Delete',
                                  style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Main build method
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Users'),
            Tab(text: 'Items'),
            Tab(text: 'Categories'),
            Tab(text: 'Locations'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAllData,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _loadAllData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildUserList(),
                    _buildItemList(),
                    _buildCategoryList(),
                    _buildLocationList(),
                  ],
                ),
    );
  }
}
