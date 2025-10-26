import 'package:flutter/material.dart';
import 'package:my_app/widgets/custom_app_bar.dart';
import 'package:my_app/widgets/custom_bottom_nav.dart';
import 'package:my_app/widgets/info_card.dart';
import 'package:url_launcher/url_launcher.dart';

class BuddyHubScreen extends StatelessWidget {
  const BuddyHubScreen({super.key});

  void _comingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Coming soon')),
    );
  }

  Future<void> _openDiscord() async {
    final Uri url = Uri.parse('https://discord.com');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: 'Buddy Hub'),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 3),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Illustration header card
              Container(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.asset(
                    'assets/images/buddy_hub.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              // Cards
              const SizedBox(height: 4),
              InfoCard(
                title: 'Smart Buddy',
                subtitle:
                    'Ask questions and get instant guidance.',
                iconPath: 'assets/images/perform_smartly.png',
                onTap: () => Navigator.pushNamed(context, '/smartBuddy'),
              ),
              InfoCard(
                title: 'Real Buddy',
                subtitle:
                    'Connect with peers in our community server.',
                iconPath: 'assets/images/perform_smartly.png',
                onTap: _openDiscord,
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}