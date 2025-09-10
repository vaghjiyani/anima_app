import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_colors.dart';
import 'create_new_password_screen.dart';

class VerificationCodeScreen extends StatefulWidget {
  const VerificationCodeScreen({
    super.key,
    this.destination = '+1 111 ******99',
  });

  final String destination;

  @override
  State<VerificationCodeScreen> createState() => _VerificationCodeScreenState();
}

class _VerificationCodeScreenState extends State<VerificationCodeScreen> {
  final int _codeLength = 4;
  final List<TextEditingController> _controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  Timer? _timer;
  int _secondsRemaining = 55;
  bool _resending = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsRemaining = 55);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining <= 1) {
        timer.cancel();
        setState(() {});
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  Future<void> _resendCode() async {
    if (_secondsRemaining > 0 || _resending) return;
    setState(() => _resending = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _resending = false);
    _startTimer();
  }

  void _onChanged(int index, String value) {
    if (value.isNotEmpty) {
      if (index < _codeLength - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    }
  }

  String get _enteredCode => _controllers.map((e) => e.text).join();

  void _verify() {
    if (_enteredCode.length == _codeLength) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CreateNewPasswordScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the full code.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppColors.primaryGradientDecoration,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),

                  const Text(
                    'Forgot Password',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Code has been sent to ${widget.destination}',
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(_codeLength, (index) {
                      return _CodeBox(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        onChanged: (v) => _onChanged(index, v),
                      );
                    }),
                  ),

                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Resend code in ',
                        style: TextStyle(color: Colors.black54),
                      ),
                      GestureDetector(
                        onTap: _resendCode,
                        child: Text(
                          _secondsRemaining > 0
                              ? '$_secondsRemaining s'
                              : (_resending ? 'sending...' : 'Resend'),
                          style: TextStyle(
                            color: Colors.green[400],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _verify,
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
                        'Verify',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
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
      ),
    );
  }
}

class _CodeBox extends StatelessWidget {
  const _CodeBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 16 * 2 - 24 * 3) / 4,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        maxLength: 1,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: onChanged,
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: Colors.white.withOpacity(0.85),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.black.withOpacity(0.2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.green[400]!, width: 2),
          ),
        ),
      ),
    );
  }
}
