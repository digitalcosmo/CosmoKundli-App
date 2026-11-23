import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/api.dart';
import '../core/session.dart';
import '../main.dart';
import '../ui/ck_theme.dart';
import '../ui/glass.dart';
import '../ui/widgets.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _go();
  }

  Future<void> _go() async {
    await Future.delayed(const Duration(milliseconds: 1100));
    if (!Session.loggedIn) return goLogin();
    // Same device check as the original app: one active device per account.
    try {
      final r = await Api.post(Endpoints.verifyDevice, {'uID': Session.uid, 'device_id': Session.deviceId});
      if (r.containsKey('status') && !Api.ok(r)) {
        await Session.signOut();
        goLogin();
        Get.snackbar('Signed out', 'Your account was signed in on another device.',
            snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(16));
        return;
      }
    } catch (_) {/* offline: let them in, calls will show their own errors */}
    goHome();
  }

  @override
  Widget build(BuildContext context) => CkScaffold(
        body: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 900),
            curve: CkMotion.ease,
            builder: (c, t, child) => Opacity(opacity: t, child: Transform.scale(scale: .94 + .06 * t, child: child)),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 56),
                child: Image.asset('assets/images/ck_logo.png'),
              ),
              const SizedBox(height: 34),
              const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.4)),
            ]),
          ),
        ),
      );
}

