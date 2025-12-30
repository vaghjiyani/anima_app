import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../utils/app_colors.dart';
import '../utils/responsive_helper.dart';
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  File? _profileImageFile;
  static const String _profileImagePathKey = 'profile_image_path';

  String _selectedGender = 'Male';
  final List<String> _genderOptions = ['Male', 'Female', 'Other'];

  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _nicknameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });

      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          throw Exception('No user logged in');
        }

        // Update display name in Firebase Auth
        await user.updateDisplayName(_fullNameController.text);

        // Save to Firestore (primary storage)
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'email': user.email,
          'fullName': _fullNameController.text.trim(),
          'nickname': _nicknameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'gender': _selectedGender,
          'profileImagePath': _profileImageFile?.path ?? '',
          'updatedAt': FieldValue.serverTimestamp(),
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true)); // merge = update existing fields only

        // Also save to SharedPreferences as backup (for offline access)
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_nickname', _nicknameController.text);
        await prefs.setString('user_phone', _phoneController.text);
        await prefs.setString('user_gender', _selectedGender);
        await prefs.setString('user_fullname', _fullNameController.text);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Profile saved to cloud!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Error: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSaving = false;
          });
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadSavedProfileImage();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Set email (always from Firebase Auth)
      setState(() {
        _emailController.text = user.email ?? '';
      });

      // Try to load from Firestore first
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          setState(() {
            _fullNameController.text =
                data['fullName'] ?? user.displayName ?? '';
            _nicknameController.text = data['nickname'] ?? '';
            _phoneController.text = data['phone'] ?? '';
            _selectedGender = data['gender'] ?? 'Male';
          });

          // Also save to SharedPreferences for offline access
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_fullname', data['fullName'] ?? '');
          await prefs.setString('user_nickname', data['nickname'] ?? '');
          await prefs.setString('user_phone', data['phone'] ?? '');
          await prefs.setString('user_gender', data['gender'] ?? 'Male');
        } else {
          // No Firestore data, try SharedPreferences
          await _loadFromSharedPreferences(user);
        }
      } catch (e) {
        // Firestore failed, use SharedPreferences
        await _loadFromSharedPreferences(user);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading profile: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadFromSharedPreferences(User user) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _fullNameController.text =
          prefs.getString('user_fullname') ?? user.displayName ?? '';
      _nicknameController.text = prefs.getString('user_nickname') ?? '';
      _phoneController.text = prefs.getString('user_phone') ?? '';
      _selectedGender = prefs.getString('user_gender') ?? 'Male';
    });
  }

  Future<void> _loadSavedProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString(_profileImagePathKey);
    if (path != null && path.isNotEmpty) {
      final file = File(path);
      if (await file.exists()) {
        setState(() {
          _profileImageFile = file;
        });
      }
    }
  }

  Future<void> _pickAndSaveProfileImage() async {
    final ImagePicker picker = ImagePicker();
    XFile? picked;

    // Check if running on desktop (Windows, macOS, Linux)
    final isDesktop =
        Platform.isWindows || Platform.isMacOS || Platform.isLinux;

    if (isDesktop) {
      // On desktop, directly pick from files
      picked = await picker.pickImage(source: ImageSource.gallery);
    } else {
      // On mobile, show dialog to choose camera or gallery
      final source = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Choose Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
            ],
          ),
        ),
      );

      if (source == null) return;
      picked = await picker.pickImage(source: source);
    }

    if (picked == null) return;

    final file = File(picked.path);
    if (!await file.exists()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load image'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      _profileImageFile = file;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileImagePathKey, file.path);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile image updated!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Fill your Profile',
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: AppColors.themedPrimaryGradient(context),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              ResponsiveHelper.isDesktop(context) ? 32 : 16,
              20,
              ResponsiveHelper.isDesktop(context) ? 32 : 16,
              40,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: ResponsiveHelper.getMaxWidth(context),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 20),

                      // Profile Picture Section
                      Center(
                        child: Stack(
                          children: [
                            Container(
                              width: ResponsiveHelper.isDesktop(context)
                                  ? 150
                                  : 120,
                              height: ResponsiveHelper.isDesktop(context)
                                  ? 150
                                  : 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.grey[800]
                                    : Colors.white.withOpacity(0.9),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: _profileImageFile != null
                                    ? Image.file(
                                        _profileImageFile!,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                      )
                                    : Icon(
                                        Icons.person,
                                        size:
                                            ResponsiveHelper.isDesktop(context)
                                            ? 80
                                            : 60,
                                        color:
                                            Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white70
                                            : Colors.black54,
                                      ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: InkWell(
                                onTap: _pickAndSaveProfileImage,
                                borderRadius: BorderRadius.circular(999),
                                child: Container(
                                  width: ResponsiveHelper.isDesktop(context)
                                      ? 44
                                      : 36,
                                  height: ResponsiveHelper.isDesktop(context)
                                      ? 44
                                      : 36,
                                  decoration: BoxDecoration(
                                    color: Colors.green[400],
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 3,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: ResponsiveHelper.isDesktop(context)
                                        ? 24
                                        : 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(
                        height: ResponsiveHelper.isDesktop(context) ? 40 : 30,
                      ),

                      // Full Name Field
                      _ProfileTextField(
                        controller: _fullNameController,
                        label: 'Full Name',
                        hint: 'Enter your full name',
                        prefixIcon: Icons.person_outline,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your full name';
                          }
                          return null;
                        },
                      ),

                      SizedBox(
                        height: ResponsiveHelper.isDesktop(context) ? 20 : 16,
                      ),

                      // Nickname Field
                      _ProfileTextField(
                        controller: _nicknameController,
                        label: 'Nickname',
                        hint: 'Enter your nickname',
                        prefixIcon: Icons.alternate_email,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your nickname';
                          }
                          return null;
                        },
                      ),

                      SizedBox(
                        height: ResponsiveHelper.isDesktop(context) ? 20 : 16,
                      ),

                      // Email Field (Read-only)
                      _ProfileTextField(
                        controller: _emailController,
                        label: 'Email',
                        hint: 'Your email address',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        readOnly: true,
                        validator: null,
                      ),

                      SizedBox(
                        height: ResponsiveHelper.isDesktop(context) ? 20 : 16,
                      ),

                      // Account Created Date
                      Text(
                        'Account Created',
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                            context,
                            16,
                          ),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(
                        height: ResponsiveHelper.isDesktop(context) ? 12 : 8,
                      ),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveHelper.isDesktop(context)
                              ? 20
                              : 16,
                          vertical: ResponsiveHelper.isDesktop(context)
                              ? 16
                              : 12,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[800]!.withOpacity(0.5)
                              : Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.white.withOpacity(0.2)
                                : Colors.black.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white70
                                  : Colors.black54,
                              size: ResponsiveHelper.getIconSize(context, 24),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              AuthService.currentUser?.metadata.creationTime !=
                                      null
                                  ? '${AuthService.currentUser!.metadata.creationTime!.day}/${AuthService.currentUser!.metadata.creationTime!.month}/${AuthService.currentUser!.metadata.creationTime!.year}'
                                  : 'Unknown',
                              style: TextStyle(
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                                fontSize:
                                    ResponsiveHelper.getResponsiveFontSize(
                                      context,
                                      16,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(
                        height: ResponsiveHelper.isDesktop(context) ? 20 : 16,
                      ),

                      // Phone Number Field
                      _ProfileTextField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        hint: 'Enter your phone number',
                        prefixIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your phone number';
                          }
                          return null;
                        },
                      ),

                      SizedBox(
                        height: ResponsiveHelper.isDesktop(context) ? 20 : 16,
                      ),

                      // Gender Selection
                      Text(
                        'Gender',
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                            context,
                            16,
                          ),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(
                        height: ResponsiveHelper.isDesktop(context) ? 12 : 8,
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveHelper.isDesktop(context)
                              ? 20
                              : 16,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[800]!.withOpacity(0.5)
                              : Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.white.withOpacity(0.2)
                                : Colors.black.withOpacity(0.2),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedGender,
                            isExpanded: true,
                            dropdownColor:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey[800]
                                : Colors.white,
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white70
                                  : Colors.black54,
                              size: ResponsiveHelper.getIconSize(context, 24),
                            ),
                            items: _genderOptions.map((String gender) {
                              return DropdownMenuItem<String>(
                                value: gender,
                                child: Text(
                                  gender,
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize:
                                        ResponsiveHelper.getResponsiveFontSize(
                                          context,
                                          16,
                                        ),
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _selectedGender = newValue;
                                });
                              }
                            },
                          ),
                        ),
                      ),

                      SizedBox(
                        height: ResponsiveHelper.isDesktop(context) ? 50 : 40,
                      ),

                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        height: ResponsiveHelper.getButtonHeight(context),
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[400],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            elevation: 8,
                            shadowColor: Colors.black.withOpacity(0.3),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'Save Profile',
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
    );
  }
}

class _ProfileTextField extends StatelessWidget {
  const _ProfileTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.readOnly = false,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData prefixIcon;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: ResponsiveHelper.isDesktop(context) ? 12 : 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          readOnly: readOnly,
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white70
                  : Colors.black.withOpacity(0.6),
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
            ),
            prefixIcon: Icon(
              prefixIcon,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white70
                  : Colors.black54,
              size: ResponsiveHelper.getIconSize(context, 24),
            ),
            filled: true,
            fillColor: readOnly
                ? (Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[700]!.withOpacity(0.3)
                      : Colors.grey.withOpacity(0.3))
                : (Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[800]!.withOpacity(0.5)
                      : Colors.white.withOpacity(0.9)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white24
                    : Colors.black.withOpacity(0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white24
                    : Colors.black.withOpacity(0.3),
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
}
