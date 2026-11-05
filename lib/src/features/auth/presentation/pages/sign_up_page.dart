import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/localization/app_text.dart';
import '../../../../core/widgets/premium_widgets.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/auth_layout.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});
  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final keyForm = GlobalKey<FormState>();
  final username = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirm = TextEditingController();
  bool hidden = true, confirmHidden = true, touched = false;
  @override
  void dispose() {
    username.dispose();
    email.dispose();
    password.dispose();
    confirm.dispose();
    super.dispose();
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
      title: AppText.of(context, 'sign_up_title'),
      subtitle: AppText.of(context, 'sign_up_subtitle'),
      back: true,
      form: Form(
        key: keyForm,
        autovalidateMode: touched
            ? AutovalidateMode.onUserInteraction
            : AutovalidateMode.disabled,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: username,
              decoration: InputDecoration(
                labelText: AppText.of(context, 'username'),
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (v) => v == null || v.trim().length < 3
                  ? AppText.read(context, 'username_too_short')
                  : null,
            ),
            const SizedBox(height: 14),
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
            const SizedBox(height: 14),
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
              validator: (v) => v == null || v.length < 8
                  ? AppText.read(context, 'password_min_8')
                  : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: confirm,
              obscureText: confirmHidden,
              decoration: InputDecoration(
                labelText: AppText.of(context, 'confirm_password'),
                prefixIcon: const Icon(Icons.verified_user_outlined),
                suffixIcon: IconButton(
                  onPressed: () =>
                      setState(() => confirmHidden = !confirmHidden),
                  icon: Icon(
                    confirmHidden
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                ),
              ),
              validator: (v) => v != password.text
                  ? AppText.read(context, 'passwords_do_not_match')
                  : null,
            ),
            const SizedBox(height: 26),
            PremiumButton(
              text: AppText.of(context, 'create_account'),
              loading: state is AuthLoading,
              onPressed: () {
                setState(() => touched = true);
                if (keyForm.currentState!.validate()) {
                  context.read<AuthBloc>().add(
                    SignUpRequested(username.text, email.text, password.text),
                  );
                }
              },
            ),
            const SizedBox(height: 18),
            TextButton(
              onPressed: state is AuthLoading
                  ? null
                  : () => Navigator.pop(context),
              child: Text(
                "${AppText.of(context, 'have_account')} ${AppText.of(context, 'login')}",
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
