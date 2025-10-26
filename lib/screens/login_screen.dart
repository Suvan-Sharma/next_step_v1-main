import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/email_service.dart';
import 'email_verification_screen.dart';
import 'password_change_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? errorMessage;
  bool _isLoading = false;
  String? _existingEmail;
  bool _showPasswordField = false;

  late final VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/videos/Logo_02.mp4')
      ..setLooping(true)
      ..initialize().then((_) {
        setState(() {
          _initialized = true;
        });
        _controller.play();
      });

    // Load any previously stored email to determine if password field should be shown
    SharedPreferences.getInstance().then((prefs) {
      if (!mounted) return;
      _existingEmail = prefs.getString('email');
      _updatePasswordVisibility();
    });

    // Update password field visibility when email input changes
    _emailController.addListener(_updatePasswordVisibility);
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _updatePasswordVisibility() {
    final String currentEmail = _emailController.text.trim();
    final bool shouldShow = currentEmail.isNotEmpty && _existingEmail == currentEmail;
    if (_showPasswordField != shouldShow) {
      setState(() {
        _showPasswordField = shouldShow;
      });
    }
  }

  Widget _logoVideo() {
    if (!_initialized) return const SizedBox(height: 230);

    return SizedBox(
      height: 230,
      width: double.infinity,
      child: ClipRect(
        child: FittedBox(
          fit: BoxFit.cover,
          alignment: Alignment.center,
          child: SizedBox(
            width: _controller.value.size.width,
            height: _controller.value.size.height,
            child: VideoPlayer(_controller),
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      errorMessage = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    
    // Validate email format
    if (!EmailService.isValidEmail(email)) {
      setState(() {
        errorMessage = 'Please enter a valid email address';
        _isLoading = false;
      });
      return;
    }

    // Check if user exists in SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final existingEmail = prefs.getString('email');
    final existingPassword = prefs.getString('password');
    final needsPasswordChange = prefs.getBool('needsPasswordChange') ?? false;
    final isNewUser = existingEmail != email || existingPassword == null || existingPassword.isEmpty;

    if (isNewUser) {
      // New user - send temporary password via email
      final temporaryPassword = EmailService.generateTemporaryPassword();
      final success = await EmailService.sendTemporaryPassword(email, temporaryPassword);
      
      if (success) {
        // Store temporary password for verification
        await prefs.setString('tempPassword', temporaryPassword);
        await prefs.setString('tempEmail', email);
        
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EmailVerificationScreen(
                userEmail: email,
              ),
            ),
          );
        }
      } else {
        setState(() {
          errorMessage = 'Failed to send email. Please try again.';
        });
      }
    } else if (needsPasswordChange) {
      // User exists but must change password
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PasswordChangeScreen(userEmail: email),
          ),
        );
      }
    } else {
      // Existing user - verify password
      if (existingPassword == password) {
        // Password correct - login
        await prefs.setBool('loggedIn', true);
        await prefs.setString('email', email);
        
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        setState(() {
          errorMessage = 'Invalid email or password';
        });
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  Widget _emailFields() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE9ECEF), width: 1.2),
        boxShadow: const [
          BoxShadow(color: Color(0x12000000), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        child: Column(
          children: [
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: Color(0xFF6B7280)),
                border: InputBorder.none,
                hintText: 'Enter your email address',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                return null;
              },
            ),
            if (_showPasswordField)
              const Divider(height: 1, color: Color(0xFFE9ECEF)),
            if (_showPasswordField)
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Color(0xFF6B7280)),
                  border: InputBorder.none,
                  hintText: 'Enter your password',
                ),
                validator: (value) {
                  if (!_showPasswordField) return null; // no password for new users
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _loginButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1976FF),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Color(0x12000000), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: _isLoading ? null : _login,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isLoading)
                const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              else
                const Icon(Icons.mail_outline, color: Colors.white),
              const SizedBox(width: 12),
              Text(
                _isLoading ? 'Logging in...' : 'Login',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            FocusManager.instance.primaryFocus?.unfocus();
            // Defer navigation to ensure keyboard insets are cleared
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                Navigator.pop(context);
              }
            });
          },
          tooltip: 'Back',
        ),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0), // horizontal padding
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Center(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (!keyboardOpen) _logoVideo(),
                            if (!keyboardOpen) const SizedBox(height: 24),
                            const Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: Colors.black,
                                letterSpacing: -0.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _showPasswordField
                                  ? 'Enter your email and password to continue'
                                  : 'Enter your email to continue',
                              style: const TextStyle(color: Color(0xFF6B7280), fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 28),
                            _emailFields(),
                            const SizedBox(height: 14),
                            if (errorMessage != null)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.red.shade200),
                                ),
                                child: Text(
                                  errorMessage!,
                                  style: TextStyle(color: Colors.red.shade700),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            const SizedBox(height: 24),
                            _loginButton(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
