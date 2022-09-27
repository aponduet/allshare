import 'package:allshare/data/app_states.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class ReceiveProgressIndicator extends StatelessWidget {
  final AppStates appStates;
  const ReceiveProgressIndicator({Key? key, required this.appStates})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
        valueListenable: appStates.receiveProgressValue,
        builder: (context, value, child) {
          return LinearPercentIndicator(
            width: 600.0,
            lineHeight: 20.0,
            percent: value,
            backgroundColor: Colors.grey,
            progressColor: Colors.blue,
            //animation: true,
            //animationDuration: 1000,
            barRadius: const Radius.circular(10),
            center: Text(
              "${(value * 100).round()}%",
              style: const TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w600,
                  color: Colors.black),
            ),
          );
        });
  }
}
