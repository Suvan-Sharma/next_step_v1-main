import 'package:flutter/material.dart';

class HotlineCard extends StatelessWidget {
  final String title;
  final String number;
  final VoidCallback onCallTap;
  final Widget? trailing;
  final String? titleNote;

  const HotlineCard({
    required this.title,
    required this.number,
    required this.onCallTap,
    this.trailing,
    this.titleNote,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onCallTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      style: DefaultTextStyle.of(context).style,
                      children: [
                        const TextSpan(
                          text: '',
                        ),
                        TextSpan(
                          text: title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                        if (titleNote != null)
                          TextSpan(
                            text: " ${'' + titleNote!}",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 10,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    number,
                    style: const TextStyle(
                      color: Color(0xFF1E88E5), // link-like blue
                    ),
                  ),
                ]),
            trailing ??
                IconButton(
                  icon: const Icon(Icons.call, color: Colors.blueAccent),
                  onPressed: onCallTap,
                ),
          ],
        ),
      ),
    );
  }
}
