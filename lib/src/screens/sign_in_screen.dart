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
  final _controllers = List.generate(6, (_) => TextEditingController());
  final _nodes = List.generate(6, (_) => FocusNode());

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
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                const Text('Sign in', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
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
                        'Use your mobile number to send reports and track updates.',
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
                  const Text('Mobile number', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
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
                  PrimaryButton(
                    label: 'Send Code',
                    trailing: Icons.arrow_forward_rounded,
                    onPressed: () {
                      final digits = store.mobile.replaceAll(RegExp(r'\D'), '');
                      if (digits.length < 10) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Enter a 10-digit mobile number')),
                        );
                        return;
                      }
                      store.sendCode();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SoftCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Enter 6-digit code', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
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
                    children: List.generate(6, (i) {
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
                          onChanged: (v) {
                            if (v.isNotEmpty && i < 5) _nodes[i + 1].requestFocus();
                            if (v.isEmpty && i > 0) _nodes[i - 1].requestFocus();
                            final code = _controllers.map((c) => c.text).join();
                            store.setOtp(code);
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
                              onTap: store.sendCode,
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
                            'Your number is only used to send and track your reports.',
                            style: TextStyle(color: AppColors.ink, height: 1.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
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
          'Enter the mobile number you use with PMC CARE, then type the 6-digit code sent to that number.',
          style: TextStyle(fontSize: 16, height: 1.4),
        ),
      ),
    );
  }
}
