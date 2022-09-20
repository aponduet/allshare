import 'package:flutter/material.dart';

class FileSavingIndicator extends StatelessWidget {
  const FileSavingIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 40,
      decoration: BoxDecoration(
          //color: Colors.green,
          border: Border.all(width: 1, color: Colors.green),
          borderRadius: const BorderRadius.all(Radius.circular(30))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const [
          SizedBox(
            child: Text(
              "File Saving...",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          CircularProgressIndicator(),
        ],
      ),
    );
  }
}
