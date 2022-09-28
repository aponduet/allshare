import 'package:flutter/material.dart';

class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget tablet;
  final Widget desktop;
  const Responsive({
    Key? key,
    required this.mobile,
    required this.tablet,
    required this.desktop,
  }) : super(key: key);

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 650;
  }

  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width < 1100 &&
        MediaQuery.of(context).size.width >= 650;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1100;
  }

  static value(m, t, d, BuildContext context) {
    //  Return any value depending on screen sizes.
    var constraints = MediaQuery.of(context).size.width;
    // If our width is more than 1100 then we consider it a desktop
    if (constraints >= 1100) {
      return d;
    }
    // If width it less then 1100 and more then 650 we consider it as tablet
    else if (constraints >= 650) {
      return t;
    } else {
      // Or less then that we called it mobile
      return m;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: ((context, constraints) {
        // If our width is more than 1100 then we consider it a desktop
        if (constraints.maxWidth >= 1100) {
          return desktop;
        }
        // If width it less then 1100 and more then 650 we consider it as tablet
        else if (constraints.maxWidth >= 650) {
          return tablet;
        } else {
          // Or less then that we called it mobile
          return mobile;
        }
      }),
    );
  }
}
