import 'dart:developer';

import 'package:fatiel/models/visitor.dart';
import 'package:fatiel/services/auth/bloc/auth_bloc.dart';
import 'package:fatiel/widgets/hotel/network_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserProfile extends StatelessWidget {
  const UserProfile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final avatarURL =
        (context.watch<AuthBloc>().state.currentUser as Visitor).avatarURL;

    return CircleAvatar(
      radius: 30,
      backgroundColor: Colors.transparent,
      backgroundImage: (avatarURL == null || avatarURL.isEmpty)
          ? const AssetImage("assets/images/default-avatar-icon.jpg")
          : NetworkImage(avatarURL) as ImageProvider,
      child: (avatarURL != null && avatarURL.isNotEmpty)
          ? ClipOval(
              child: NetworkImageWithLoader(
                imageUrl: avatarURL,
                height: 60,
                width: 60,
                aspectRatio: 1,
              ),
            )
          : null,
    );
  }
}
