import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:tadbirio/views/screens/registration_screen/login_screen.dart';
import 'package:tadbirio/views/screens/registration_screen/user_input_info.dart';
import 'package:tadbirio/views/widgets/registration/show_error.dart';
import 'package:tadbirio/views/widgets/registration/submit_button.dart';
import 'package:tadbirio/views/widgets/registration/text_feild.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordCheckController =
      TextEditingController();

  bool _obscureText = true;
  bool _isLoading = false;

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        String uid = userCredential.user!.uid;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => UserInputInfo(
              email: _emailController.text,
              uid: uid,
            ),
          ),
          (route) => false,
        );
      } on FirebaseAuthException catch (e) {
        String message = e.message ?? "An error occurred";
        if (e.code == 'email-already-in-use') {
          message = "Email already exists";
        }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
          ),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Gap(50),
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
                      "Ro'yxatdan o'tish",
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
                      hintText: "Email",
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
                      icon: Icons.password,
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
                    TextFieldWidget(
                      icon: Icons.password,
                      obscureText: _obscureText,
                      controller: _passwordCheckController,
                      suffixIcon: GestureDetector(
                        onTap: _togglePasswordVisibility,
                        child: Icon(
                          _obscureText
                              ? CupertinoIcons.eye
                              : CupertinoIcons.eye_slash,
                          color: const Color(0xff041955),
                        ),
                      ),
                      hintText: "Confirm Password",
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != _passwordController.text) {
                          return "Passwords do not match";
                        }
                        return null;
                      },
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
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      child: const Text("Tizimga kirish"),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
