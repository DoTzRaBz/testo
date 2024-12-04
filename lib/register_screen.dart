import 'package:flutter/material.dart';
import 'package:myapp/database_helper.dart';
import 'package:myapp/login_screen.dart';
import 'package:myapp/utils/screen_utils.dart';
import 'package:myapp/utils/size.dart';
import 'package:myapp/utils/style.dart';
import 'package:flutter_animate/flutter_animate.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final dbHelper = DatabaseHelper();
        final result = await dbHelper.insertUser(
          _nameController.text,
          _emailController.text,
          _passwordController.text,
        );

        if (mounted) {
          if (result > 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Registration successful!',
                  style:
                      TahuraTextStyles.bodyText.copyWith(color: Colors.white),
                ),
                backgroundColor: TahuraColors.success,
                behavior: SnackBarBehavior.floating,
                margin: EdgeInsets.all(Sizes.medium),
                duration: TahuraAnimations.slow,
              ),
            );
            Navigator.pop(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Registration failed. Please try again.',
                  style:
                      TahuraTextStyles.bodyText.copyWith(color: Colors.white),
                ),
                backgroundColor: TahuraColors.error,
                behavior: SnackBarBehavior.floating,
                margin: EdgeInsets.all(Sizes.medium),
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error: $e',
                style: TahuraTextStyles.bodyText.copyWith(color: Colors.white),
              ),
              backgroundColor: TahuraColors.error,
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.all(Sizes.medium),
            ),
          );
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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
                            height: ScreenUtils.getResponsiveHeight(15),
                          )
                              .animate()
                              .fadeIn(duration: TahuraAnimations.medium)
                              .scale(),

                          SizedBox(height: Sizes.large),

                          // Title
                          Text(
                            'Register',
                            style: TahuraTextStyles.screenTitle,
                          )
                              .animate()
                              .fadeIn(duration: TahuraAnimations.medium)
                              .slideY(begin: 0.3, end: 0),

                          SizedBox(height: Sizes.large),

                          // Name Field
                          TextFormField(
                            controller: _nameController,
                            decoration:
                                TahuraInputDecorations.defaultInput.copyWith(
                              labelText: 'Full Name',
                              prefixIcon: Icon(Icons.person,
                                  color: TahuraColors.primary),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your full name';
                              }
                              return null;
                            },
                          )
                              .animate()
                              .fadeIn(duration: TahuraAnimations.medium)
                              .slideX(begin: -0.2, end: 0),

                          SizedBox(height: Sizes.medium),

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
                              if (!value.contains('@gmail.com')) {
                                return 'Please use a Gmail address';
                              }
                              return null;
                            },
                          )
                              .animate()
                              .fadeIn(duration: TahuraAnimations.medium)
                              .slideX(begin: 0.2, end: 0),

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
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters long';
                              }
                              return null;
                            },
                          )
                              .animate()
                              .fadeIn(duration: TahuraAnimations.medium)
                              .slideX(begin: -0.2, end: 0),

                          SizedBox(height: Sizes.medium),

                          // Confirm Password Field
                          TextFormField(
                            controller: _confirmPasswordController,
                            decoration:
                                TahuraInputDecorations.defaultInput.copyWith(
                              labelText: 'Confirm Password',
                              prefixIcon: Icon(Icons.lock_outline,
                                  color: TahuraColors.primary),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: TahuraColors.primary,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword;
                                  });
                                },
                              ),
                            ),
                            obscureText: _obscureConfirmPassword,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please confirm your password';
                              }
                              if (value != _passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          )
                              .animate()
                              .fadeIn(duration: TahuraAnimations.medium)
                              .slideX(begin: 0.2, end: 0),

                          SizedBox(height: Sizes.large),

                          // Register Button
                          SizedBox(
                            width: double.infinity,
                            height: Sizes.buttonHeight,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _register,
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
                                  : Text('Register',
                                      style: TahuraTextStyles.buttonText),
                            ),
                          )
                              .animate()
                              .fadeIn(duration: TahuraAnimations.medium)
                              .slideY(begin: 0.2, end: 0),

                          SizedBox(height: Sizes.medium),

                          // Login Link
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Already have an account? Login here.',
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
