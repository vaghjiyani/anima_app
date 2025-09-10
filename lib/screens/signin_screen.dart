import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/responsive_helper.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';
import 'home_page.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _obscurePassword = true;

  // Demo credentials (hardcoded)
  static const String _demoEmail = 'user@example.com';
  static const String _demoPassword = 'Password123';

  @override
  void initState() {
    super.initState();
    // Prefill demo credentials for convenience
    _emailController.text = _demoEmail;
    _passwordController.text = _demoPassword;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signIn() {
    FocusScope.of(context).unfocus();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppColors.primaryGradientDecoration,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: ResponsiveHelper.getResponsivePadding(context),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: ResponsiveHelper.getMaxWidth(context),
                  minHeight:
                      MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: IntrinsicHeight(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Back button
                        Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 10),
                          child: IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(
                              Icons.arrow_back_ios,
                              color: Colors.white,
                              size: ResponsiveHelper.getIconSize(context, 24),
                            ),
                          ),
                        ),

                        // Logo
                        Center(
                          child: Container(
                            width: ResponsiveHelper.isDesktop(context)
                                ? 100
                                : 80,
                            height: ResponsiveHelper.isDesktop(context)
                                ? 100
                                : 80,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/Logo.png',
                                width: ResponsiveHelper.isDesktop(context)
                                    ? 100
                                    : 80,
                                height: ResponsiveHelper.isDesktop(context)
                                    ? 100
                                    : 80,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: ResponsiveHelper.isDesktop(context)
                                        ? 100
                                        : 80,
                                    height: ResponsiveHelper.isDesktop(context)
                                        ? 100
                                        : 80,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.image,
                                      size: ResponsiveHelper.isDesktop(context)
                                          ? 50
                                          : 40,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),

                        SizedBox(
                          height: ResponsiveHelper.isDesktop(context) ? 20 : 15,
                        ),

                        // Title
                        Center(
                          child: Text(
                            "Welcome Back",
                            style: TextStyle(
                              fontSize: ResponsiveHelper.getResponsiveFontSize(
                                context,
                                28,
                              ),
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),

                        SizedBox(
                          height: ResponsiveHelper.isDesktop(context) ? 8 : 5,
                        ),

                        Center(
                          child: Text(
                            "Sign in to continue",
                            style: TextStyle(
                              fontSize: ResponsiveHelper.getResponsiveFontSize(
                                context,
                                14,
                              ),
                              color: Colors.black54,
                            ),
                          ),
                        ),

                        SizedBox(
                          height: ResponsiveHelper.isDesktop(context) ? 30 : 20,
                        ),

                        // Email field
                        _buildTextField(
                          controller: _emailController,
                          label: "Email",
                          hint: "Enter your email",
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.email_outlined,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(
                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                            ).hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),

                        SizedBox(
                          height: ResponsiveHelper.isDesktop(context) ? 16 : 12,
                        ),

                        // Password field
                        _buildTextField(
                          controller: _passwordController,
                          label: "Password",
                          hint: "Enter your password",
                          obscureText: _obscurePassword,
                          prefixIcon: Icons.lock_outlined,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.black54,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 12),

                        // Remember me and Forgot password
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: _rememberMe,
                                  onChanged: (value) {
                                    setState(() {
                                      _rememberMe = value ?? false;
                                    });
                                  },
                                  activeColor: Colors.green[400],
                                  checkColor: Colors.white,
                                ),
                                const Text(
                                  "Remember me",
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ForgotPasswordScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                "Forgot Password?",
                                style: TextStyle(
                                  color: Colors.green[400],
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Sign in button
                        SizedBox(
                          width: double.infinity,
                          height: ResponsiveHelper.getButtonHeight(context),
                          child: ElevatedButton(
                            onPressed: _signIn,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[400],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                              elevation: 8,
                              shadowColor: Colors.black.withValues(alpha: 0.3),
                            ),
                            child: Text(
                              "Sign In",
                              style: TextStyle(
                                fontSize:
                                    ResponsiveHelper.getResponsiveFontSize(
                                      context,
                                      18,
                                    ),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 15),

                        // Sign up link
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Don't have an account? ",
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 16,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const SignupScreen(),
                                    ),
                                  );
                                },
                                child: Text(
                                  "Sign up",
                                  style: TextStyle(
                                    color: Colors.green[400],
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Or divider
                        const Center(
                          child: Text(
                            "or",
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 16,
                            ),
                          ),
                        ),

                        const SizedBox(height: 15),

                        // Social login icons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildIconButton(
                              iconPath: 'assets/icons/facebook.png',
                              fallbackIcon: Icons.facebook,
                              onTap: () {},
                            ),
                            const SizedBox(width: 20),
                            _buildIconButton(
                              iconPath: 'assets/icons/google.png',
                              fallbackIcon: Icons.g_mobiledata,
                              onTap: () {},
                            ),
                            const SizedBox(width: 20),
                            _buildIconButton(
                              iconPath: 'assets/icons/apple.png',
                              fallbackIcon: Icons.apple,
                              onTap: () {},
                            ),
                          ],
                        ),

                        SizedBox(
                          height: ResponsiveHelper.isDesktop(context) ? 30 : 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefixIcon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.black,
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: ResponsiveHelper.isDesktop(context) ? 12 : 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          style: TextStyle(
            color: Colors.black,
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.black.withValues(alpha: 0.6),
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
            ),
            prefixIcon: Icon(
              prefixIcon,
              color: Colors.black54,
              size: ResponsiveHelper.getIconSize(context, 24),
            ),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.black.withValues(alpha: 0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.black.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.green[400]!, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: ResponsiveHelper.isDesktop(context) ? 20 : 16,
              vertical: ResponsiveHelper.isDesktop(context) ? 16 : 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIconButton({
    required String iconPath,
    required IconData fallbackIcon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(child: _buildIcon(iconPath, fallbackIcon)),
      ),
    );
  }

  Widget _buildIcon(String iconPath, IconData fallbackIcon) {
    return Image.asset(
      iconPath,
      width: 24,
      height: 24,
      errorBuilder: (context, error, stackTrace) {
        return Icon(fallbackIcon, size: 24, color: Colors.black54);
      },
    );
  }
}
