import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:udghosh/utils.dart';

import '../../widgets/widgets.dart';

class ContactUs extends StatelessWidget {
  const ContactUs({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20.0, top: 10.0, bottom: 20.0),
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
                "Contact Us",
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
        // InkWell(
        //   onTap: () {
        //     makePhoneCall("+919838189697");
        //   },
        //   borderRadius: BorderRadius.circular(12),
        //   child: Container(
        //     padding: const EdgeInsets.all(12),
        //     decoration: BoxDecoration(
        //       color: Color(0xFF1E3A8A).withOpacity(0.08),
        //       border: Border.all(
        //         color: Color(0xFF1E3A8A).withOpacity(0.2),
        //         width: 1,
        //       ),
        //       borderRadius: BorderRadius.circular(12),
        //     ),
        //     child: Row(
        //       children: [
        //         Container(
        //           padding: EdgeInsets.all(6),
        //           decoration: BoxDecoration(
        //             color: Color(0xFF1E3A8A).withOpacity(0.15),
        //             borderRadius: BorderRadius.circular(8),
        //           ),
        //           child: Icon(
        //             Icons.person_outline,
        //             color: Color(0xFF3B82F6),
        //             size: 18,
        //           ),
        //         ),
        //         const SizedBox(width: 10),
        //         Expanded(
        //           child: Column(
        //             crossAxisAlignment: CrossAxisAlignment.start,
        //             children: [
        //               Text(
        //                 "Hemant Tiwari (Organising Secretary)",
        //                 style: TextStyle(
        // fontFamily: globalFontFamily,
        //                   fontSize: 13,
        //                   fontWeight: FontWeight.w600,
        //                   color: lightTextColor,
        //                 ),
        //               ),
        //               SizedBox(height: 2),
        //               Text(
        //                 "+919838189697",
        //                 style: TextStyle(
        // fontFamily: globalFontFamily,
        //                   fontSize: 12,
        //                   fontWeight: FontWeight.w500,
        //                   color: Color(0xFF475569),
        //                 ),
        //               ),
        //             ],
        //           ),
        //         ),
        //         Icon(Icons.call_outlined, color: Color(0xFF3B82F6), size: 16),
        //       ],
        //     ),
        //   ),
        // ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () {
            makePhoneCall("5126797999");
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xFF1E3A8A).withOpacity(0.08),
              border: Border.all(
                color: Color(0xFF1E3A8A).withOpacity(0.2),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Color(0xFF1E3A8A).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.security_outlined,
                    color: Color(0xFF3B82F6),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Campus Security : 5126797999",
                    style: TextStyle(
                      fontFamily: globalFontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: lightTextColor,
                    ),
                  ),
                ),
                Icon(Icons.call_outlined, color: Color(0xFF3B82F6), size: 16),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () {
            makePhoneCall("5126797769");
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xFF1E3A8A).withOpacity(0.08),
              border: Border.all(
                color: Color(0xFF1E3A8A).withOpacity(0.2),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Color(0xFF1E3A8A).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.local_hospital_outlined,
                    color: Color(0xFF3B82F6),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Health Center : 5126797769",
                    style: TextStyle(
                      fontFamily: globalFontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: lightTextColor,
                    ),
                  ),
                ),
                Icon(Icons.call_outlined, color: Color(0xFF3B82F6), size: 16),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () {
            makePhoneCall("8247276839");
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xFF1E3A8A).withOpacity(0.08),
              border: Border.all(
                color: Color(0xFF1E3A8A).withOpacity(0.2),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Color(0xFF1E3A8A).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.local_hospital_outlined,
                    color: Color(0xFF3B82F6),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Gender Cell (1) : 8247276839",
                    style: TextStyle(
                      fontFamily: globalFontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: lightTextColor,
                    ),
                  ),
                ),
                Icon(Icons.call_outlined, color: Color(0xFF3B82F6), size: 16),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () {
            makePhoneCall("9257009192");
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xFF1E3A8A).withOpacity(0.08),
              border: Border.all(
                color: Color(0xFF1E3A8A).withOpacity(0.2),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Color(0xFF1E3A8A).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.local_hospital_outlined,
                    color: Color(0xFF3B82F6),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Gender Cell (2) : 9257009192",
                    style: TextStyle(
                      fontFamily: globalFontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: lightTextColor,
                    ),
                  ),
                ),
                Icon(Icons.call_outlined, color: Color(0xFF3B82F6), size: 16),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

Future<void> makePhoneCall(String phoneNumber) async {
  final Uri callUri = Uri(scheme: 'tel', path: phoneNumber);
  await launchUrl(callUri);
}

Future<void> makeEmail(String email) async {
  final Uri callUri = Uri(scheme: 'mailto', path: email);
  if (await canLaunchUrl(callUri)) {
    await launchUrl(callUri);
  } else {
    errorSnackMsg('Could not call $email');
    throw 'Could not launch $callUri';
  }
}
