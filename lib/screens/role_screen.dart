import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'parent/parent_home_screen.dart';
import 'teacher/teacher_home_screen.dart';
import 'admin/admin_home_screen.dart';

class RoleScreen extends StatefulWidget {
  const RoleScreen({super.key});

  @override
  State<RoleScreen> createState() => _RoleScreenState();
}

class _RoleScreenState extends State<RoleScreen> {
  bool loading = true;

  @override
  void initState() {
    super.initState();
    checkRole();
  }

  Future<void> checkRole() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        return;
      }

      final document = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!document.exists) {
        showError('User profile not found in Firestore.');
        return;
      }

      final data = document.data();

      final role = data?['role'];

      if (!mounted) return;

      if (role == 'parent') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const ParentHomeScreen(),
          ),
        );
      } else if (role == 'teacher') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const TeacherHomeScreen(),
          ),
        );
      } else if (role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const AdminHomeScreen(),
          ),
        );
      } else {
        showError('Invalid user role.');
      }
    } catch (e) {
      showError('Could not load your role.');
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  void showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: loading
            ? const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 15),
            Text('Loading your account...'),
          ],
        )
            : const Text('Unable to load account.'),
      ),
    );
  }
}