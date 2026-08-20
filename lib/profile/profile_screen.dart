import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

import 'package:taskati/auth/login_screen.dart';

class Profile extends StatefulWidget {
  final String userName;
  final String userEmail;
  const Profile({
    super.key,
    required this.userName,
    required this.userEmail,
  });
  @override
  State<Profile> createState() => _ProfileState();
}
class _ProfileState extends State<Profile> {
  XFile? image;

  Future<void> pickImage(ImageSource source) async {
    if (source == ImageSource.camera) {
      final status = await Permission.camera.request();

      if (!status.isGranted) {
        return;
      }
    }
    final selectedImage = await ImagePicker().pickImage(
      source: source,
    );
    if (selectedImage != null) {
      setState(() {
        image = selectedImage;
      });
    }
  }
  void showImageOptions() {
    showModalBottomSheet(
      context: context,

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),

      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "Choose Profile Picture",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              ListTile(
                leading: const Icon(
                  Icons.camera_alt,
                  color: Colors.deepPurpleAccent,
                ),
                title: const Text("Take Photo"),

                onTap: () {
                  Navigator.pop(context);

                  pickImage(
                    ImageSource.camera,
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: Colors.deepPurpleAccent,
                ),
                title: const Text("Choose from Gallery"),
                onTap: () {
                  Navigator.pop(context);
                  pickImage(
                    ImageSource.gallery,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        foregroundColor: Colors.white,
        title: const Text("Profile"),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),

        child: Column(
          children: [
            const SizedBox(height: 20),

            // Profile Picture
            Stack(
              children: [
                CircleAvatar(
                  radius: 75,

                  backgroundColor:
                  Colors.deepPurple.shade100,

                  backgroundImage: image != null
                      ? FileImage(
                    // ImagePicker returns a path
                    // that works with FileImage
                    File(image!.path),
                  )
                      : null,

                  child: image == null
                      ? const Icon(
                    Icons.person,
                    size: 80,
                    color: Colors.deepPurpleAccent,
                  )
                      : null,
                ),

                Positioned(
                  bottom: 0,
                  right: 0,

                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.deepPurpleAccent,
                    ),

                    child: IconButton(
                      onPressed: showImageOptions,

                      icon: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Name
            Card(
              elevation: 2,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),

              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE9E1FF),

                  child: Icon(
                    Icons.person,
                    color: Colors.deepPurpleAccent,
                  ),
                ),

                title: const Text(
                  "Name",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),

                subtitle: Text(
                  widget.userName,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // Email
            Card(
              elevation: 2,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),

              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE9E1FF),

                  child: Icon(
                    Icons.email_outlined,
                    color: Colors.deepPurpleAccent,
                  ),
                ),

                title: const Text(
                  "Email",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),

                subtitle: Text(
                  widget.userEmail,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,

              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                        (route) => false,
                  );
                },
                icon: const Icon(
                  Icons.logout,
                  color: Colors.red,
                ),
                label: const Text(
                  "Logout",
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                    color: Colors.red,
                  ),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}