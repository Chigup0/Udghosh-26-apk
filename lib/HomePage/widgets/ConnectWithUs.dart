import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ConnectWithUs extends StatelessWidget {
  const ConnectWithUs({super.key});
  final double iconSize = 25;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Color(0xFF1E3A8A).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Color(0xFF1E3A8A).withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: 16),

          // Social media icons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSocialIcon(
                FontAwesomeIcons.whatsapp,
                Color.fromARGB(255, 59, 246, 96),
                'https://chat.whatsapp.com/BDCIfPdcxVS7Ai9njjn8Z7',
              ),
              SizedBox(width: 16),
              _buildSocialIcon(
                FontAwesomeIcons.globe,
                Color(0xFF3B82F6),
                'https://udghosh.org.in/',
              ),
              SizedBox(width: 16),
              _buildInstagramIcon(),
              SizedBox(width: 16),
              _buildSocialIcon(
                FontAwesomeIcons.facebook,
                Color.fromARGB(255, 5, 95, 240),
                'https://www.facebook.com/udghosh.iitk/',
              ),
              SizedBox(width: 16),
              _buildSocialIcon(
                FontAwesomeIcons.youtube,
                Color(0xFFDC2626),
                'https://www.youtube.com/@Udghoshiitk/featured',
              ),
              SizedBox(width: 16),
              _buildSocialIcon(
                FontAwesomeIcons.linkedin,
                Color(0xFF1E40AF),
                'https://in.linkedin.com/company/udghosh-iit-kanpur-fest',
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper method for regular social icons
  Widget _buildSocialIcon(dynamic icon, Color color, String url) {
    return InkWell(
      onTap: () {
        launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
        ),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }

  // Special Instagram icon with gradient
  Widget _buildInstagramIcon() {
    return InkWell(
      onTap: () {
        launchUrl(
          Uri.parse('https://www.instagram.com/udghosh_iitk/'),
          mode: LaunchMode.externalApplication,
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          // gradient: LinearGradient(
          //   colors: [
          //     Color(0xFF833AB4).withValues(alpha: 0.15),
          //     Color(0xFFC13584).withValues(alpha: 0.15),
          //     Color(0xFFF56040).withValues(alpha: 0.15),
          //   ],
          //   begin: Alignment.topLeft,
          //   end: Alignment.bottomRight,
          // ),
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Color(0xFFC13584).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: GradientIcon(
          icon: FontAwesomeIcons.instagram,
          size: 20,
          gradient: const LinearGradient(
            colors: [
              Color(0xFF833AB4),
              Color(0xFFC13584),
              Color(0xFFF56040),
              Color(0xFFFCAF45),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }
}

Widget mediaIcon(IconData icon, Color color, double iconSize, String url) {
  return InkWell(
    onTap: () {
      launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    },
    child: Icon(icon, color: color, size: iconSize),
  );
}

class GradientIcon extends StatelessWidget {
  final dynamic icon;
  final double size;
  final Gradient gradient;

  const GradientIcon({
    required this.icon,
    required this.size,
    required this.gradient,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return gradient.createShader(bounds);
      },
      child: FaIcon(
        icon,
        size: size,
        color: Colors.white, // The color is ignored due to ShaderMask
      ),
    );
  }
}
