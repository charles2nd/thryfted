import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/clerk_providers.dart';
import '../../../core/config/clerk_config.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';

/// Modern Clerk-powered authentication screen
class ClerkAuthScreen extends ConsumerStatefulWidget {
  final AuthMode mode;

  const ClerkAuthScreen({
    super.key,
    this.mode = AuthMode.signIn,
  });

  @override
  ConsumerState<ClerkAuthScreen> createState() => _ClerkAuthScreenState();
}

class _ClerkAuthScreenState extends ConsumerState<ClerkAuthScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  // Email verification
  final _verificationCodeController = TextEditingController();
  bool _showEmailVerification = false;
  String? _signUpId;
  
  // State
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.mode == AuthMode.signIn ? 0 : 1,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _confirmPasswordController.dispose();
    _verificationCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(clerkAuthStateProvider);
    final emailVerification = ref.watch(emailVerificationProvider);

    // Show email verification screen
    if (_showEmailVerification && _signUpId != null) {
      return _buildEmailVerificationScreen();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 40),
              _buildTabBar(),
              const SizedBox(height: 24),
              _buildAuthForm(),
              if (authState.error != null) ...[
                const SizedBox(height: 16),
                _buildErrorMessage(authState.error!),
              ],
              const SizedBox(height: 32),
              _buildSocialSignIn(),
              const SizedBox(height: 24),
              _buildFooterLinks(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.shopping_bag_outlined,
            color: Colors.white,
            size: 40,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Welcome to Thryfted',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Sustainable fashion marketplace',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(24),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        labelColor: Colors.black,
        unselectedLabelColor: Colors.grey,
        tabs: const [
          Tab(text: 'Sign In'),
          Tab(text: 'Sign Up'),
        ],
      ),
    );
  }

  Widget _buildAuthForm() {
    return SizedBox(
      height: 400,
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildSignInForm(),
          _buildSignUpForm(),
        ],
      ),
    );
  }

  Widget _buildSignInForm() {
    final authState = ref.watch(clerkAuthStateProvider);
    
    return Form(
      key: _formKey,
      child: Column(
        children: [
          CustomTextField(
            controller: _emailController,
            label: 'Email',
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _passwordController,
            label: 'Password',
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Sign In',
            onPressed: authState.isLoading ? null : _handleSignIn,
            isLoading: authState.isLoading,
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => context.push('/auth/forgot-password'),
            child: const Text('Forgot your password?'),
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpForm() {
    final authState = ref.watch(clerkAuthStateProvider);
    
    return Form(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _firstNameController,
                  label: 'First Name',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomTextField(
                  controller: _lastNameController,
                  label: 'Last Name',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _emailController,
            label: 'Email',
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _passwordController,
            label: 'Password',
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              }
              if (value.length < 8) {
                return 'Password must be at least 8 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Checkbox(
                value: _acceptTerms,
                onChanged: (value) {
                  setState(() {
                    _acceptTerms = value ?? false;
                  });
                },
              ),
              const Expanded(
                child: Text(
                  'I agree to the Terms of Service and Privacy Policy',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Sign Up',
            onPressed: authState.isLoading || !_acceptTerms ? null : _handleSignUp,
            isLoading: authState.isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildEmailVerificationScreen() {
    final emailVerification = ref.watch(emailVerificationProvider);
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            setState(() {
              _showEmailVerification = false;
              _signUpId = null;
            });
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.email_outlined,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 24),
            Text(
              'Verify your email',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'We sent a verification code to\n${_emailController.text}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),
            CustomTextField(
              controller: _verificationCodeController,
              label: 'Verification Code',
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Verify Email',
              onPressed: emailVerification?.isVerifying == true ? null : _handleEmailVerification,
              isLoading: emailVerification?.isVerifying == true,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                // Resend verification code
                _handleSignUp();
              },
              child: const Text('Resend code'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialSignIn() {
    return Column(
      children: [
        const Row(
          children: [
            Expanded(child: Divider()),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Or continue with'),
            ),
            Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: ClerkConfig.enabledSocialProviders.map((provider) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _buildSocialButton(provider),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSocialButton(String provider) {
    final authState = ref.watch(clerkAuthStateProvider);
    
    return OutlinedButton(
      onPressed: authState.isLoading ? null : () => _handleSocialAuth(provider),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _getSocialIcon(provider),
          const SizedBox(width: 8),
          Text(
            provider.capitalize(),
            style: const TextStyle(color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _getSocialIcon(String provider) {
    switch (provider.toLowerCase()) {
      case 'google':
        return const Icon(Icons.g_mobiledata, color: Colors.red);
      case 'facebook':
        return const Icon(Icons.facebook, color: Colors.blue);
      case 'apple':
        return const Icon(Icons.apple, color: Colors.black);
      default:
        return const Icon(Icons.login);
    }
  }

  Widget _buildErrorMessage(String error) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: const TextStyle(color: Colors.red),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: () {
              ref.read(clerkAuthStateProvider.notifier).clearError();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFooterLinks() {
    return Column(
      children: [
        const Text(
          'By signing up, you agree to our Terms of Service\nand Privacy Policy',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                // Navigate to terms
              },
              child: const Text('Terms'),
            ),
            const Text('•'),
            TextButton(
              onPressed: () {
                // Navigate to privacy
              },
              child: const Text('Privacy'),
            ),
            const Text('•'),
            TextButton(
              onPressed: () {
                // Navigate to help
              },
              child: const Text('Help'),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await ref.read(clerkAuthStateProvider.notifier).signInWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } catch (e) {
      // Error handled by provider
    }
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await ref.read(clerkAuthStateProvider.notifier).signUpWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
      );
    } catch (e) {
      if (e.toString().contains('Email verification required')) {
        // Extract sign up ID and show verification screen
        setState(() {
          _showEmailVerification = true;
          _signUpId = 'temp_signup_id'; // In real implementation, extract from error
        });
        
        ref.read(emailVerificationProvider.notifier).state = EmailVerificationState(
          signUpId: 'temp_signup_id',
          email: _emailController.text.trim(),
        );
      }
    }
  }

  Future<void> _handleEmailVerification() async {
    if (_signUpId == null || _verificationCodeController.text.isEmpty) return;

    try {
      ref.read(emailVerificationProvider.notifier).state = 
          ref.read(emailVerificationProvider)!.copyWith(isVerifying: true);

      await ref.read(clerkAuthStateProvider.notifier).verifyEmailAddress(
        signUpId: _signUpId!,
        code: _verificationCodeController.text.trim(),
      );

      // Verification successful, clear state
      setState(() {
        _showEmailVerification = false;
        _signUpId = null;
      });
      ref.read(emailVerificationProvider.notifier).state = null;
    } catch (e) {
      ref.read(emailVerificationProvider.notifier).state = 
          ref.read(emailVerificationProvider)!.copyWith(
            isVerifying: false,
            error: e.toString(),
          );
    }
  }

  Future<void> _handleSocialAuth(String provider) async {
    try {
      final isSignUp = _tabController.index == 1;
      
      if (isSignUp) {
        await ref.read(clerkAuthStateProvider.notifier).signUpWithSocial(provider);
      } else {
        await ref.read(clerkAuthStateProvider.notifier).signInWithSocial(provider);
      }
    } catch (e) {
      // Error handled by provider
    }
  }
}

enum AuthMode { signIn, signUp }

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}