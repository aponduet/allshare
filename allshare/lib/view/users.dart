import 'package:flutter/material.dart';

class Users extends StatelessWidget {
  final String name;
  final String id;
  final bool status;
  const Users({
    Key? key,
    required this.name,
    required this.id,
    required this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(name),
        Text(id),
        status
            ? const Text(
                'Online',
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.green,
                    fontWeight: FontWeight.bold),
              )
            : const Text('Offline',
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.red,
                    fontWeight: FontWeight.bold)),
      ],
    );
  }
}
