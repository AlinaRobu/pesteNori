import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:peste_nori/controllers/AppLoginCtrl.dart';
import 'package:peste_nori/globals.dart';

Future<void> signOutOfAccount(BuildContext context) async {
  try {
    await AppLoginCtrl().signOut();
    if (context.mounted)
      Navigator.of(context).popUntil((route) => route.isFirst);
  } catch (error) {
    debugPrint('Sign-out failed: $error');
    if (context.mounted) _showError(context, translations.signOutError);
  }
}

Future<void> confirmAccountDeletion(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(translations.deleteAccount),
      content: Text(translations.deleteAccountConfirm),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(translations.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(translations.deleteAccount),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;

  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;
  final providers = user.providerData
      .map((provider) => provider.providerId)
      .toSet();
  final password = providers.contains('password')
      ? await _askForPassword(context)
      : null;
  if (!context.mounted ||
      (providers.contains('password') && password == null)) {
    return;
  }

  final auth = AppLoginCtrl();
  try {
    if (!await auth.reauthenticateWithCredential(providers, password)) return;
    if (FirebaseAuth.instance.currentUser?.uid != user.uid) return;
    await auth.deleteAccount();
    if (context.mounted)
      Navigator.of(context).popUntil((route) => route.isFirst);
  } on FirebaseAuthException catch (error) {
    if (!context.mounted) return;
    _showError(
      context,
      error.code == 'invalid-credential' || error.code == 'wrong-password'
          ? translations.wrongPassword
          : translations.deleteAccountError,
    );
  } catch (error) {
    debugPrint('Account deletion failed: $error');
    if (context.mounted) _showError(context, translations.deleteAccountError);
  }
}

Future<String?> _askForPassword(BuildContext context) {
  var password = '';
  return showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(translations.confirmYourPassword),
      content: TextField(
        obscureText: true,
        onChanged: (value) => password = value,
        decoration: InputDecoration(labelText: translations.password),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: Text(translations.cancel),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(dialogContext, password),
          child: Text(translations.confirm),
        ),
      ],
    ),
  );
}

void _showError(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
