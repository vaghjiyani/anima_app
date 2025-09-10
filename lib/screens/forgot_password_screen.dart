import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'verification_code_screen.dart';

enum RecoveryMethod { phone, email }

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with TickerProviderStateMixin {
  RecoveryMethod _selected = RecoveryMethod.phone;
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  // Add animations for option cards
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _buttonAnimation;

  // Button press animation controller
  late final AnimationController _buttonPressController;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
          ),
        );

    // Initialize new animations
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _buttonAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.elasticOut),
      ),
    );

    // Initialize button press animation controller
    _buttonPressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Button press tween is applied where needed via the controller if required

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _buttonPressController.dispose();
    super.dispose();
  }

  void _onContinue() {
    // Use the pre-initialized button press animation controller
    _buttonPressController.forward().then((_) {
      _buttonPressController.reverse().then((_) {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const VerificationCodeScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  var curve = Curves.easeInOut;
                  var curveTween = CurveTween(curve: curve);
                  var fadeAnimation = Tween<double>(
                    begin: 0.0,
                    end: 1.0,
                  ).animate(animation.drive(curveTween));

                  var slideAnimation = Tween<Offset>(
                    begin: const Offset(0.05, 0.0),
                    end: Offset.zero,
                  ).animate(animation.drive(curveTween));

                  return FadeTransition(
                    opacity: fadeAnimation,
                    child: SlideTransition(
                      position: slideAnimation,
                      child: child,
                    ),
                  );
                },
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 24),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: AppColors.primaryGradientDecoration,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: const Text(
                                'Forgot Password',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Select which contact details should we use to reset your password',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildOptionCard(
                              method: RecoveryMethod.phone,
                              icon: Icons.sms_outlined,
                              title: 'via SMS',
                              subtitle: '+1 111 ******99',
                            ),
                            const SizedBox(height: 12),
                            _buildOptionCard(
                              method: RecoveryMethod.email,
                              icon: Icons.email_outlined,
                              title: 'via Email',
                              subtitle: 'an**ley@yourdomain.com',
                            ),
                            const SizedBox(height: 24),
                            ScaleTransition(
                              scale: _buttonAnimation,
                              child: SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: _onContinue,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green[400],
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(28),
                                    ),
                                    elevation: 8,
                                    shadowColor: Colors.black.withOpacity(0.3),
                                  ),
                                  child: const Text(
                                    'Continue',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
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

  Widget _buildOptionCard({
    required RecoveryMethod method,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final bool isSelected = _selected == method;
    return InkWell(
      onTap: () => setState(() => _selected = method),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? Colors.green[400]!
                : Colors.black.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isSelected ? 0.15 : 0.08),
              blurRadius: isSelected ? 12 : 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.8, end: 1.0),
              duration: const Duration(milliseconds: 300),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: isSelected ? (value * 1.05) : value,
                  child: child,
                );
              },
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: (isSelected ? Colors.green[400] : Colors.grey[300])!,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isSelected ? Colors.white : Colors.black54,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: Radio<RecoveryMethod>(
                key: ValueKey<RecoveryMethod>(method),
                value: method,
                groupValue: _selected,
                activeColor: Colors.green[400],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selected = value);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
