import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:myapp/pages/chat_screen.dart';
import 'package:myapp/report_screen.dart';
import 'package:myapp/database_helper.dart';
import 'package:myapp/utils/screen_utils.dart';
import 'package:myapp/utils/size.dart';
import 'package:myapp/utils/style.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HomeScreen extends StatefulWidget {
  final String email;

  const HomeScreen({Key? key, required this.email}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? userRole;
  int _currentCarouselIndex = 0;

  @override
  void initState() {
    super.initState();
    _getUserRole();
  }

  Future<void> _getUserRole() async {
    String? role = await DatabaseHelper().getUserRole(widget.email);
    setState(() {
      userRole = role;
    });
  }

  List<String> get carouselImages => [
        'C:/Users/Nikolaus Franz/Documents/tahura_project/lib/assets/tahura1.png',
        'C:/Users/Nikolaus Franz/Documents/tahura_project/lib/assets/tahura2.png',
        'C:/Users/Nikolaus Franz/Documents/tahura_project/lib/assets/tahura3.png',
        'C:/Users/Nikolaus Franz/Documents/tahura_project/lib/assets/tahura4.png',
        'C:/Users/Nikolaus Franz/Documents/tahura_project/lib/assets/tahura5.png',
        'C:/Users/Nikolaus Franz/Documents/tahura_project/lib/assets/tahura6.png',
        'C:/Users/Nikolaus Franz/Documents/tahura_project/lib/assets/tahura7.png',
        'C:/Users/Nikolaus Franz/Documents/tahura_project/lib/assets/tahura8.png',
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Tahura Explorer',
          style: TahuraTextStyles.appBarTitle,
        )
            .animate()
            .fadeIn(duration: TahuraAnimations.medium)
            .slideX(begin: -0.2, end: 0),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Carousel Tahura
                _buildTahuraCarousel()
                    .animate()
                    .fadeIn(duration: TahuraAnimations.medium)
                    .scale(),

                // Carousel Indicator
                _buildCarouselIndicator()
                    .animate()
                    .fadeIn(duration: TahuraAnimations.medium),

                // Greeting Section
                _buildGreetingSection()
                    .animate()
                    .fadeIn(duration: TahuraAnimations.medium)
                    .slideY(begin: 0.2, end: 0),

                // Quick Access Menu
                _buildQuickAccessMenu()
                    .animate()
                    .fadeIn(duration: TahuraAnimations.medium)
                    .slideY(begin: 0.3, end: 0),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildTahuraCarousel() {
    return CarouselSlider(
      options: CarouselOptions(
        height: ScreenUtils.getResponsiveHeight(30),
        autoPlay: true,
        enlargeCenterPage: true,
        viewportFraction: 0.9,
        onPageChanged: (index, reason) {
          setState(() {
            _currentCarouselIndex = index;
          });
        },
      ),
      items: carouselImages.map((imagePath) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.symmetric(horizontal: Sizes.small),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Sizes.radiusLarge),
                image: DecorationImage(
                  image: AssetImage(imagePath),
                  fit: BoxFit.cover,
                ),
                boxShadow: TahuraShadows.medium,
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildCarouselIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: carouselImages.asMap().entries.map((entry) {
        return Container(
          width: Sizes.xsmall,
          height: Sizes.xsmall,
          margin: EdgeInsets.symmetric(
            vertical: Sizes.small,
            horizontal: Sizes.xsmall,
          ),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentCarouselIndex == entry.key
                ? TahuraColors.primary
                : TahuraColors.textSecondary,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGreetingSection() {
    return Padding(
      padding: EdgeInsets.all(Sizes.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selamat Datang di Tahura',
            style: TahuraTextStyles.screenTitle,
          ),
          SizedBox(height: Sizes.small),
          Text(
            'Jelajahi keindahan alam dan keanekaragaman hayati',
            style: TahuraTextStyles.bodyTextSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessMenu() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Sizes.large),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            _buildQuickAccessButton(
              icon: Icons.cloud,
              label: 'Cuaca',
              onTap: () => Navigator.pushNamed(context, '/weather'),
            ),
            if (userRole == 'admin' || userRole == 'staff') ...[
              SizedBox(width: Sizes.medium),
              _buildQuickAccessButton(
                icon: Icons.analytics_outlined,
                label: 'Analisis',
                onTap: () => Navigator.pushNamed(context, '/analysis'),
              ),
            ],
            SizedBox(width: Sizes.medium),
            _buildQuickAccessButton(
              icon: Icons.confirmation_number_outlined,
              label: 'Tiket',
              onTap: () => Navigator.pushNamed(context, '/ticket'),
            ),
            SizedBox(width: Sizes.medium),
            _buildQuickAccessButton(
              icon: Icons.calendar_month,
              label: 'Event',
              onTap: () =>
                  Navigator.pushNamed(context, '/event', arguments: userRole),
            ),
            if (userRole == 'admin' || userRole == 'staff') ...[
              SizedBox(width: Sizes.medium),
              _buildQuickAccessButton(
                icon: Icons.report,
                label: 'Laporan',
                onTap: () => Navigator.pushNamed(context, '/report'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: TahuraShadows.small,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Sizes.radiusMedium),
          child: Container(
            padding: EdgeInsets.all(Sizes.medium),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(Sizes.radiusMedium),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: Sizes.iconLarge,
                ),
                SizedBox(height: Sizes.small),
                Text(
                  label,
                  style: TahuraTextStyles.bodyText,
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: TahuraAnimations.medium).scale();
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      backgroundColor: TahuraColors.primary,
      tooltip: 'Chat AI',
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              isAdminOrStaff: userRole == 'admin' || userRole == 'staff',
            ),
          ),
        );
      },
      child: Icon(
        Icons.chat,
        color: Colors.white,
        size: Sizes.iconMedium,
      ),
    ).animate().fadeIn(duration: TahuraAnimations.medium).scale();
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      backgroundColor: Colors.black,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white54,
      currentIndex: 1,
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
        if (index == 0) {
          Navigator.pushNamed(context, '/profile', arguments: widget.email);
        } else if (index == 2) {
          Navigator.pushNamed(context, '/map',
              arguments: userRole == 'admin' || userRole == 'staff'
                  ? 'admin'
                  : widget.email);
        }
      },
    );
  }
}
