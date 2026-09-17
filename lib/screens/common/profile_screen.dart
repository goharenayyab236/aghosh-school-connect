import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isLoading = true;

  String name = 'Loading...';
  String email = '';
  String phone = '';
  String role = '';

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      final document = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (document.exists) {
        final data = document.data();

        setState(() {
          name = data?['name'] ?? 'No name';
          email = data?['email'] ?? user.email ?? '';
          phone = data?['phone'] ?? '';
          role = data?['role'] ?? '';
          isLoading = false;
        });
      } else {
        setState(() {
          name = 'Profile not found';
          email = user.email ?? '';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.of(context).popUntil(
          (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),

            const CircleAvatar(
              radius: 50,
              child: Icon(
                Icons.person,
                size: 55,
              ),
            ),

            const SizedBox(height: 15),

            Text(
              name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              role.isEmpty
                  ? 'Parent'
                  : role.toUpperCase(),
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 30),

            _profileItem(
              icon: Icons.person,
              title: 'Full Name',
              value: name,
            ),

            _profileItem(
              icon: Icons.email,
              title: 'Email',
              value: email,
            ),

            _profileItem(
              icon: Icons.phone,
              title: 'Phone',
              value: phone.isEmpty
                  ? 'Not provided'
                  : phone,
            ),

            _profileItem(
              icon: Icons.badge,
              title: 'Role',
              value: role.isEmpty
                  ? 'Parent'
                  : role,
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: logout,
                icon: const Icon(Icons.logout),
                label: const Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.grey,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}