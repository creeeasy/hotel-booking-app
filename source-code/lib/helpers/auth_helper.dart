import 'package:fatiel/services/auth/bloc/auth_bloc.dart';
import 'package:fatiel/services/auth/bloc/auth_event.dart';
import 'package:fatiel/utilities/dialogs/generic_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> handleLogout(BuildContext context) async {
  final shouldLogout = await showGenericDialog<bool>(
    context: context,
    title: 'Log out',
    content: 'Are you sure you want to log out?',
    optionBuilder: () => {'Cancel': false, 'Log Out': true},
  ).then((value) => value ?? false);

  if (!shouldLogout) return;
  if (context.mounted) {
    context.read<AuthBloc>().add(const AuthEventLogOut());

    Navigator.of(context).maybePop();
  }
}
