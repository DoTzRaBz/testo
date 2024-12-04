import 'package:flutter/material.dart';
import 'package:myapp/database_helper.dart';
import 'package:myapp/utils/size.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/utils/screen_utils.dart';
import 'package:myapp/utils/style.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final dbHelper = DatabaseHelper();
      final email = _emailController.text;
      final password = _passwordController.text;

      try {
        final isValidUser = await dbHelper.loginUser(email, password);
        if (isValidUser) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('userEmail', email);

          final userRole = await dbHelper.getUserRole(email);

          if (mounted) {
            Navigator.pushReplacementNamed(context, '/home', arguments: email);
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Invalid email or password.',
                  style: TahuraTextStyles.bodyText,
                ),
                backgroundColor: TahuraColors.error,
                behavior: SnackBarBehavior.floating,
                margin: EdgeInsets.all(Sizes.medium),
              ),
            );
          }
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'C:/Users/Nikolaus Franz/Documents/tahura_project/lib/assets/screen.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(Sizes.medium),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Sizes.radiusLarge),
                  ),
                  color: Colors.white.withOpacity(0.9),
                  child: Padding(
                    padding: EdgeInsets.all(Sizes.large),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Logo
                          Image.asset(
                            'C:/Users/Nikolaus Franz/Documents/tahura_project/lib/assets/tahura.png',
                            height: ScreenUtils.getResponsiveHeight(
                                20), // 20% of screen height
                          )
                              .animate()
                              .fadeIn(duration: TahuraAnimations.medium)
                              .scale(),

                          SizedBox(height: Sizes.large),

                          // Title
                          Text(
                            'Login',
                            style: TahuraTextStyles.screenTitle,
                          )
                              .animate()
                              .fadeIn(duration: TahuraAnimations.medium)
                              .slideY(begin: 0.3, end: 0),

                          SizedBox(height: Sizes.large),

                          // Email Field
                          TextFormField(
                            controller: _emailController,
                            decoration:
                                TahuraInputDecorations.defaultInput.copyWith(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email,
                                  color: TahuraColors.primary),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              return null;
                            },
                          )
                              .animate()
                              .fadeIn(duration: TahuraAnimations.medium)
                              .slideX(begin: -0.2, end: 0),

                          SizedBox(height: Sizes.medium),

                          // Password Field
                          TextFormField(
                            controller: _passwordController,
                            decoration:
                                TahuraInputDecorations.defaultInput.copyWith(
                              labelText: 'Password',
                              prefixIcon:
                                  Icon(Icons.lock, color: TahuraColors.primary),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: TahuraColors.primary,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            obscureText: _obscurePassword,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                          )
                              .animate()
                              .fadeIn(duration: TahuraAnimations.medium)
                              .slideX(begin: 0.2, end: 0),

                          SizedBox(height: Sizes.large),

                          // Login Button
                          SizedBox(
                            width: double.infinity,
                            height: Sizes.buttonHeight,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _login,
                              style: TahuraButtons.primaryButton,
                              child: _isLoading
                                  ? SizedBox(
                                      height: Sizes.iconMedium,
                                      width: Sizes.iconMedium,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text('Login',
                                      style: TahuraTextStyles.buttonText),
                            ),
                          )
                              .animate()
                              .fadeIn(duration: TahuraAnimations.medium)
                              .slideY(begin: 0.2, end: 0),

                          SizedBox(height: Sizes.medium),

                          // Register Link
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/register');
                            },
                            child: Text(
                              'Don\'t have an account? Register',
                              style: TahuraTextStyles.linkText,
                            ),
                          ).animate().fadeIn(duration: TahuraAnimations.medium),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
