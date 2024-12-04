import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/edit_faq_screen.dart';
import 'package:myapp/utils/screen_utils.dart';
import 'package:myapp/utils/size.dart';
import 'package:myapp/utils/style.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HomeStaff extends StatefulWidget {
  const HomeStaff({Key? key}) : super(key: key);

  @override
  _HomeStaffState createState() => _HomeStaffState();
}

class _HomeStaffState extends State<HomeStaff> {
  final List<StaffMenuItem> _menuItems = [
    StaffMenuItem(
      title: 'Interactive Map',
      description: 'View and manage location points',
      icon: Icons.map,
      route: '/map',
      color: Colors.blue,
    ),
    StaffMenuItem(
      title: 'Manage POI',
      description: 'Add or edit points of interest',
      icon: Icons.place,
      route: '/manage_poi',
      color: Colors.green,
    ),
    StaffMenuItem(
      title: 'FAQ Management',
      description: 'Update frequently asked questions',
      icon: Icons.question_answer,
      route: '/faq',
      color: Colors.orange,
    ),
    StaffMenuItem(
      title: 'System Dashboard',
      description: 'Monitor system performance',
      icon: Icons.dashboard,
      route: '/dashboard',
      color: Colors.purple,
    ),
    StaffMenuItem(
      title: 'Content Updates',
      description: 'Manage site content and media',
      icon: Icons.edit,
      route: '/update_content',
      color: Colors.red,
    ),
    StaffMenuItem(
      title: 'Tour Packages',
      description: 'Manage tour packages and pricing',
      icon: Icons.card_travel,
      route: '/manage_tour',
      color: Colors.teal,
    ),
    StaffMenuItem(
      title: 'Analytics',
      description: 'View visitor statistics and reports',
      icon: Icons.analytics,
      route: '/analytics',
      color: Colors.indigo,
    ),
    StaffMenuItem(
      title: 'Reports',
      description: 'Generate and view system reports',
      icon: Icons.summarize,
      route: '/report',
      color: Colors.brown,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Staff Dashboard',
          style: TahuraTextStyles.appBarTitle,
        )
            .animate()
            .fadeIn(duration: TahuraAnimations.medium)
            .slideX(begin: -0.2, end: 0),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () => _showLogoutConfirmation(context),
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
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.all(Sizes.medium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeCard(),
                SizedBox(height: Sizes.large),
                _buildQuickStats(),
                SizedBox(height: Sizes.large),
                Text(
                  'Management Menu',
                  style: TahuraTextStyles.screenTitle,
                )
                    .animate()
                    .fadeIn(duration: TahuraAnimations.medium)
                    .slideY(begin: 0.2, end: 0),
                SizedBox(height: Sizes.medium),
                _buildMenuGrid(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: EdgeInsets.all(Sizes.large),
      decoration: BoxDecoration(
        color: TahuraColors.primary.withOpacity(0.9),
        borderRadius: BorderRadius.circular(Sizes.radiusLarge),
        boxShadow: TahuraShadows.medium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome Back, Staff!',
            style: TahuraTextStyles.screenTitle.copyWith(
              fontSize: Sizes.fontXXLarge,
            ),
          ),
          SizedBox(height: Sizes.small),
          Text(
            'Manage and monitor Tahura activities',
            style: TahuraTextStyles.bodyText,
          ),
        ],
      ),
    ).animate().fadeIn(duration: TahuraAnimations.medium).scale();
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        _buildStatCard(
          'Active Users',
          '1,234',
          Icons.people,
          Colors.blue,
        ),
        SizedBox(width: Sizes.medium),
        _buildStatCard(
          'Today\'s Visits',
          '156',
          Icons.visibility,
          Colors.green,
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(Sizes.medium),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(Sizes.radiusMedium),
          boxShadow: TahuraShadows.small,
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(Sizes.small),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(Sizes.radiusSmall),
              ),
              child: Icon(icon, color: color),
            ),
            SizedBox(width: Sizes.medium),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TahuraTextStyles.screenTitle.copyWith(
                    color: Colors.black,
                    fontSize: Sizes.fontLarge,
                  ),
                ),
                Text(
                  title,
                  style: TahuraTextStyles.bodyText.copyWith(
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: TahuraAnimations.medium)
        .slideY(begin: 0.2, end: 0);
  }

  Widget _buildMenuGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: Sizes.medium,
        mainAxisSpacing: Sizes.medium,
        childAspectRatio: 1,
      ),
      itemCount: _menuItems.length,
      itemBuilder: (context, index) => _buildMenuItem(_menuItems[index], index),
    );
  }

  Widget _buildMenuItem(StaffMenuItem item, int index) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Sizes.radiusMedium),
      ),
      child: InkWell(
        onTap: () => _handleMenuItemTap(item),
        borderRadius: BorderRadius.circular(Sizes.radiusMedium),
        child: Container(
          padding: EdgeInsets.all(Sizes.medium),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                item.color.withOpacity(0.8),
                item.color.withOpacity(0.6),
              ],
            ),
            borderRadius: BorderRadius.circular(Sizes.radiusMedium),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                item.icon,
                size: Sizes.iconXLarge,
                color: Colors.white,
              ),
              SizedBox(height: Sizes.medium),
              Text(
                item.title,
                style: TahuraTextStyles.bodyText.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: Sizes.small),
              Text(
                item.description,
                style: TahuraTextStyles.bodyText.copyWith(
                  fontSize: Sizes.fontSmall,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(
          duration: TahuraAnimations.medium,
          delay: Duration(milliseconds: 100 * index),
        )
        .scale();
  }

  void _handleMenuItemTap(StaffMenuItem item) {
    if (item.route == '/faq') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditFAQScreen(
            onUpdate: (question, answer) {
              // Handle FAQ update
            },
          ),
        ),
      );
    } else {
      Navigator.pushNamed(context, item.route);
    }
  }

  Future<void> _showLogoutConfirmation(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Confirm Logout',
          style: TahuraTextStyles.screenTitle.copyWith(color: Colors.black),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TahuraTextStyles.bodyText.copyWith(color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: TahuraTextStyles.bodyText.copyWith(
                color: TahuraColors.primary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Logout',
              style: TahuraTextStyles.bodyText.copyWith(
                color: TahuraColors.error,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }
}

class StaffMenuItem {
  final String title;
  final String description;
  final IconData icon;
  final String route;
  final Color color;

  StaffMenuItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.route,
    required this.color,
  });
}
