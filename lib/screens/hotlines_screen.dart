import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/hotline_card.dart';

class HotlinesScreen extends StatelessWidget {
  const HotlinesScreen({super.key});

  Future<void> _launchPhone(String phoneNumber) async {
    final Uri uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchSms(String phoneNumber, {String? body}) async {
    final Uri uri = Uri(scheme: 'sms', path: phoneNumber, queryParameters: body == null ? null : {"body": body});
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F8FF),
      appBar: const CustomAppBar(title: "Crisis Hotlines"),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          HotlineCard(
            title: "Suicide & Crisis Lifeline",
            number: "988",
            onCallTap: () => _launchPhone('988'),
            trailing: Image.asset('assets/icons/call_info.gif', height: 42),
          ),
          HotlineCard(
            title: "National Runaway Safeline",
            number: "1-800-RUNAWAY (1-800-786-2929)",
            onCallTap: () => _launchPhone('1-800-786-2929'),
            trailing: Image.asset('assets/icons/call_info.gif', height: 42),
          ),
          HotlineCard(
            title: "SAMHSA Helpline",
            number: "1-800-662-HELP (4357)",
            onCallTap: () => _launchPhone('1-800-662-4357'),
            titleNote: "(Mental Health & Substance Use)",
            trailing: Image.asset('assets/icons/call_info.gif', height: 42),
          ),
          HotlineCard(
            title: "Crisis Text Line",
            number: "Text HOME to 741741",
            onCallTap: () => _launchSms('741741', body: 'HOME'),
            trailing: Image.asset('assets/icons/text_info.gif', height: 42),
          ),
        ],
      ),
    );
  }
}