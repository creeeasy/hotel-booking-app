import 'package:fatiel/constants/colors/theme_colors.dart';
import 'package:fatiel/services/auth/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

class UserProfile extends StatelessWidget {
  const UserProfile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final avatarURL = context.watch<AuthBloc>().state.currentUser.avatarURL;
    final hasAvatar = avatarURL?.isNotEmpty == true;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: ThemeColors.primaryLight, width: 2),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        width: 60,
        height: 60,
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
                  width: 56,
                  height: 56,
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
                    errorBuilder: (context, _, __) => _buildFallbackIcon(),
                  ),
                ),
              )
            else
              _buildFallbackIcon(),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackIcon() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: ThemeColors.primary.withOpacity(0.1),
      ),
      child: const Icon(
        Iconsax.user,
        size: 28,
        color: ThemeColors.primary,
      ),
    );
  }
}
