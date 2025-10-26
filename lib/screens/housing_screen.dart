import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/info_card.dart';

class HousingScreen extends StatelessWidget {
  const HousingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F8FF),
      appBar: const CustomAppBar(title: "Housing Help"),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
        children: [
          InfoCard(
            title: "HUD Youth Homelessness Programs",
            subtitle: "Federal programs that support housing",
            iconPath: "assets/icons/hud.png",
            onTap: () async {
              await launchUrl(
                Uri.parse('https://www.hudexchange.info/homelessness-assistance'),
                mode: LaunchMode.externalApplication,
              );
            },
          ),
          InfoCard(
            title: "National Center for Housing & Child Welfare",
            subtitle: "Advocacy and resources for stable housing",
            iconPath: "assets/icons/nchcw.png",
            onTap: () async {
              await launchUrl(
                Uri.parse('https://www.nchcw.org'),
                mode: LaunchMode.externalApplication,
              );
            },
          ),
          InfoCard(
            title: "Covenant House",
            subtitle: "Shelter and services for young people",
            iconPath: "assets/icons/covenant.png",
            onTap: () async {
              await launchUrl(
                Uri.parse('https://www.covenanthouse.org'),
                mode: LaunchMode.externalApplication,
              );
            },
          ),
          InfoCard(
            title: "Support Networks",
            subtitle: "Hotlines and local support options",
            iconPath: "assets/icons/support.png",
            onTap: () => Navigator.pushNamed(context, '/support'),
          ),
        ],
      ),
    );
  }
}

// Local no-op to satisfy const `onTap` requirement in the list above.
void _noop() {}