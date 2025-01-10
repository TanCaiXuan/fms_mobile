import 'package:flood_management_system/component/constant.dart';
import 'package:flutter/material.dart';

class buildButtonCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const buildButtonCard({
    required this.label,
    required this.icon,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: kCardColor,
      elevation: 8,
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: kAppBarColor, width: 1),
        borderRadius: BorderRadius.all(Radius.circular(15.0)),
      ),
      clipBehavior: Clip.hardEdge,
      shadowColor: Colors.black.withOpacity(0.2),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: kButtonTextColor,
                size: 55,
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 18,
                  color: kButtonTextColor,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

