import 'dart:io';

import 'package:circle_share/app/constants/api_endpoints.dart';
import 'package:circle_share/app/di/di.dart';
import 'package:circle_share/core/common/snackbar/my_snackbar.dart';
import 'package:circle_share/features/auth/data/data_source/remote_data_source/auth_remote_datasource.dart';
import 'package:circle_share/features/auth/data/repository/auth_remote_repository.dart';
import 'package:circle_share/features/auth/domain/entity/auth_entity.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UpdateUserView extends StatefulWidget {
  const UpdateUserView({super.key});

  @override
  State<UpdateUserView> createState() => _UpdateUserViewState();
}

class _UpdateUserViewState extends State<UpdateUserView> {
  final _formKey = GlobalKey<FormState>();
  final _fNameController = TextEditingController();
  final _lNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _usernameController = TextEditingController();

  bool isLoading = true;
  late AuthEntity currentUser;
  File? _image; // To store the selected image

  final ImagePicker _picker = ImagePicker(); // Initialize ImagePicker

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Load user data
  Future<void> _loadUserData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final authDataSource = getIt<AuthRemoteDataSource>();
      currentUser = await authDataSource.getCurrentUser();

      _fNameController.text = currentUser.fName;
      _lNameController.text = currentUser.lName;
      _phoneController.text = currentUser.phone;
      _usernameController.text = currentUser.username;

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error loading user data: $e');

      if (mounted) {
        showMySnackBar(
          context: context,
          message: "Failed to load user data: $e",
          color: Colors.red,
        );
      }

      setState(() {
        isLoading = false;
      });
    }
  }

  // Image upload method
  Future<String?> _uploadImage(File imageFile) async {
    try {
      final authDataSource = getIt<AuthRemoteDataSource>();
      final imageName = await authDataSource.uploadProfilePicture(
          imageFile); // Assuming the API returns the image name
      return imageName;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // Pick image method
  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path); // Set the selected image
      });

      // Upload the image
      String? imageName = await _uploadImage(_image!);
      if (imageName != null) {
        setState(() {
          // Manually update the currentUser object with the new image name
          currentUser = AuthEntity(
            userId: currentUser.userId,
            fName: currentUser.fName,
            lName: currentUser.lName,
            image: imageName, // Update the image
            phone: currentUser.phone,
            username: currentUser.username,
            password: currentUser.password,
          );
        });
      } else {
        print('Image upload failed');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 32),
                        GestureDetector(
                          onTap: _pickImage, // Open image picker on tap
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey[300],
                            backgroundImage: _image != null
                                ? FileImage(
                                    _image!) // If user has selected an image, use FileImage
                                : (currentUser.image != null &&
                                        currentUser.image!.isNotEmpty
                                    ? NetworkImage(
                                            '${ApiEndpoints.baseUrl}auth/${currentUser.userId}/image')
                                        as ImageProvider<
                                            Object> // Use NetworkImage if image URL exists
                                    : null), // Ensure correct type
                            child: _image == null &&
                                    (currentUser.image == null ||
                                        currentUser.image!.isEmpty)
                                ? const Icon(Icons.person,
                                    size: 50, color: Colors.grey)
                                : null,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Text(
                                  "Update Profile",
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildTextField(_fNameController, "First Name",
                                    "Enter your first name"),
                                const SizedBox(height: 16),
                                _buildTextField(_lNameController, "Last Name",
                                    "Enter your last name"),
                                const SizedBox(height: 16),
                                _buildTextField(_phoneController, "Phone",
                                    "Enter your phone number"),
                                const SizedBox(height: 16),
                                _buildTextField(_usernameController, "Username",
                                    "Enter your username",
                                    enabled: false),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _updateProfile,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 16.0),
                                    child: Text(
                                      "Update",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  // Update profile method
  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() {
          isLoading = true;
        });

        // Create updated user data
        final updatedUser = AuthEntity(
          userId: currentUser.userId,
          fName: _fNameController.text,
          lName: _lNameController.text,
          phone: _phoneController.text,
          username: _usernameController.text,
          image: _image != null
              ? currentUser.image
              : currentUser
                  .image, // Ensure this correctly reflects the selected image
          password: '', // Leave empty for security
        );

        print('Attempting to update user: ${updatedUser.userId}');

        // Call the update user API using the repository
        final result =
            await getIt<AuthRemoteRepository>().updateUser(updatedUser);

        setState(() {
          isLoading = false;
        });

        result.fold(
          (failure) {
            print('Error updating user profile: ${failure.message}');
            showMySnackBar(
              context: context,
              message: "Failed to update profile: ${failure.message}",
              color: Colors.red,
            );
          },
          (_) {
            print(
                'User profile updated successfully for user: ${updatedUser.userId}');
            showMySnackBar(
              context: context,
              message: "Profile updated successfully!",
              color: Colors.green,
            );
            Navigator.pop(context);
          },
        );
      } catch (e) {
        print('Unexpected error updating user profile: $e');
        setState(() {
          isLoading = false;
        });

        showMySnackBar(
          context: context,
          message: "An error occurred: $e",
          color: Colors.red,
        );
      }
    } else {
      print('Form validation failed');
      showMySnackBar(
        context: context,
        message: "Please fix the errors above",
        color: Colors.red,
      );
    }
  }

  // Helper method to build text fields
  TextFormField _buildTextField(
      TextEditingController controller, String label, String hint,
      {bool enabled = true}) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "$label is required";
        }
        return null;
      },
    );
  }

  @override
  void dispose() {
    _fNameController.dispose();
    _lNameController.dispose();
    _phoneController.dispose();
    _usernameController.dispose();
    super.dispose();
  }
}
