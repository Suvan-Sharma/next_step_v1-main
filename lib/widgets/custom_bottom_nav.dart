import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomBottomNav extends StatefulWidget {
  final int currentIndex;

  const CustomBottomNav({super.key, required this.currentIndex});

  @override
  State<CustomBottomNav> createState() => _CustomBottomNavState();
}

class _CustomBottomNavState extends State<CustomBottomNav> {
  late int selectedIndex;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.currentIndex;
  }

  void _onItemTapped(int index) {
    if (index == selectedIndex) return;

    setState(() => selectedIndex = index);

    // Handle navigation here — update routes as per your app
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/home');
        break;
      case 1:
        Navigator.pushNamed(context, '/lifeSkills');
        break;
      case 2:
        Navigator.pushNamed(context, '/goals');
        break;
      case 3:
        Navigator.pushNamed(context, '/buddyHub');
        break;
      case 4:
        Navigator.pushNamed(context, '/journal');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color brandBlue = const Color(0xFF006EDA);
    final items = [
      _NavItemData(
        label: "Home",
        iconPath: "assets/icons/home.svg",
      ),
      _NavItemData(
        label: "Life skills",
        iconPath: "assets/icons/life_skills.svg",
      ),
      _NavItemData(
        label: "Goals",
        iconPath: "assets/icons/goals.svg",
      ),
      _NavItemData(
        label: "Buddy Hub",
        iconPath: "assets/icons/buddy_hub.svg",
      ),
      _NavItemData(
        label: "Journal",
        iconPath: "assets/icons/journal.svg",
      ),
    ];

    return Container(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 15, bottom: 30),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final item = items[index];
          final bool active = index == selectedIndex;
          return _NavItem(
            data: item,
            active: active,
            color: brandBlue,
            onTap: () => _onItemTapped(index),
          );
        }),
      ),
    );
  }
}

class _NavItemData {
  final String label;
  final String iconPath;
  const _NavItemData({required this.label, required this.iconPath});
}

class _NavItem extends StatelessWidget {
  final _NavItemData data;
  final bool active;
  final Color color;
  final VoidCallback onTap;

  const _NavItem({
    required this.data,
    required this.active,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(40),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: active
            ? BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(40),
              )
            : null,
        child: Row(
          children: [
            SvgPicture.asset(
              data.iconPath,
              height: 22,
              width: 22,
              color: active ? color : Colors.black54,
            ),
            if (active) ...[
              const SizedBox(width: 8),
              Text(
                data.label,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
