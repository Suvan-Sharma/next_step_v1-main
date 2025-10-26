import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/info_card.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F8FF),
      appBar: const CustomAppBar(title: "Support Networks"),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
        children: [
          InfoCard(
            title: "FosterClub",
            subtitle: "Community, tools, and stories for foster youth",
            iconPath: "assets/icons/fosterclub.png",
            onTap: () async {
              await launchUrl(
                Uri.parse('https://www.fosterclub.com'),
                mode: LaunchMode.externalApplication,
              );
            },
          ),
          InfoCard(
            title: "National Mentoring",
            subtitle: "Find mentoring programs and resources",
            iconPath: "assets/icons/national_mentoring.png",
            onTap: () async {
              await launchUrl(
                Uri.parse('https://www.nationalmentoringresourcecenter.org'),
                mode: LaunchMode.externalApplication,
              );
            },
          ),
          InfoCard(
            title: "Transition",
            subtitle: "Guidance for life transitions and planning",
            iconPath: "assets/icons/transition.png",
            onTap: () async {
              await launchUrl(
                Uri.parse('https://youth.gov'),
                mode: LaunchMode.externalApplication,
              );
            },
          ),
        ],
      ),
    );
  }
}
