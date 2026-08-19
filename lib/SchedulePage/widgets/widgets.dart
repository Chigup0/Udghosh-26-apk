import 'package:flutter/material.dart';
import 'package:udghosh/utils.dart';

import '../../widgets/widgets.dart';

Widget verticalLogoWithCollegeName(
  String collegeName,
  double height,
  double width, {
  Color? ringColor,
}) {
  return Container(
    width: 90,
    alignment: Alignment.center,
    child: Column(
      children: [
        TeamLogo(teamName: collegeName, size: width, ringColor: ringColor),
        customText(
          collegeName.toUpperCase(),
          10,
          FontWeight.w900,
          Colors.grey.shade800,
          1.9,
        ),
      ],
    ),
  );
}

Widget horizontalLogoWithCollegeName(
  String collegeName,
  double height,
  double width, {
  Color? ringColor,
}) {
  return Container(
    width: 90,
    alignment: Alignment.center,
    child: Row(
      children: [
        TeamLogo(teamName: collegeName, size: 35, ringColor: ringColor),
        customText(
          collegeName.toUpperCase(),
          10,
          FontWeight.w900,
          Colors.grey.shade800,
          1.9,
        ),
      ],
    ),
  );
}

Widget customChips(
  String sport,
  IconData icon,
  bool isActive,
  Function() onTap,
) {
  return Container(
    decoration: BoxDecoration(
      color: isActive ? yellowColor : Colors.grey.shade200,
      borderRadius: BorderRadius.circular(30.0),
      border: Border.all(
        color: isActive ? darkYellowColor : Colors.grey.shade200,
      ),
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: yellowColor,
        borderRadius: BorderRadius.circular(30.0),
        child: Padding(
          padding: const EdgeInsets.only(
            left: 6.0,
            right: 6.0,
            top: 3.0,
            bottom: 3.0,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isActive ? Colors.white : Colors.grey,
                size: 15.0,
              ),
              const SizedBox(width: 3.0),
              Text(
                sport,
                style: TextStyle(
                  fontFamily: globalFontFamily,
                  fontSize: 13.0,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.white : Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget customChip2(
  String sport,
  IconData icon,
  bool isActive,
  Function() onTap,
) {
  return ClipPath(
    clipper: OctagonClipper(padding: 8),
    child: Container(
      decoration: BoxDecoration(
        color: isActive ? darkYellowColor : Colors.grey.shade300,
        // borderRadius: BorderRadius.circular(30.0),
        border: Border.all(
          color: isActive ? darkYellowColor : Colors.grey.shade300,
        ),
      ),
      child: ClipPath(
        clipper: OctagonClipper(padding: 8),
        child: Container(
          color: isActive ? yellowColor : Colors.grey.shade200,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              splashColor: yellowColor,
              borderRadius: BorderRadius.circular(30.0),
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 8.0,
                  right: 8.0,
                  top: 3.0,
                  bottom: 3.0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      color: isActive
                          ? Colors.white
                          : const Color.fromARGB(255, 119, 119, 119),
                      size: 15.0,
                    ),
                    const SizedBox(width: 3.0),
                    Text(
                      sport,
                      style: TextStyle(
                        fontFamily: globalFontFamily,
                        fontSize: 13.0,
                        fontWeight: FontWeight.w600,
                        color: isActive
                            ? Colors.white
                            : const Color.fromARGB(255, 119, 119, 119),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

Widget customChips1(
  String sport,
  IconData icon,
  bool isActive,
  Function() onTap,
) {
  return Container(
    decoration: BoxDecoration(
      color: isActive ? Colors.blue.shade300 : Colors.grey.shade200,
      borderRadius: BorderRadius.circular(30.0),
      border: Border.all(
        color: isActive ? Colors.blue.shade400 : Colors.grey.shade300,
      ),
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.blue,
        borderRadius: BorderRadius.circular(30.0),
        child: Padding(
          padding: const EdgeInsets.only(
            left: 6.0,
            right: 6.0,
            top: 3.0,
            bottom: 3.0,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: 3.0),
              Icon(
                icon,
                color: isActive ? Colors.white : Colors.grey,
                size: 22.0,
              ),
              const SizedBox(width: 3.0),
              if (isActive)
                Text(
                  sport,
                  style: TextStyle(
                    fontFamily: globalFontFamily,
                    fontSize: 15.0,
                    fontWeight: FontWeight.w500,
                    color: isActive ? Colors.white : Colors.grey.shade600,
                  ),
                ),
              if (isActive) const SizedBox(width: 3.0),
            ],
          ),
        ),
      ),
    ),
  );
}
