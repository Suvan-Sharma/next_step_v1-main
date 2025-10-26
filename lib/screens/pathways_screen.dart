import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/info_card.dart';

class PathwaysScreen extends StatelessWidget {
  const PathwaysScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F8FF),
      appBar: const CustomAppBar(title: "Pathways"),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
        children: [
          InfoCard(
            title: "CareerOneStop",
            subtitle: "Explore careers, training, and jobs",
            iconPath: "assets/icons/career_onestop.png",
            onTap: () async {
              await launchUrl(
                Uri.parse('https://www.careeronestop.org'),
                mode: LaunchMode.externalApplication,
              );
            },
          ),
          InfoCard(
            title: "YouthBuild",
            subtitle: "Education, jobs, and leadership for youth",
            iconPath: "assets/icons/youthbuild.png",
            onTap: () async {
              await launchUrl(
                Uri.parse('https://www.youthbuild.org'),
                mode: LaunchMode.externalApplication,
              );
            },
          ),
          InfoCard(
            title: "Apprenticeship",
            subtitle: "Earn while you learn in-demand skills",
            iconPath: "assets/icons/apprenticeship.png",
            onTap: () async {
              await launchUrl(
                Uri.parse('https://www.apprenticeship.gov'),
                mode: LaunchMode.externalApplication,
              );
            },
          ),
          InfoCard(
            title: "Khan Academy",
            subtitle: "Free lessons to grow your knowledge",
            iconPath: "assets/icons/khan_academy.png",
            onTap: () async {
              await launchUrl(
                Uri.parse('https://www.khanacademy.org'),
                mode: LaunchMode.externalApplication,
              );
            },
          ),
          InfoCard(
            title: "Youth Activism",
            subtitle: "Get involved and make a difference",
            iconPath: "assets/icons/youth_activism.png",
            onTap: () async {
              await launchUrl(
                Uri.parse('https://www.dosomething.org'),
                mode: LaunchMode.externalApplication,
              );
            },
          ),
        ],
      ),
    );
  }
}
