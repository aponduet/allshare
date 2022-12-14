import 'package:flutter/material.dart';

class SendSuccessIndicator extends StatelessWidget {
  const SendSuccessIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 700,
      height: 40,
      decoration: BoxDecoration(
          color: Colors.green,
          border: Border.all(width: 1, color: Colors.green),
          borderRadius: const BorderRadius.all(Radius.circular(30))),
      child: const Center(
        child: Text(
          "File Transfer Successful",
          style: TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
