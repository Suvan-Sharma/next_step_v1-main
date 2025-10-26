import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBack;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.onBack,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      elevation: 0,
      backgroundColor: Colors.transparent,
      toolbarHeight: 66,
      automaticallyImplyLeading: false,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFB3D3F4),
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(22),
          ),
        ),
      ),
      title: Padding(
        padding: const EdgeInsets.only(top: 0.0),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 23,
          ),
        ),
      ),
      centerTitle: true,
      leading: Padding(
        padding: const EdgeInsets.only(top: 0.0, left: 8.0),
        child: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF4EA3F8),
            size: 20,
          ),
          onPressed: onBack ?? () => Navigator.pop(context),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(66);
}