import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tadbir_go/src/features/auth/data/auth_repository.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/localization/app_text.dart';
import '../../../../core/widgets/premium_widgets.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/auth_layout.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});
  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final keyForm = GlobalKey<FormState>();
  final email = TextEditingController();
  final password = TextEditingController();
  bool hidden = true;
  bool touched = false;
  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> forgotPassword() async {
    final mail = TextEditingController(text: email.text.trim());
    try {
      final selected = await showDialog<String>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(AppText.read(context, 'forgot_password_title')),
          content: TextField(
            controller: mail,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: AppText.read(context, 'email'),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(AppText.read(context, 'cancel')),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, mail.text.trim()),
              child: Text(AppText.read(context, 'send_reset_link')),
            ),
          ],
        ),
      );
      if (selected == null ||
          !selected.contains('@') ||
          !selected.contains('.')) {
        return;
      }
      if (!mounted) return;
      await context.read<AuthRepository>().forgotPassword(selected);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppText.read(context, 'email_sent'))),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppText.read(context, 'something_went_wrong'))),
      );
    } finally {
      mail.dispose();
    }
  }

  @override
  Widget build(BuildContext context) => BlocConsumer<AuthBloc, AuthState>(
    listener: (context, state) {
      if (state is AuthSuccess) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRouter.home,
          (_) => false,
        );
      }
      if (state is AuthFailure) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(state.message)));
      }
    },
    builder: (context, state) => AuthLayout(
      title: AppText.of(context, 'sign_in_title'),
      subtitle: AppText.of(context, 'sign_in_subtitle'),
      form: Form(
        key: keyForm,
        autovalidateMode: touched
            ? AutovalidateMode.onUserInteraction
            : AutovalidateMode.disabled,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: email,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: AppText.of(context, 'email'),
                prefixIcon: Icon(Icons.email_outlined),
              ),
              validator: (v) =>
                  v == null ||
                      !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim())
                  ? AppText.read(context, 'invalid_email')
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: password,
              obscureText: hidden,
              decoration: InputDecoration(
                labelText: AppText.of(context, 'password'),
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  onPressed: () => setState(() => hidden = !hidden),
                  icon: Icon(
                    hidden
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                ),
              ),
              validator: (v) => v == null || v.isEmpty
                  ? AppText.read(context, 'required_field')
                  : null,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: state is AuthLoading ? null : forgotPassword,
                child: Text(AppText.of(context, 'forgot_password')),
              ),
            ),
            const SizedBox(height: 18),
            PremiumButton(
              text: AppText.of(context, 'login'),
              loading: state is AuthLoading,
              onPressed: () {
                setState(() => touched = true);
                if (keyForm.currentState!.validate()) {
                  context.read<AuthBloc>().add(
                    SignInRequested(email.text, password.text),
                  );
                }
              },
            ),
            const SizedBox(height: 18),
            TextButton(
              onPressed: state is AuthLoading
                  ? null
                  : () => Navigator.pushNamed(context, AppRouter.signUp),
              child: Text(
                "${AppText.of(context, 'no_account')} ${AppText.of(context, 'create_account')}",
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
