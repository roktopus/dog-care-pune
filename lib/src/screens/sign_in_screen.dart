import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../main.dart';
import '../theme.dart';
import '../widgets.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _controllers = List.generate(4, (_) => TextEditingController());
  final _nodes = List.generate(4, (_) => FocusNode());

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: FitScroll(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                const Text('Sign In', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const LogoMark(size: 48),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Dog Help Pune', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                      Text(
                        'A PMC CARE account is required before you can use this app.',
                        style: TextStyle(color: AppColors.muted, fontSize: 13, height: 1.3),
                      ),
                    ],
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset('assets/images/hero_dog.png', width: 92, height: 72, fit: BoxFit.cover),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SoftCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Mobile Number', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFD7E0DC)),
                    ),
                    child: Row(
                      children: [
                        const Text('🇮🇳', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        const Text('+91', style: TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Enter mobile number',
                            ),
                            onChanged: (v) => store.mobile = v,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (!store.needsPmcAccount)
                    PrimaryButton(
                      label: store.busy ? 'Checking…' : 'Continue',
                      trailing: Icons.arrow_forward_rounded,
                      onPressed: store.busy
                          ? null
                          : () async {
                              final message = await store.requestCode();
                              if (!context.mounted) return;
                              if (store.needsPmcAccount) {
                                await openPmcRegistration(context);
                              }
                              if (!context.mounted || message == null) return;
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
                            },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (store.needsPmcAccount)
              SoftCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('PMC CARE Account Required', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    const SizedBox(height: 6),
                    const Text(
                      'This number is not registered. Create the account on PMC’s website with this mobile number and your name. Dog Help Pune stays locked until PMC confirms the account.',
                      style: TextStyle(color: AppColors.muted, height: 1.35),
                    ),
                    const SizedBox(height: 12),
                    PrimaryButton(
                      label: 'Create PMC CARE account',
                      trailing: Icons.open_in_new,
                      onPressed: () => openPmcRegistration(context),
                    ),
                    const SizedBox(height: 8),
                    OutlineButton(
                      label: store.busy ? 'Checking…' : 'I’ve registered — check again',
                      onPressed: () async {
                        if (store.busy) return;
                        final message = await store.requestCode();
                        if (!context.mounted) return;
                        if (store.needsPmcAccount) await openPmcRegistration(context);
                        if (!context.mounted || message == null) return;
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
                      },
                    ),
                  ],
                ),
              )
            else if (store.codeSent)
            SoftCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Enter 4-Digit Code', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(
                    store.codeSent
                        ? 'We’ve sent a code to +91 ${store.mobile}'
                        : 'We’ll send a code after you enter your mobile number.',
                    style: const TextStyle(color: AppColors.muted, fontSize: 13),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(4, (i) {
                      return SizedBox(
                        width: 44,
                        height: 52,
                        child: TextField(
                          controller: _controllers[i],
                          focusNode: _nodes[i],
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: InputDecoration(
                            counterText: '',
                            filled: true,
                            fillColor: const Color(0xFFF7F8F7),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE3E8E5)),
                            ),
                          ),
                          onChanged: (v) async {
                            if (v.isNotEmpty && i < 3) _nodes[i + 1].requestFocus();
                            if (v.isEmpty && i > 0) _nodes[i - 1].requestFocus();
                            final code = _controllers.map((c) => c.text).join();
                            if (code.length != 4) return;
                            final message = await store.verifyCode(code);
                            if (!context.mounted) return;
                            if (message != null) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
                              return;
                            }
                            Navigator.pop(context);
                          },
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text.rich(
                      TextSpan(
                        style: const TextStyle(color: AppColors.muted),
                        children: [
                          const TextSpan(text: 'Didn’t receive the code? '),
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: store.busy ? null : () => store.requestCode(),
                              child: const Text(
                                'Resend code',
                                style: TextStyle(
                                  color: AppColors.teal,
                                  fontWeight: FontWeight.w700,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.mint,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.verified_user_outlined, color: AppColors.green),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'The app opens only after PMC CARE accepts this number and the 4-digit code.',
                            style: TextStyle(color: AppColors.ink, height: 1.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const _HelpStub()),
                ),
                child: const Text(
                  'Need help?',
                  style: TextStyle(
                    color: AppColors.teal,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }
}

class _HelpStub extends StatelessWidget {
  const _HelpStub();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help')),
      body: const Padding(
        padding: EdgeInsets.all(20),
        child: Text(
          'Dog Help Pune requires a PMC CARE account. Register on PMC’s website if this number is new, then enter the 4-digit code PMC sends.',
          style: TextStyle(fontSize: 16, height: 1.4),
        ),
      ),
    );
  }
}
