import 'dart:io';

import 'package:circle_share/app/di/di.dart';
import 'package:circle_share/features/category/domain/entity/category_entity.dart';
import 'package:circle_share/features/category/presentation/view_model/category/category_bloc.dart';
import 'package:circle_share/features/items/presentation/view_model/item/item_bloc.dart';
import 'package:circle_share/features/location/domain/entity/location_entity.dart';
import 'package:circle_share/features/location/presentation/view_model/location/location_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

// This is a wrapper widget that provides all the necessary blocs
class AddItemScreen extends StatelessWidget {
  const AddItemScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Create blocs inside the build method
    return MultiBlocProvider(
      providers: [
        BlocProvider<ItemBloc>(
          create: (context) => getIt<ItemBloc>(),
        ),
        BlocProvider<CategoryBloc>(
          create: (context) => getIt<CategoryBloc>()..add(LoadCategories()),
        ),
        BlocProvider<LocationBloc>(
          create: (context) => getIt<LocationBloc>()..add(LoadLocations()),
        ),
      ],
      child: const AddItemView(),
    );
  }
}

// The actual form view
class AddItemView extends StatefulWidget {
  const AddItemView({super.key});

  @override
  State<AddItemView> createState() => _AddItemViewState();
}

class _AddItemViewState extends State<AddItemView> {
  final _key = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _rulesController = TextEditingController();
  final _priceController = TextEditingController();
  final _maxBorrowController = TextEditingController();

  File? _image;
  final ImagePicker _picker = ImagePicker();

  // Selected values
  CategoryEntity? _selectedCategory;
  LocationEntity? _selectedLocation;
  String? _selectedCondition;
  String? _selectedStatus;

  // Condition & Status enums
  final List<String> _conditions = ["new", "used", "good", "fair"];
  final List<String> _statuses = ["available", "unavailable", "reserved"];

  @override
  void initState() {
    super.initState();

    // Initialize default values for condition and status
    setState(() {
      _selectedCondition = _conditions.first;
      _selectedStatus = _statuses.first;
    });
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

  // Fetch image
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (!mounted) return; // Ensure widget is still mounted

      setState(() {
        _image = File(pickedFile.path);
      });

      // Dispatch event to upload the image
      context.read<ItemBloc>().add(UploadItemImage(file: _image!));
    }
  }

  // Form submission
  void _submitForm() {
  if (_key.currentState!.validate()) {
    final itemState = context.read<ItemBloc>().state;

    // Check if the imageName is null and show a snack bar if image is not uploaded
    if (_image == null) {
      // Optionally show a message but still allow submission
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Image is optional, submitting without it")),
      );
    }

    context.read<ItemBloc>().add(
      AddItem(
        context: context,
        name: _nameController.text,
        categoryId: _selectedCategory?.categoryId ?? "",
        description: _descriptionController.text,
        availabilityStatus: _selectedStatus!,
        locationId: _selectedLocation?.id ?? "",
        borrowerId: '', 
        imageName: _image != null ? 'image_file_name_here' : null, // Use a placeholder if no image
        rulesNotes: _rulesController.text.isNotEmpty ? _rulesController.text : '',
        price: double.tryParse(_priceController.text) ?? 0.0,
        condition: _selectedCondition!,
        maxBorrowDuration: int.tryParse(_maxBorrowController.text) ?? 0,
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Item'), centerTitle: true),
      body: SafeArea(
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
                    child: _image == null
                        ? const Center(
                            child: Icon(Icons.upload,
                                size: 40, color: Colors.grey))
                        : Image.file(_image!, fit: BoxFit.cover),
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
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Enter item name' : null,
                ),
                const SizedBox(height: 16),

                // Category Dropdown (Fetched from Backend)
                BlocConsumer<CategoryBloc, CategoryState>(
                  listener: (context, state) {
                    // When categories load, set the first one as default if nothing is selected
                    if (state.categories.isNotEmpty &&
                        _selectedCategory == null) {
                      setState(() {
                        _selectedCategory = state.categories.first;
                      });
                    }
                  },
                  builder: (context, state) {
                    if (state.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state.categories.isEmpty) {
                      // Check if there's an error
                      if (state.error != null && state.error!.isNotEmpty) {
                        return Text("Error: ${state.error}");
                      }
                      return const Text(
                          "No categories available - check API connection");
                    }
                    return DropdownButtonFormField<CategoryEntity>(
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      hint: const Text('Select a category'),
                      items: state.categories.map((category) {
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
                    );
                  },
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
                          value: e, child: Text(e.capitalize())))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedStatus = value),
                  value: _selectedStatus,
                  validator: (value) => value == null ? 'Select status' : null,
                ),
                const SizedBox(height: 16),

                // Location Dropdown (Fetched from Backend)
                BlocConsumer<LocationBloc, LocationState>(
                  listener: (context, state) {
                    // When locations load, set the first one as default if nothing is selected
                    if (state.locations.isNotEmpty &&
                        _selectedLocation == null) {
                      setState(() {
                        _selectedLocation = state.locations.first;
                      });
                    }
                  },
                  builder: (context, state) {
                    if (state.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state.locations.isEmpty) {
                      return const Text("No locations available");
                    }

                    return DropdownButtonFormField<LocationEntity>(
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        border: OutlineInputBorder(),
                      ),
                      hint: const Text('Select a location'),
                      items: state.locations.map((location) {
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
                    );
                  },
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
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Enter price' : null,
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
                          value: e, child: Text(e.capitalize())))
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
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Enter duration' : null,
                ),
                const SizedBox(height: 24),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    child:
                        const Text('List Item', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Extension for capitalizing first letter of dropdown items
extension StringCasing on String {
  String capitalize() => this[0].toUpperCase() + substring(1);
}