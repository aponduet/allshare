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
    return Container(
      decoration: BoxDecoration(
          border: Border.all(width: 1, color: Colors.grey),
          borderRadius: const BorderRadius.all(Radius.circular(8))),
      width: 150,
      height: 200,
      child: Column(
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
      ),
    );
  }
}
