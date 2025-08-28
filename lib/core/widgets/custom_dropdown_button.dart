import 'package:flutter/material.dart';

class CustomDropdownButton extends StatelessWidget {
  final List<String> menuItems;
  final ValueChanged<String> onSelected;
  final Icon icon;

  const CustomDropdownButton({
    super.key,
    required this.menuItems,
    required this.onSelected,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      // The icon that triggers the dropdown
      icon: icon,
      // Callback when a menu item is selected
      onSelected: onSelected,
      // Build the list of menu items
      itemBuilder: (BuildContext context) {
        return menuItems.map((String item) {
          return PopupMenuItem<String>(
            value: item,
            child: Text(item, style: const TextStyle(color: Colors.black)),
          );
        }).toList();
      },
      // Styling for the dropdown menu
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: Colors.black, width: 1),
      ),
      elevation: 8.0,
    );
  }
}
