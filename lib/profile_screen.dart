import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/database_helper.dart';
import 'package:myapp/utils/screen_utils.dart';
import 'package:myapp/utils/size.dart';
import 'package:myapp/utils/style.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';

class ProfileScreen extends StatefulWidget {
  final String? email;
  const ProfileScreen({Key? key, required this.email}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _userData;
  File? _imageFile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (widget.email != null) {
      final dbHelper = DatabaseHelper();
      final user = await dbHelper.getUserByEmail(widget.email!);
      setState(() {
        _userData = user;
        if (user != null && user['profile_image'] != null) {
          _imageFile = File(user['profile_image']);
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        final dbHelper = DatabaseHelper();
        await dbHelper.updateProfileImage(widget.email!, pickedFile.path);

        setState(() {
          _imageFile = File(pickedFile.path);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Profile picture updated successfully!',
                style: TahuraTextStyles.bodyText.copyWith(color: Colors.white),
              ),
              backgroundColor: TahuraColors.success,
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
              'Failed to update profile picture. Please try again.',
              style: TahuraTextStyles.bodyText.copyWith(color: Colors.white),
            ),
            backgroundColor: TahuraColors.error,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(Sizes.medium),
          ),
        );
      }
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
          'Profil Saya',
          style: TahuraTextStyles.appBarTitle,
        )
            .animate()
            .fadeIn(duration: TahuraAnimations.medium)
            .slideX(begin: -0.2, end: 0),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                  context, '/login', (route) => false);
            },
          )
              .animate()
              .fadeIn(duration: TahuraAnimations.medium)
              .slideX(begin: 0.2, end: 0),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'C:/Users/Nikolaus Franz/Documents/tahura_project/lib/assets/screen.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: _isLoading ? _buildLoadingState() : _buildProfileContent(),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: ScreenUtils.getResponsiveWidth(15),
            ),
            SizedBox(height: Sizes.large),
            Container(
              width: ScreenUtils.getResponsiveWidth(60),
              height: Sizes.medium,
              color: Colors.white,
            ),
            SizedBox(height: Sizes.medium),
            Container(
              width: ScreenUtils.getResponsiveWidth(40),
              height: Sizes.medium,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildProfileImage()
              .animate()
              .fadeIn(duration: TahuraAnimations.medium)
              .scale(),
          SizedBox(height: Sizes.large),
          _buildProfileInfo()
              .animate()
              .fadeIn(duration: TahuraAnimations.medium)
              .slideY(begin: 0.2, end: 0),
          SizedBox(height: Sizes.large),
          _buildEditButton()
              .animate()
              .fadeIn(duration: TahuraAnimations.medium)
              .slideY(begin: 0.3, end: 0),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    return Stack(
      children: [
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: TahuraShadows.medium,
            ),
            child: CircleAvatar(
              radius: ScreenUtils.getResponsiveWidth(15),
              backgroundColor: Colors.white.withOpacity(0.3),
              backgroundImage: _imageFile != null
                  ? FileImage(_imageFile!)
                  : AssetImage(
                          'C:/Users/Nikolaus Franz/Documents/tahura_project/lib/assets/pp.png')
                      as ImageProvider,
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            padding: EdgeInsets.all(Sizes.xsmall),
            decoration: BoxDecoration(
              color: TahuraColors.primary,
              shape: BoxShape.circle,
              boxShadow: TahuraShadows.small,
            ),
            child: Icon(
              Icons.camera_alt,
              color: Colors.white,
              size: Sizes.iconMedium,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileInfo() {
    return Column(
      children: [
        _buildInfoCard(
          'Nama',
          _userData!['name'] ?? 'Tidak ada nama',
          Icons.person,
        ),
        SizedBox(height: Sizes.medium),
        _buildInfoCard(
          'Email',
          _userData!['email'] ?? 'Tidak ada email',
          Icons.email,
        ),
      ],
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: Sizes.large),
      padding: EdgeInsets.all(Sizes.medium),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(Sizes.radiusMedium),
        boxShadow: TahuraShadows.small,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: Sizes.iconLarge,
          ),
          SizedBox(width: Sizes.medium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TahuraTextStyles.bodyText.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: Sizes.xsmall),
                Text(
                  value,
                  style: TahuraTextStyles.bodyTextSecondary,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditButton() {
    return ElevatedButton.icon(
      onPressed: _pickImage,
      style: TahuraButtons.primaryButton,
      icon: Icon(Icons.edit, size: Sizes.iconMedium),
      label: Text(
        'Ubah Foto Profil',
        style: TahuraTextStyles.buttonText,
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      backgroundColor: Colors.black,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white54,
      currentIndex: 0,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profil',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map),
          label: 'Peta',
        ),
      ],
      onTap: (index) {
        if (index == 1) {
          Navigator.pushReplacementNamed(context, '/home',
              arguments: widget.email);
        } else if (index == 2) {
          Navigator.pushNamed(context, '/map');
        }
      },
    );
  }
}
