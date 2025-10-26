import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_bottom_nav.dart';
import '../widgets/info_card.dart';

class LifeSkillsScreen extends StatelessWidget {
  const LifeSkillsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F8FF),
      appBar: const CustomAppBar(title: "Life skills"),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 1),
      body: ListView(
        padding: const EdgeInsets.only(top: 12, bottom: 24),
        children: [
          InfoCard(
            title: "Pathways",
            subtitle: "Explore education and career resources",
            iconPath: "assets/icons/pathways.png",
            onTap: () => Navigator.pushNamed(context, '/pathways'),
          ),
          InfoCard(
            title: "Crisis Hotlines",
            subtitle: "Get immediate help and support",
            iconPath: "assets/icons/hotline.png",
            onTap: () => Navigator.pushNamed(context, '/hotlines'),
          ),
          InfoCard(
            title: "Money Smart",
            subtitle: "Learn personal finance basics",
            iconPath: "assets/icons/money_smart.png",
            onTap: () async {
              await launchUrl(
                Uri.parse('https://www.fdic.gov/resources/consumers/money-smart'),
                mode: LaunchMode.externalApplication,
              );
            },
          ),
          InfoCard(
            title: "Financial Tips",
            subtitle: "Smart money tips for youth",
            iconPath: "assets/icons/financial_tips.png",
            onTap: () async {
              await launchUrl(
                Uri.parse('https://www.nyc.gov/site/dca/talk-money/fly-financial-literacy-for-youth.page'),
                mode: LaunchMode.externalApplication,
              );
            },
          ),
          InfoCard(
            title: "Housing",
            subtitle: "Find housing help and resources",
            iconPath: "assets/icons/housing.png",
            onTap: () => Navigator.pushNamed(context, '/housing'),
          ),
        ],
      ),
    );
  }
}
