import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tadbirio/views/screens/home_screen/home_screen.dart';
import 'package:tadbirio/views/screens/registration_screen/sign_up_screen.dart';
import 'package:tadbirio/views/widgets/registration/show_error.dart';
import 'package:tadbirio/views/widgets/registration/submit_button.dart';
import 'package:tadbirio/views/widgets/registration/text_feild.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;
  bool _isLoading = false;

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });

      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (userDoc.exists) {
          String name = userDoc.get('name');
          String surname = userDoc.get('surname');
          String imageUrl = userDoc.get('image_url');
          String email = userDoc.get('email');

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('name', name);
          await prefs.setString('surname', surname);
          await prefs.setString('image_url', imageUrl);
          await prefs.setString('email', email);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const HomeScreen(),
            ),
          );
        } else {
          showErrorDialog("User data not found", context);
        }
      } on FirebaseAuthException catch (e) {
        String message = e.message!;
        showErrorDialog(message, context);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _showInfoDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xff041955),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        title: const Text(
          "Info",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white70,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: ButtonStyle(
              overlayColor: WidgetStateProperty.all(
                Colors.white.withOpacity(0.1),
              ),
            ),
            child: const Text(
              "OK",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendPasswordResetEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      showErrorDialog(
          'Iltimos, parolingizni tiklash uchun elektron pochtangizni kiriting.',
          context);
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _showInfoDialog(
          'Parolni tiklash elektron pochtasi yuborildi. Pochtangizni tekshiring.');
    } on FirebaseAuthException catch (e) {
      showErrorDialog(e.message!, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.teal,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "T A D B I R O",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Gap(50),
                      const Text(
                        "Tizimga kirish",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Gap(20),
                      TextFieldWidget(
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        controller: _emailController,
                        hintText: "Email or User Name",
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const Gap(10),
                      TextFieldWidget(
                        icon: Icons.password_outlined,
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: _obscureText,
                        controller: _passwordController,
                        suffixIcon: GestureDetector(
                          onTap: _togglePasswordVisibility,
                          child: Icon(
                            _obscureText
                                ? CupertinoIcons.eye
                                : CupertinoIcons.eye_slash,
                            color: const Color(0xff041955),
                          ),
                        ),
                        hintText: 'Password',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Enter something';
                          }
                          if (value.length < 8) {
                            return "Password must be at least 8 characters long";
                          }
                          return null;
                        },
                      ),
                      const Gap(10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: _sendPasswordResetEmail,
                            child: const Text(
                              "Forget Password?",
                              style: TextStyle(
                                color: Color(0xff041955),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Gap(30),
                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : SubmitButton(
                              text: 'Sign in',
                              onTap: _submit,
                            ),
                      const Gap(10),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignUpScreen(),
                            ),
                          );
                        },
                        child: const Text("Ro'yxatdan o'tish"),
                      )
                    ],
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
