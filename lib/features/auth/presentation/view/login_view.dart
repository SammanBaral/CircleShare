import 'package:circle_share/core/common/snackbar/my_snackbar.dart';
import 'package:circle_share/features/auth/presentation/view/register_view.dart';
import 'package:circle_share/features/auth/presentation/view_model/login/login_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginView extends StatelessWidget {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController =
      TextEditingController(text: '');
  final TextEditingController _passwordController =
      TextEditingController(text: '');

  LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive layout
    final Size screenSize = MediaQuery.of(context).size;
    final bool isTablet = screenSize.width > 600;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isTablet ? 600 : screenSize.width,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  // Smaller padding for phones, larger for tablets
                  horizontal: isTablet ? 48.0 : 24.0,
                  vertical: 16.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLogoSection(isTablet),
                    SizedBox(height: isTablet ? 48 : 32),
                    _buildLoginForm(context, isTablet),
                    const SizedBox(height: 16),
                    _buildSignupSection(context, isTablet),
                    const SizedBox(height: 16),
                    _buildSocialLoginSection(isTablet),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection(bool isTablet) {
    return Column(
      children: [
        Image.asset(
          'assets/images/circle_logo.png',
          height: isTablet ? 200 : 150,
          width: isTablet ? 200 : 150,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isTablet ? 48.0 : 24.0),
          child: Text(
            "Share and borrow items in your community",
            style: TextStyle(
              fontSize: isTablet ? 18 : 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm(BuildContext context, bool isTablet) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Login",
                style: TextStyle(
                  fontFamily: 'Montserrat Bold',
                  fontSize: isTablet ? 26 : 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: isTablet ? 24 : 16),
              _buildUsernameField(),
              SizedBox(height: isTablet ? 24 : 16),
              _buildPasswordField(),
              SizedBox(height: isTablet ? 24 : 16),
              _buildLoginButton(context, isTablet),
              const SizedBox(height: 8),
              _buildForgotPasswordButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUsernameField() {
    return TextFormField(
      controller: _usernameController,
      decoration: InputDecoration(
        labelText: "Username",
        hintText: "Enter your username",
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 16.0,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Username cannot be empty";
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: true,
      decoration: InputDecoration(
        labelText: "Password",
        hintText: "Enter your password",
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 16.0,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Password cannot be empty";
        } else if (value.length < 6) {
          return "Password must be at least 6 characters long";
        }
        return null;
      },
    );
  }

  Widget _buildLoginButton(BuildContext context, bool isTablet) {
    return ElevatedButton(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          // Trigger login logic through the bloc or API here
          context.read<LoginBloc>().add(LoginUserEvent(
                context: context,
                username: _usernameController.text,
                password: _passwordController.text,
              ));
        } else {
          showMySnackBar(
            context: context,
            message: "Please correct errors in the form",
            color: Colors.red,
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.symmetric(
          vertical: isTablet ? 20.0 : 16.0,
        ),
      ),
      child: Text(
        "Login",
        style: TextStyle(
          fontSize: isTablet ? 18 : 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildForgotPasswordButton(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () {
          // TODO: Implement forgot password functionality
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Forgot password functionality not implemented yet'),
            ),
          );
        },
        child: Text(
          "Forgot password?",
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildSignupSection(BuildContext context, bool isTablet) {
    return Column(
      children: [
        Text(
          "Don't have an account?",
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: isTablet ? 16 : 14,
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RegisterView()),
            );
          },
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.black),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.symmetric(
              vertical: isTablet ? 16.0 : 12.0,
              horizontal: isTablet ? 48.0 : 24.0,
            ),
          ),
          child: Text(
            "Sign Up",
            style: TextStyle(
              color: Colors.black,
              fontSize: isTablet ? 18 : 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialLoginSection(bool isTablet) {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: Divider(thickness: 1)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                "Or continue with",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: isTablet ? 16 : 14,
                ),
              ),
            ),
            const Expanded(child: Divider(thickness: 1)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialButton(Icons.g_translate, isTablet),
            _buildSocialButton(Icons.facebook, isTablet),
            _buildSocialButton(Icons.apple, isTablet),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton(IconData icon, bool isTablet) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
      ),
      child: IconButton(
        onPressed: () {
          // Social login functionality would go here
        },
        icon: Icon(icon),
        iconSize: isTablet ? 40 : 32,
        padding: EdgeInsets.all(isTablet ? 16.0 : 12.0),
      ),
    );
  }
}
