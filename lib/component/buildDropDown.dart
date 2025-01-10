import 'package:flood_management_system/component/constant.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget buildDropdownCard({
  required IconData icon,
  required String label,
  String? value,
  required List<String> items,
  Function(String?)? onChanged,
  String? Function(String?)? validator,
}) {
  return Card(
    elevation: 2.0,
    color: kScaffoldColor,
    shadowColor: kLightGreyColor,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: ListTile(
      leading: Icon(icon, color: kButtonTextColor),
      title: DropdownButtonFormField<String>(
        value: value,
        items: items.map((item) => DropdownMenuItem<String>(value: item, child: Text(item))).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
        validator: validator,
      ),
    ),
  );
}