import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/email_service.dart';
import 'password_change_screen.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String userEmail;

  const EmailVerificationScreen({
    Key? key,
    required this.userEmail,
  }) : super(key: key);

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final TextEditingController _codeController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  String? _temporaryPassword;
  bool _isLoading = false;
  bool _isResending = false;
  String? _errorMessage;
  int _resendCountdown = 0;
  bool _showPasswordFields = false;

  @override
  void initState() {
    super.initState();
    _loadOrSendVerificationCode();
    _startResendCountdown();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _loadOrSendVerificationCode() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final prefs = await SharedPreferences.getInstance();
    final storedEmail = prefs.getString('tempEmail');
    final storedTemp = prefs.getString('tempPassword');

    if (storedEmail == widget.userEmail && storedTemp != null && storedTemp.isNotEmpty) {
      _temporaryPassword = storedTemp;
      setState(() {
        _showPasswordFields = true;
        _isLoading = false;
      });
      return;
    }

    _temporaryPassword = EmailService.generateTemporaryPassword();
    await prefs.setString('tempPassword', _temporaryPassword!);
    await prefs.setString('tempEmail', widget.userEmail);

    final success = await EmailService.sendTemporaryPassword(widget.userEmail, _temporaryPassword!);
    
    if (success) {
      setState(() {
        _showPasswordFields = true;
      });
    } else {
      setState(() {
        _errorMessage = 'Failed to send email. Please try again.';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _startResendCountdown() {
    setState(() {
      _resendCountdown = 60; // 60 seconds countdown
    });
    
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          _resendCountdown--;
        });
        return _resendCountdown > 0;
      }
      return false;
    });
  }

  Future<void> _resendCode() async {
    if (_resendCountdown > 0) return;
    
    setState(() {
      _isResending = true;
      _errorMessage = null;
    });

    final prefs = await SharedPreferences.getInstance();
    _temporaryPassword = EmailService.generateTemporaryPassword();
    await prefs.setString('tempPassword', _temporaryPassword!);
    await prefs.setString('tempEmail', widget.userEmail);
    await EmailService.sendTemporaryPassword(widget.userEmail, _temporaryPassword!);
    _startResendCountdown();

    setState(() {
      _isResending = false;
    });
  }

  Future<void> _verifyAndProceed() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Verify code
    if (_codeController.text.trim() != _temporaryPassword) {
      setState(() {
        _errorMessage = 'Incorrect verification code';
        _isLoading = false;
      });
      return;
    }

    // Save user session and proceed to password change
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('loggedIn', true);
    await prefs.setString('email', widget.userEmail);
    await prefs.setString('temporaryPassword', _temporaryPassword!);
    await prefs.setBool('needsPasswordChange', true);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PasswordChangeScreen(userEmail: widget.userEmail),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                
                // Header
                const Text(
                  'Verify Your Email',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'We\'ve sent a 6-digit verification code to ${widget.userEmail}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 40),

                // Code field
                if (_showPasswordFields) ...[
                  _buildCodeField(),
                  const SizedBox(height: 20),
                ],

                // Error Message
                if (_errorMessage != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red.shade700),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Verify Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _verifyAndProceed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Continue',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                // Resend Code Button
                Center(
                  child: TextButton(
                    onPressed: _resendCountdown > 0 || _isResending ? null : _resendCode,
                    child: _isResending
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            _resendCountdown > 0
                                ? 'Resend in ${_resendCountdown}s'
                                : 'Resend Code',
                            style: TextStyle(
                              color: _resendCountdown > 0 ? Colors.grey : Colors.blue,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 40),

                // Help Text
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue.shade700,
                        size: 24,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Check your email for the 6-digit code. You\'ll be asked to set your password after verification.',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildCodeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Verification Code',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _codeController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: InputDecoration(
            counterText: '',
            hintText: 'Enter 6-digit code',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the code';
            }
            if (value.length != 6 || int.tryParse(value) == null) {
              return 'Enter a valid 6-digit code';
            }
            return null;
          },
        ),
      ],
    );
  }
}
