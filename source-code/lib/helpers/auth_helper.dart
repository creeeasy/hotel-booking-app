import 'package:fatiel/l10n/l10n.dart';
import 'package:fatiel/services/auth/bloc/auth_bloc.dart';
import 'package:fatiel/services/auth/bloc/auth_event.dart';
import 'package:fatiel/utilities/dialogs/generic_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> handleLogout(BuildContext context) async {
  final shouldLogout = await showGenericDialog<bool>(
    context: context,
    title: L10n.of(context).logoutTitle,
    content: L10n.of(context).logoutContent,
    optionBuilder: () => {
      L10n.of(context).cancel: false,
      L10n.of(context).logout: true,
    },
  ).then((value) => value ?? false);

  if (!shouldLogout) return;
  if (context.mounted) {
    context.read<AuthBloc>().add(const AuthEventLogOut());
    Navigator.of(context).maybePop();
  }
}
