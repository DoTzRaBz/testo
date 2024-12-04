import 'package:flutter/material.dart';
import 'package:myapp/utils/screen_utils.dart';
import 'package:myapp/utils/size.dart';
import 'package:myapp/utils/style.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String email;
  final String? title;
  final List<Widget>? additionalActions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const CustomAppBar({
    Key? key,
    required this.email,
    this.title,
    this.additionalActions,
    this.showBackButton = false,
    this.onBackPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: showBackButton
          ? IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: TahuraColors.textPrimary,
                size: Sizes.iconMedium,
              ),
              onPressed: onBackPressed ?? () => Navigator.pop(context),
            )
              .animate()
              .fadeIn(duration: TahuraAnimations.medium)
              .slideX(begin: -0.2, end: 0)
          : null,
      title: title != null
          ? Text(
              title!,
              style: TahuraTextStyles.appBarTitle,
            )
              .animate()
              .fadeIn(duration: TahuraAnimations.medium)
              .slideX(begin: -0.2, end: 0)
          : null,
      actions: [
        if (additionalActions != null) ...additionalActions!,
        _buildLogoutButton(context),
      ],
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.5),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return PopupMenuButton(
      icon: Icon(
        Icons.more_vert,
        color: TahuraColors.textPrimary,
        size: Sizes.iconMedium,
      ),
      offset: Offset(0, Sizes.medium),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Sizes.radiusMedium),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          child: ListTile(
            leading: Icon(
              Icons.person,
              color: TahuraColors.primary,
              size: Sizes.iconMedium,
            ),
            title: Text(
              email,
              style: TahuraTextStyles.bodyText.copyWith(
                color: Colors.black87,
              ),
            ),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        PopupMenuItem(
          child: ListTile(
            leading: Icon(
              Icons.logout,
              color: TahuraColors.error,
              size: Sizes.iconMedium,
            ),
            title: Text(
              'Logout',
              style: TahuraTextStyles.bodyText.copyWith(
                color: TahuraColors.error,
              ),
            ),
            contentPadding: EdgeInsets.zero,
            onTap: () => _showLogoutConfirmation(context),
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(duration: TahuraAnimations.medium)
        .slideX(begin: 0.2, end: 0);
  }

  Future<void> _showLogoutConfirmation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
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

    if (confirmed == true) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  @override
  Size get preferredSize => Size.fromHeight(
        ScreenUtils.getResponsiveHeight(8), // 8% of screen height
      );
}
