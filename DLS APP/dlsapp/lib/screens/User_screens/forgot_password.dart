import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  Future<void> _sendPasswordResetEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );

      setState(() => _emailSent = true);
      Fluttertoast.showToast(
        msg: "Password reset email sent! Check your inbox",
        backgroundColor: Colors.green,
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Error sending reset email";
      if (e.code == 'user-not-found') {
        errorMessage = "No account found with this email";
      } else {
        errorMessage = e.message ?? errorMessage;
      }
      
      Fluttertoast.showToast(
        msg: errorMessage,
        backgroundColor: Colors.red,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Need Help?'),
        content: const Text(
          'If you\'re having trouble resetting your password, please contact our support team at umerm7783@gmail.com',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text(
                _emailSent ? 'Check Your Email' : 'Reset Your Password',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: const Color(0xFF6A1B9A),
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                _emailSent
                    ? 'We\'ve sent password reset instructions to your email'
                    : 'Enter your email to receive a password reset link',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.black54,
                    ),
              ),
              const SizedBox(height: 32),
              
              if (!_emailSent) ...[
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
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
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _sendPasswordResetEmail,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : const Text('Send Reset Link'),
                  ),
                ),
              ],
              
              if (_emailSent) ...[
                const Icon(
                  Icons.mark_email_read_outlined,
                  size: 80,
                  color: Color(0xFF6A1B9A),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Color(0xFF6A1B9A)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Return to Login',
                      style: TextStyle(color: Color(0xFF6A1B9A)),
                    ),
                  ),
                ),
              ],
              const Spacer(),
              Center(
                child: TextButton(
                  onPressed: () {
                    if (_emailSent) {
                      _emailController.clear();
                      setState(() => _emailSent = false);
                    } else {
                      _showHelpDialog(context); // Show help dialog when "Need help?" is pressed
                    }
                  },
                  child: Text(
                    _emailSent ? 'Resend Email' : 'Need help?',
                    style: const TextStyle(color: Color(0xFF6A1B9A)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}