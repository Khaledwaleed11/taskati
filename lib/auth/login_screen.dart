import 'package:flutter/material.dart';
import 'package:taskati/auth/register_screen.dart';

import '../app_validate.dart';
import '../home/home_screen.dart';
import '../widgets/custom_field.dart';

class LoginScreen extends StatefulWidget {
  final String? registeredName;
  final String? registeredEmail;
  final String? registeredPassword;

  const LoginScreen({
    super.key,
    this.registeredName,
    this.registeredEmail,
    this.registeredPassword,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3FF),

      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        foregroundColor: Colors.white,
        title: const Text("Login"),
        centerTitle: true,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),

          child: Form(
            key: formKey,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 30),

                const Icon(
                  Icons.task_alt,
                  size: 90,
                  color: Colors.deepPurpleAccent,
                ),

                const SizedBox(height: 20),

                const Text(
                  "Welcome Back!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurpleAccent,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  "Login to continue to Taskatii",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 35),

                // Email
                CustomFormField(
                  controller: emailController,
                  hintText: "Enter your email",
                  labelText: "Email",
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,

                  validator: AppValidator.validateEmail,
                ),

                const SizedBox(height: 18),

                // Password
                CustomFormField(
                  controller: passwordController,
                  hintText: "Enter your password",
                  labelText: "Password",
                  prefixIcon: Icons.lock_outline,
                  obscureText: obscurePassword,

                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },

                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                  ),

                  validator: AppValidator.validatePassword,
                ),

                const SizedBox(height: 28),

                SizedBox(
                  height: 52,

                  child: ElevatedButton(
                    onPressed: () {
                      if (!formKey.currentState!.validate()) {
                        return;
                      }

                      // لو المستخدم جاي من Register
                      if (widget.registeredEmail != null) {
                        if (emailController.text.trim() !=
                            widget.registeredEmail ||
                            passwordController.text !=
                                widget.registeredPassword) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Email or password is incorrect",
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );

                          return;
                        }
                      }

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomeScreen(
                            userName:
                            widget.registeredName ?? "User",
                            userEmail:
                            emailController.text.trim(),
                          ),
                        ),
                      );
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent,
                      foregroundColor: Colors.white,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),

                    child: const Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),

                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                            const RegisterScreen(),
                          ),
                        );
                      },

                      child: const Text(
                        "Register",
                        style: TextStyle(
                          color: Colors.deepPurpleAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }
}