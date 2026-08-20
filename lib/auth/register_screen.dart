import 'package:flutter/material.dart';

import '../app_validate.dart';
import '../widgets/custom_field.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3FF),

      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        foregroundColor: Colors.white,
        title: const Text("Create Account"),
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
                const SizedBox(height: 20),

                const Icon(
                  Icons.person_add_alt_1,
                  size: 80,
                  color: Colors.deepPurpleAccent,
                ),

                const SizedBox(height: 20),

                const Text(
                  "Create Your Account",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurpleAccent,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  "Register to start managing your tasks",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 30),

                // Name
                CustomFormField(
                  controller: nameController,
                  hintText: "Enter your name",
                  labelText: "Full Name",
                  prefixIcon: Icons.person_outline,
                  keyboardType: TextInputType.name,

                  validator: AppValidator.validateName,
                ),

                const SizedBox(height: 18),

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

                const SizedBox(height: 18),

                // Confirm Password
                CustomFormField(
                  controller: confirmPasswordController,
                  hintText: "Confirm your password",
                  labelText: "Confirm Password",
                  prefixIcon: Icons.lock_reset,
                  obscureText: obscureConfirmPassword,

                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        obscureConfirmPassword =
                        !obscureConfirmPassword;
                      });
                    },

                    icon: Icon(
                      obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                  ),

                  validator: (value) {
                    return AppValidator.validateConfirmPassword(
                      value,
                      passwordController.text,
                    );
                  },
                ),

                const SizedBox(height: 28),

                SizedBox(
                  height: 52,

                  child: ElevatedButton(
                    onPressed: () {
                      if (!formKey.currentState!.validate()) {
                        return;
                      }

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginScreen(
                            registeredName:
                            nameController.text.trim(),

                            registeredEmail:
                            emailController.text.trim(),

                            registeredPassword:
                            passwordController.text,
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
                      "Register",
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
                      "Already have an account? ",
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
                            const LoginScreen(),
                          ),
                        );
                      },

                      child: const Text(
                        "Login",
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
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    super.dispose();
  }
}