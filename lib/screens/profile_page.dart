import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../utils/app_colors.dart';
import '../utils/responsive_helper.dart';
import '../services/auth_service.dart';

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
      try {
        final user = AuthService.currentUser;
        if (user != null) {
          await user.updateDisplayName(_fullNameController.text);

          // Save additional profile data to SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_nickname', _nicknameController.text);
          await prefs.setString('user_phone', _phoneController.text);
          await prefs.setString('user_gender', _selectedGender);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile saved successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to save profile: $e'),
              backgroundColor: Colors.red,
            ),
          );
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

  void _loadUserData() {
    final user = AuthService.currentUser;
    if (user != null) {
      setState(() {
        _emailController.text = user.email ?? '';
        _fullNameController.text = user.displayName ?? '';
      });
    }
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

    // Load additional profile data
    final nickname = prefs.getString('user_nickname');
    final phone = prefs.getString('user_phone');
    final gender = prefs.getString('user_gender');

    if (nickname != null) _nicknameController.text = nickname;
    if (phone != null) _phoneController.text = phone;
    if (gender != null) _selectedGender = gender;
  }

  Future<void> _pickAndSaveProfileImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final file = File(picked.path);
    if (!await file.exists()) return;

    setState(() {
      _profileImageFile = file;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileImagePathKey, file.path);
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
                          onPressed: _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[400],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            elevation: 8,
                            shadowColor: Colors.black.withOpacity(0.3),
                          ),
                          child: Text(
                            'Save Profile',
                            style: TextStyle(
                              fontSize: ResponsiveHelper.getResponsiveFontSize(
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