class _AuthFrame extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> children;
  final Widget? footer;
  final bool back;
  const _AuthFrame({required this.title, required this.subtitle, required this.children, this.footer, this.back = false});
  @override
  Widget build(BuildContext context) => CkScaffold(
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Stack(children: [
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
                child: Column(children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Image.asset('assets/images/ck_logo.png', height: 64),
                  ),
                  const SizedBox(height: 26),
                  FadeSlideIn(
                    child: Glass(
                      radius: 28,
                      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                        Text(title, style: CkText.h(24)),
                        const SizedBox(height: 4),
                        Text(subtitle, style: CkText.muted.copyWith(fontSize: 14)),
                        const SizedBox(height: 6),
                        ...children,
                      ]),
                    ),
                  ),
                  if (footer != null) ...[const SizedBox(height: 20), footer!],
                ]),
              ),
            ),
            if (back)
              Positioned(
                  left: 14,
                  top: 8,
                  child: CircleBtn(Icons.arrow_back_ios_new_rounded, label: 'Back', onTap: () => Get.back())),
          ]),
        ),
      );
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _hide = true, _remember = true, _busy = false;

  Future<void> _login() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      final r = await Api.post(Endpoints.login,
          {'email': _email.text.trim(), 'password': _pass.text, 'device_id': Session.deviceId});
      if (Api.ok(r)) {
        await Session.signIn((r['uID'] ?? '').toString(), (r['feature'] is List) ? r['feature'] : []);
        goHome();
      } else if (mounted) {
        toast(context, Api.msg(r, 'Email or password is incorrect'), error: true);
      }
    } catch (_) {
      if (mounted) toast(context, 'Couldn\'t reach the server. Check your connection.', error: true);
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) => _AuthFrame(
        title: 'Welcome back',
        subtitle: 'Sign in to continue to your clients',
        footer: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text('New to CosmoKundli? ', style: CkText.muted),
          GestureDetector(
            onTap: () => Get.to(() => const SignUpPage()),
            child: const Text('Create account', style: TextStyle(color: Color(0xFFF7A45E), fontWeight: FontWeight.w700)),
          ),
        ]),
        children: [
          Form(
            key: _form,
            child: Column(children: [
              Field('Email', controller: _email, icon: Icons.person_outline_rounded, keyboard: TextInputType.emailAddress,
                  validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email' : null),
              Field('Password',
                  controller: _pass,
                  icon: Icons.lock_outline_rounded,
                  obscure: _hide,
                  required: false,
                  validator: (v) => (v == null || v.isEmpty) ? 'Enter your password' : null,
                  suffix: IconButton(
                      onPressed: () => setState(() => _hide = !_hide),
                      icon: Icon(_hide ? Icons.visibility_outlined : Icons.visibility_off_outlined))),
            ]),
          ),
          const SizedBox(height: 12),
          Row(children: [
            GestureDetector(
              onTap: () => setState(() => _remember = !_remember),
              child: Row(children: [
                AnimatedContainer(
                  duration: CkMotion.fast,
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: _remember ? CkColors.orangeSoft : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: _remember ? CkColors.orangeSoft : CkColors.textSecondary),
                  ),
                  child: _remember ? const Icon(Icons.check_rounded, size: 15, color: Colors.white) : null,
                ),
                const SizedBox(width: 8),
                const Text('Remember me', style: TextStyle(fontSize: 13)),
              ]),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => Get.to(() => const ForgotPasswordPage()),
              child: const Text('Forgot password?', style: TextStyle(color: Color(0xFFF7A45E), fontWeight: FontWeight.w600, fontSize: 13)),
            ),
          ]),
          const SizedBox(height: 18),
          PrimaryButton('Login', onTap: _login, loading: _busy),
        ],
      );
}

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});
  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _mobile = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _busy = false, _hide = true;

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      final r = await Api.post(Endpoints.signUp,
          {'name': _name.text.trim(), 'mobile': _mobile.text.trim(), 'email': _email.text.trim(), 'password': _pass.text});
      if (!mounted) return;
      if (Api.ok(r)) {
        toast(context, Api.msg(r, 'Account created. Please sign in.'));
        Get.back();
      } else {
        toast(context, Api.msg(r), error: true);
      }
    } catch (_) {
      if (mounted) toast(context, 'Couldn\'t reach the server.', error: true);
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) => _AuthFrame(
        back: true,
        title: 'Create account',
        subtitle: 'Start using CosmoKundli on your phone',
        children: [
          Form(
            key: _form,
            child: Column(children: [
              Field('Name', controller: _name, icon: Icons.person_outline_rounded, required: true),
              Field('Mobile', controller: _mobile, icon: Icons.phone_outlined, keyboard: TextInputType.phone, required: true),
              Field('Email', controller: _email, icon: Icons.mail_outline_rounded, keyboard: TextInputType.emailAddress,
                  validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email' : null),
              Field('Password',
                  controller: _pass,
                  icon: Icons.lock_outline_rounded,
                  obscure: _hide,
                  validator: (v) => (v == null || v.length < 6) ? 'At least 6 characters' : null,
                  suffix: IconButton(
                      onPressed: () => setState(() => _hide = !_hide),
                      icon: Icon(_hide ? Icons.visibility_outlined : Icons.visibility_off_outlined))),
            ]),
          ),
          const SizedBox(height: 18),
          PrimaryButton('Create account', onTap: _submit, loading: _busy),
        ],
      );
}

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});
  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _email = TextEditingController();
  final _otp = TextEditingController();
  final _pass = TextEditingController();
  bool _sent = false, _busy = false;

  Future<void> _send() async {
    if (!_email.text.contains('@')) return toast(context, 'Enter a valid email', error: true);
    setState(() => _busy = true);
    try {
      final r = await Api.post(Endpoints.forgot, {'email': _email.text.trim()});
      if (!mounted) return;
      if (Api.ok(r)) {
        setState(() => _sent = true);
        toast(context, Api.msg(r, 'We sent a code to your email'));
      } else {
        toast(context, Api.msg(r), error: true);
      }
    } catch (_) {
      if (mounted) toast(context, 'Couldn\'t reach the server.', error: true);
    }
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _reset() async {
    if (_otp.text.trim().isEmpty || _pass.text.length < 6) {
      return toast(context, 'Enter the code and a new password (6+ characters)', error: true);
    }
    setState(() => _busy = true);
    try {
      final r = await Api.post(Endpoints.reset, {'email': _email.text.trim(), 'otp': _otp.text.trim(), 'new_password': _pass.text});
      if (!mounted) return;
      if (Api.ok(r)) {
        toast(context, Api.msg(r, 'Password changed. Please sign in.'));
        Get.back();
      } else {
        toast(context, Api.msg(r), error: true);
      }
    } catch (_) {
      if (mounted) toast(context, 'Couldn\'t reach the server.', error: true);
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) => _AuthFrame(
        back: true,
        title: 'Reset password',
        subtitle: _sent ? 'Enter the code we emailed you' : 'We\'ll email you a code',
        children: [
          Field('Email', controller: _email, icon: Icons.mail_outline_rounded, keyboard: TextInputType.emailAddress, readOnly: _sent),
          if (_sent) ...[
            Field('Code', controller: _otp, icon: Icons.pin_outlined, keyboard: TextInputType.number),
            Field('New password', controller: _pass, icon: Icons.lock_outline_rounded, obscure: true),
          ],
          const SizedBox(height: 18),
          PrimaryButton(_sent ? 'Change password' : 'Send code', onTap: _sent ? _reset : _send, loading: _busy),
        ],
      );
}
