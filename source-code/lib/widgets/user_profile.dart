import 'package:fatiel/constants/colors/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class UserProfile extends StatelessWidget {
  final String? avatarURL;
  final String? firstName;
  final String? lastName;
  final String? name;

  const UserProfile({
    Key? key,
    this.avatarURL,
    this.firstName,
    this.lastName,
    this.name,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasAvatar = avatarURL?.isNotEmpty == true;
    final displayName = name ?? '${firstName ?? ''} ${lastName ?? ''}'.trim();

    return Container(
      width: 136,
      height: 136,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: ThemeColors.primaryLight,
          width: 2,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (hasAvatar)
            ClipOval(
              child: SizedBox(
                width: 132,
                height: 132,
                child: Image.network(
                  avatarURL!,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: ThemeColors.primary,
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                (loadingProgress.expectedTotalBytes ?? 1)
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, _, __) =>
                      _buildFallbackIcon(displayName),
                ),
              ),
            )
          else
            _buildFallbackIcon(displayName),
        ],
      ),
    );
  }

  Widget _buildFallbackIcon(String displayName) {
    // If there's a name, show initials
    if (displayName.isNotEmpty) {
      final initials = _getInitials(displayName);

      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: ThemeColors.primary.withOpacity(0.1),
        ),
        child: Center(
          child: Text(
            initials,
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: ThemeColors.primary,
            ),
          ),
        ),
      );
    }

    // Default fallback
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: ThemeColors.primary.withOpacity(0.1),
      ),
      child: const Icon(
        Iconsax.user,
        size: 48,
        color: ThemeColors.primary,
      ),
    );
  }

  String _getInitials(String name) {
    final nameParts = name.split(' ').where((part) => part.isNotEmpty).toList();
    if (nameParts.isEmpty) return '';
    if (nameParts.length == 1) return nameParts[0][0].toUpperCase();

    return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
  }
}
