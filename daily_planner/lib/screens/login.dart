// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:daily_planner/screens/home.dart';
// import 'package:daily_planner/screens/signup.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});

//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _isPasswordVisible = false;

//   Future<void> loginUser() async {
//     if (!_formKey.currentState!.validate()) return;

//     try {
//       final userCredential = await FirebaseAuth.instance
//           .signInWithEmailAndPassword(
//             email: _emailController.text.trim(),
//             password: _passwordController.text.trim(),
//           );

//       final userDoc =
//           await FirebaseFirestore.instance
//               .collection('users')
//               .doc(userCredential.user!.uid)
//               .get();

//       String fullName = userDoc.data()?['fullName'] ?? 'User';

//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Welcome, $fullName!')));

//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => const MyHome()),
//       );
//     } on FirebaseAuthException catch (e) {
//       String message = 'Login failed';
//       if (e.code == 'user-not-found') {
//         message = 'No user found for that email.';
//       } else if (e.code == 'wrong-password') {
//         message = 'Incorrect password.';
//       }
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text(message)));
//     } catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('Something went wrong.')));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       body: Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 24),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               children: [
//                 const Icon(
//                   Icons.lock_outline,
//                   size: 100,
//                   color: Colors.blueAccent,
//                 ),
//                 const SizedBox(height: 20),
//                 const Text(
//                   'Welcome Back!',
//                   style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 30),

//                 // Email
//                 TextFormField(
//                   controller: _emailController,
//                   decoration: InputDecoration(
//                     labelText: 'Email',
//                     prefixIcon: const Icon(Icons.email_outlined),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   keyboardType: TextInputType.emailAddress,
//                   validator:
//                       (value) =>
//                           value != null && value.contains('@')
//                               ? null
//                               : 'Enter a valid email',
//                 ),
//                 const SizedBox(height: 16),

//                 // Password
//                 TextFormField(
//                   controller: _passwordController,
//                   obscureText: !_isPasswordVisible,
//                   decoration: InputDecoration(
//                     labelText: 'Password',
//                     prefixIcon: const Icon(Icons.lock_outline),
//                     suffixIcon: IconButton(
//                       icon: Icon(
//                         _isPasswordVisible
//                             ? Icons.visibility
//                             : Icons.visibility_off,
//                       ),
//                       onPressed: () {
//                         setState(() {
//                           _isPasswordVisible = !_isPasswordVisible;
//                         });
//                       },
//                     ),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   validator:
//                       (value) =>
//                           value != null && value.length >= 6
//                               ? null
//                               : 'Password too short',
//                 ),
//                 const SizedBox(height: 24),

//                 // Login Button
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       backgroundColor: Colors.blueAccent,
//                     ),
//                     onPressed: () async {
//                       FocusScope.of(context).unfocus(); // Hide keyboard
//                       await loginUser(); // Wait for login to complete
//                     },
//                     child: const Text('Login', style: TextStyle(fontSize: 16)),
//                   ),
//                 ),

//                 const SizedBox(height: 12),
//                 TextButton(
//                   onPressed: () {
//                     Navigator.pushNamed(context, "/forgotpass");
//                   },
//                   child: const Text('Forgot Password?'),
//                 ),

//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Text("Don't have an account?"),
//                     TextButton(
//                       onPressed: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => const SignupPage(),
//                           ),
//                         );
//                       },
//                       child: const Text("Sign Up"),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }



import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daily_planner/screens/home.dart';
import 'package:daily_planner/screens/signup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  Future<void> loginUser() async {
    if (!_formKey.currentState!.validate()) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logging in...'), duration: Duration(seconds: 2)),
    );

    try {
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // If login is successful, the old session is effectively replaced
      // Now, fetch user data from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      String fullName = userDoc.data()?['fullName'] ?? 'User';

      ScaffoldMessenger.of(context).hideCurrentSnackBar(); // Hide "Logging in..."
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Welcome, $fullName!')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MyHome()),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar(); // Hide any current snackbar

      String message = 'Login failed.';
      if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        message = 'Incorrect password. Please try again.';
      } else if (e.code == 'invalid-email') {
        message = 'The email address is not valid.';
      } else if (e.code == 'invalid-credential') {
        message = 'Invalid login credentials. Please check your email and password.';
      }
      

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar(); 
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An unexpected error occurred. Please try again.')),
      );
      print('Unexpected error during login: $e'); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Icon(
                  Icons.lock_outline,
                  size: 100,
                  color: Colors.blueAccent,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Welcome Back!',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),

                // Email
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) =>
                      value != null && value.contains('@') && value.endsWith('.com')
                          ? null
                          : 'Enter a valid email (e.g., example@domain.com)', 
                ),
                const SizedBox(height: 16),

                // Password
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) =>
                      value != null && value.length >= 6
                          ? null
                          : 'Password must be at least 6 characters long', 
                ),
                const SizedBox(height: 24),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white, 
                    ),
                    onPressed: () async {
                      FocusScope.of(context).unfocus(); // Hide keyboard
                      await loginUser(); // Wait for login to complete
                    },
                    child: const Text('Login', style: TextStyle(fontSize: 16)),
                  ),
                ),

                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, "/forgotpass");
                  },
                  child: const Text('Forgot Password?'),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignupPage(),
                          ),
                        );
                      },
                      child: const Text("Sign Up"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}