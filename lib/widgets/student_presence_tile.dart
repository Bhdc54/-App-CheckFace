import 'package:flutter/material.dart';

class StudentPresenceTile extends StatelessWidget {
  final String name;
  final bool present;

  const StudentPresenceTile({
    super.key,
    required this.name,
    required this.present,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      title: Text(name),
      trailing: Icon(
        present ? Icons.check : Icons.close,
        color: present ? Colors.greenAccent : Colors.redAccent,
      ),
    );
  }
}
