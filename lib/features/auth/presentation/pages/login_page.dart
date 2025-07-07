import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../bloc/privacy_policy_bloc.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/privacy_policy_modal.dart';
import 'package:test_cbo/core/presentation/widgets/shimmer_button_loading.dart';
import '../widgets/custom_checkbox.dart';
import 'package:test_cbo/core/presentation/theme/app_theme.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      resizeToAvoidBottomInset: true,
      body: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => PrivacyPolicyBloc()),
        ],
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppTheme.getErrorColor(context),
                ),
              );
            } else if (state is AuthAuthenticated) {
              Navigator.pushReplacementNamed(context, '/dashboard');
            }
          },
          builder: (context, state) {
            return BlocBuilder<PrivacyPolicyBloc, PrivacyPolicyState>(
              builder: (context, privacyState) {
                return Stack(
                  children: [
                    SafeArea(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.05),
                              Image.asset(
                                'assets/images/mazta_logo.png',
                                width: 120,
                                height: 120,
                              ),
                              const SizedBox(height: 60),
                              Text(
                                'Selamat Datang',
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.getPrimaryTextColor(context),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Silakan masuk untuk melanjutkan',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color:
                                      AppTheme.getSecondaryTextColor(context),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 30),
                              Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    CustomTextField(
                                      controller: _emailController,
                                      labelText: 'Email',
                                      hintText: 'Masukkan email Anda',
                                      prefixIcon: Icons.email_outlined,
                                      keyboardType: TextInputType.emailAddress,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Email tidak boleh kosong';
                                        }
                                        if (!RegExp(
                                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                            .hasMatch(value)) {
                                          return 'Masukkan email yang valid';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    CustomTextField(
                                      controller: _passwordController,
                                      labelText: 'Password',
                                      hintText: 'Masukkan password Anda',
                                      prefixIcon: Icons.lock_outline,
                                      obscureText: !_isPasswordVisible,
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _isPasswordVisible
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                          color: AppTheme.getSecondaryTextColor(
                                              context),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _isPasswordVisible =
                                                !_isPasswordVisible;
                                          });
                                        },
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Password tidak boleh kosong';
                                        }
                                        if (value.length < 6) {
                                          return 'Password minimal 6 karakter';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              // Privacy Policy Checkbox
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 4),
                                decoration: BoxDecoration(
                                  color:
                                      AppTheme.getCardBackgroundColor(context),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: AppTheme.getBorderColor(context)),
                                ),
                                child: Row(
                                  children: [
                                    const SizedBox(width: 8),
                                    CustomCheckbox(
                                      value: privacyState.isAgreed,
                                      onChanged: (value) {
                                        context.read<PrivacyPolicyBloc>().add(
                                              PrivacyPolicyAgreedChanged(
                                                  value ?? false),
                                            );
                                        if (value ?? false) {
                                          context.read<PrivacyPolicyBloc>().add(
                                                const PrivacyPolicyModalVisibilityChanged(
                                                    true),
                                              );
                                        }
                                      },
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          context.read<PrivacyPolicyBloc>().add(
                                                const PrivacyPolicyModalVisibilityChanged(
                                                    true),
                                              );
                                        },
                                        child: Text(
                                          'Saya menyetujui Kebijakan Privasi',
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            color: AppTheme.getPrimaryTextColor(
                                                context),
                                            height: 1.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: (state is AuthLoading ||
                                        !privacyState.isAgreed)
                                    ? null
                                    : () {
                                        if (_formKey.currentState!.validate()) {
                                          context.read<AuthBloc>().add(
                                                LoginEvent(
                                                  email: _emailController.text,
                                                  password:
                                                      _passwordController.text,
                                                ),
                                              );
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryColor,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 0,
                                ),
                                child: state is AuthLoading
                                    ? const ShimmerButtonLoading()
                                    : Text(
                                        'Masuk',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                      ),
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (privacyState.isModalVisible) const PrivacyPolicyModal(),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
