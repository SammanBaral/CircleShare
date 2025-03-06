import 'dart:io';

import 'package:circle_share/core/common/snackbar/my_snackbar.dart';
import 'package:circle_share/features/auth/presentation/view/login_view.dart';
import 'package:circle_share/features/auth/presentation/view_model/signup/register_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fNameController = TextEditingController();
  final _lNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _usernameController = TextEditingController();

  File? _img;
  Future _browseImage(ImageSource imageSource) async {
    try {
      final image = await ImagePicker().pickImage(source: imageSource);
      if (image != null) {
        setState(() {
          _img = File(image.path);
          context.read<RegisterBloc>().add(UploadImage(file: _img!));
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/circle_logo.png',
                    height: 150,
                    width: 150,
                  ),
                  Text(
                    "Share and borrow items in your community",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  InkWell(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  _browseImage(ImageSource.camera);
                                  Navigator.pop(context);
                                },
                                icon: const Icon(Icons.camera),
                                label: const Text('Camera'),
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  _browseImage(ImageSource.gallery);
                                  Navigator.pop(context);
                                },
                                icon: const Icon(Icons.image),
                                label: const Text('Gallery'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: _img != null
                          ? FileImage(_img!)
                          : const AssetImage('assets/images/john1.jpg')
                              as ImageProvider,
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
                            "Register",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                              _fNameController,
                              "First Name",
                              "Enter your first name",
                              "First Name is required"),
                          const SizedBox(height: 16),
                          _buildTextField(_lNameController, "Last Name",
                              "Enter your last name", "Last Name is required"),
                          const SizedBox(height: 16),
                          _buildPhoneField(),
                          const SizedBox(height: 16),
                          _buildTextField(_usernameController, "Username",
                              "Create a username", "Username is required"),
                          const SizedBox(height: 16),
                          _buildPasswordField(),
                          const SizedBox(height: 16),
                          _buildConfirmPasswordField(),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                final registerState =
                                    context.read<RegisterBloc>().state;
                                final imageName = registerState.imageName;
                                context.read<RegisterBloc>().add(
                                      RegisterUser(
                                        context: context,
                                        fName: _fNameController.text,
                                        lName: _lNameController.text,
                                        phone: _phoneController.text,
                                        username: _usernameController.text,
                                        password: _passwordController.text,
                                        image: imageName,
                                      ),
                                    );
                              } else {
                                showMySnackBar(
                                  context: context,
                                  message: "Please fix the errors above",
                                  color: Colors.red,
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              child: Text(
                                "Create Account",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildLoginSection(context),
                          const SizedBox(height: 16),
                          _buildSocialLoginSection(),
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

  TextFormField _buildTextField(TextEditingController controller, String label,
      String hint, String errorMessage) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return errorMessage;
        }
        return null;
      },
    );
  }

  TextFormField _buildPhoneField() {
    return TextFormField(
      controller: _phoneController,
      decoration: InputDecoration(
        labelText: "Phone",
        hintText: "Enter your phone number",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Phone number is required";
        }
        if (!RegExp(r'^\d{10}').hasMatch(value)) {
          return "Enter a valid 10-digit phone number";
        }
        return null;
      },
    );
  }

  TextFormField _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      decoration: InputDecoration(
        labelText: "Password",
        hintText: "Create a password",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      obscureText: true,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Password is required";
        }
        if (value.length < 6) {
          return "Password must be at least 6 characters";
        }
        return null;
      },
    );
  }

  TextFormField _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      decoration: InputDecoration(
        labelText: "Confirm Password",
        hintText: "Confirm your password",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      obscureText: true,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Confirm Password is required";
        }
        if (value != _passwordController.text) {
          return "Passwords do not match";
        }
        return null;
      },
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fNameController.dispose();
    _lNameController.dispose();
    _phoneController.dispose();
    _usernameController.dispose();
    super.dispose();
  }
}

Widget _buildLoginSection(BuildContext context) {
  return Column(
    children: [
      Text(
        "Already have an account?",
        style: TextStyle(color: Colors.grey[600]),
      ),
      const SizedBox(height: 8),
      OutlinedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoginView()),
          );
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.black),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 12.0),
          child: Text(
            "Sign In",
            style: TextStyle(color: Colors.black),
          ),
        ),
      ),
    ],
  );
}

Widget _buildSocialLoginSection() {
  return Column(
    children: [
      Row(
        children: [
          const Expanded(child: Divider(thickness: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              "Or continue with",
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          const Expanded(child: Divider(thickness: 1)),
        ],
      ),
      const SizedBox(height: 16),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.g_translate),
            iconSize: 32,
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.facebook),
            iconSize: 32,
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.apple),
            iconSize: 32,
          ),
        ],
      ),
    ],
  );
}
