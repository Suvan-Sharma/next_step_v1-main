import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:my_app/widgets/custom_bottom_nav.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String name = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final storedName = prefs.getString('name');
    if (mounted) {
      setState(() => name = storedName ?? 'Amelia');
    }
  }

  @override
  Widget build(BuildContext context) {
    final String displayName = name.isNotEmpty ? name : 'Amelia';

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const CustomBottomNav(currentIndex: 0),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent, // let our overlay color show
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        child: Stack(
          children: [
            // Paint the notch/status bar area to match the header gradient
            Builder(
              builder: (context) {
                final double statusBarHeight = MediaQuery.of(context).padding.top;
                if (statusBarHeight == 0) return const SizedBox.shrink();
                return Container(
                  height: statusBarHeight,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF0077FF), Color(0xFF006EDA)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                );
              },
            ),
            SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
              // Top gradient header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0077FF), Color(0xFF006EDA)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top logo and settings row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset(
                                'assets/images/logo.svg',
                                height: 40,
                                width: 40,
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Next Step',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  'Life Unblocked',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: PopupMenuButton<String>(
                            icon: const Icon(Icons.tune, color: Colors.white),
                            tooltip: 'Menu',
                            elevation: 12,
                            color: Colors.white,
                            surfaceTintColor: Colors.transparent,
                            position: PopupMenuPosition.under,
                            // Shift left so the menu aligns to the icon on the right edge
                            offset: const Offset(0, 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            constraints: const BoxConstraints(minWidth: 180),
                            onSelected: (value) async {
                              if (value == 'profile') {
                                await Navigator.pushNamed(context, '/profile');
                                // Reload in case name changed
                                if (mounted) {
                                  await _loadData();
                                }
                              } else if (value == 'logout') {
                                final prefs = await SharedPreferences.getInstance();
                                // Preserve saved credentials; clear only session/ephemeral values
                                await prefs.setBool('loggedIn', false);
                                await prefs.remove('tempPassword');
                                await prefs.remove('tempEmail');
                                if (!mounted) return;
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  '/welcome',
                                  (route) => false,
                                );
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem<String>(
                                value: 'profile',
                                height: 42,
                                child: Row(
                                  children: const [
                                    Icon(Icons.person_outline, color: Color(0xFF0A1543)),
                                    SizedBox(width: 10),
                                    Text(
                                      'Profile',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF0A1543),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const PopupMenuDivider(height: 0),
                              PopupMenuItem<String>(
                                value: 'logout',
                                height: 42,
                                child: Row(
                                  children: const [
                                    Icon(Icons.logout, color: Colors.redAccent),
                                    SizedBox(width: 10),
                                    Text(
                                      'Log Out',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.redAccent,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Greeting section
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 36,
                          backgroundColor: Colors.white24,
                          child: Icon(Icons.person, color: Colors.white, size: 36),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hey $displayName,',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Ready For Your Next Step?',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Feature grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  childAspectRatio: 0.95,
                  children: [
                    _FeatureTile(
                      title: 'Life Skills',
                      imagePath: 'assets/images/life_skills.png',
                      onTap: () => Navigator.pushNamed(context, '/lifeSkills'),
                    ),
                    _FeatureTile(
                      title: 'Goals',
                      imagePath: 'assets/images/goals.png',
                      onTap: () => Navigator.pushNamed(context, '/goals'),
                    ),
                    _FeatureTile(
                      title: 'Buddy Hub',
                      imagePath: 'assets/images/buddy_hub.png',
                      onTap: () => Navigator.pushNamed(context, '/buddyHub'),
                    ),
                    _FeatureTile(
                      title: 'Journal',
                      imagePath: 'assets/images/journal.png',
                      onTap: () => Navigator.pushNamed(context, '/journal'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // Promo card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _PromoCard(
                  imagePath: 'assets/images/perform_smartly.png',
                  onTap: () => Navigator.pushNamed(context, '/performSmartly'),
                ),
              ),

              const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Feature Tile ---
class _FeatureTile extends StatelessWidget {
  final String title;
  final String imagePath;
  final VoidCallback onTap;

  const _FeatureTile({
    required this.title,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF5F9FF),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Image.asset(imagePath, fit: BoxFit.contain),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0A1543),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Promo Card ---
class _PromoCard extends StatelessWidget {
  final String imagePath;
  final VoidCallback onTap;

  const _PromoCard({
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
        child: Container(
        height: 118,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F6FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset(imagePath, fit: BoxFit.contain),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'How To Perform Smartly?',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 6),
                  Text(
                      'Practical tips to improve your performance',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black54),
          ],
        ),
      ),
    );
  }
}