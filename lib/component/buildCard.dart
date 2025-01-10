import 'package:flood_management_system/component/constant.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


Widget buildCard({
  required IconData icon,
  required String label,
  required String hint,
  TextEditingController? controller,
  TextInputType? keyboardType,
  bool readOnly = false,
  int? maxLines,
  Function(String)? onChanged,
  String? Function(String?)? validator,
  Function()? onTap,
}) {
  return Card(
    elevation: 2.0,
    color: kScaffoldColor,
    shadowColor: kLightGreyColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    child: ListTile(
      leading: Icon(icon, color: kButtonTextColor),
      title: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        readOnly: readOnly,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          hintStyle: const TextStyle(
            color: Colors.grey, // Set the color of the hint text
            fontFamily: 'Roboto',
            fontSize: 13, // Set the font size (optional)
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 16,
          ),
        ),
        onChanged: onChanged,
        validator: validator,
        onTap: onTap,
      ),
    ),
  );
}
