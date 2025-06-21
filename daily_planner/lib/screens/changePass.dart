import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _currentPassController = TextEditingController();
  final TextEditingController _newPassController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  bool isLoading = false;

   final bool _obscureCurrent = true;
  

  Future<void> _changePassword() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => isLoading = true);
  final user = FirebaseAuth.instance.currentUser;
  final email = user?.email;

  try {
    if (user == null || email == null) {
      throw FirebaseAuthException(
          code: 'user-not-found', message: 'User is not logged in.');
    }

    
    final cred = EmailAuthProvider.credential(
      email: email,
      password: _currentPassController.text.trim(),
    );
    await user.reauthenticateWithCredential(cred);

   
    await user.updatePassword(_newPassController.text.trim());

    
    _currentPassController.clear();
    _newPassController.clear();
    _confirmPassController.clear();

    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Password changed successfully. Please log in again.")),
    );

    await FirebaseAuth.instance.signOut();

    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  } on FirebaseAuthException catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: ${e.message}")),
    );
  } finally {
    if (mounted) setState(() => isLoading = false);
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Change Password")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _currentPassController,
                obscureText: _obscureCurrent,
                
                decoration: const InputDecoration(labelText: "Current Password"),
                validator: (value) =>
                    value == null || value.isEmpty ? "Enter current password" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _newPassController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "New Password"),
                validator: (value) =>
                    value != null && value.length >= 6
                        ? null
                        : "Password must be at least 6 characters",
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPassController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Confirm New Password"),
                validator: (value) =>
                    value == _newPassController.text
                        ? null
                        : "Passwords do not match",
              ),
              const SizedBox(height: 24),
              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      onPressed: _changePassword,
                      icon: const Icon(Icons.lock_reset),
                      label: const Text("Change Password"),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
