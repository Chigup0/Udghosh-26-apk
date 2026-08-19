import 'package:flutter/material.dart';
import 'package:udghosh/utils.dart';

class SportChips extends StatefulWidget {
  @override
  State<SportChips> createState() => _SportChipsState();

  const SportChips({super.key, required this.onTap});
  final Function(int) onTap;
}

class _SportChipsState extends State<SportChips> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Clean section header
          Padding(
            padding: const EdgeInsets.only(left: 20.0, top: 15.0, bottom: 12.0),
            child: Row(
              children: [
                Container(
                  width: 3,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Color(0xFF1E3A8A), // Dark blue accent
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  "Sports",
                  style: TextStyle(
                    fontFamily: globalFontFamily,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: lightTextColor,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: sportsList.length,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemBuilder: (context, index) {
                final sport = sportsList[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () => widget.onTap(index),
                        child: Container(
                          width: 70,
                          height: 70,
                          margin: const EdgeInsets.only(left: 8),
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 243, 243, 255),
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromARGB(255, 31, 0, 171).withOpacity(0.3),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: Offset(
                                  0,
                                  3,
                                ), // changes position of shadow
                              ),
                            ],
                            border: Border.all(
                              color: Color(0xFF1E3A8A), // Dark blue border
                              width: 2,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.transparent,
                            child: Icon(sport['icon'] as IconData, size: 35),
                          ),
                        ),
                      ),
                      SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Center(
                          child: Text(
                            "   " + sport['name']!,
                            style: TextStyle(
                              fontFamily: globalFontFamily,
                              fontSize: 12,
                              color: lightTextColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
