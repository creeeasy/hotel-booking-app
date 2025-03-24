import 'package:fatiel/constants/colors/visitor_theme_colors.dart';
import 'package:fatiel/models/visitor.dart';
import 'package:fatiel/services/auth/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserProfile extends StatelessWidget {
  const UserProfile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final visitor = context.watch<AuthBloc>().state.currentUser as Visitor;
    final avatarURL = visitor.avatarURL;
    return CircleAvatar(
      radius: 30,
      backgroundColor: Colors.transparent,
      backgroundImage: avatarURL?.isNotEmpty == true
          ? NetworkImage(avatarURL!)
          : const AssetImage("assets/images/default-avatar-icon.jpg")
              as ImageProvider,
      child: avatarURL?.isNotEmpty == true
          ? ClipOval(
              child: SizedBox(
                width: 60,
                height: 60,
                child: Image.network(
                  avatarURL!,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: SizedBox(
                        height: 30,
                        width: 30,
                        child: CircularProgressIndicator(
                          color: VisitorThemeColors.primaryColor,
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  (loadingProgress.expectedTotalBytes ?? 1)
                              : null,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, _, __) =>
                      Image.asset("assets/images/default-avatar-icon.jpg"),
                ),
              ),
            )
          : null,
    );
  }
}
