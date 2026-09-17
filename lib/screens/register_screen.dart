import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
const RegisterScreen({super.key});

@override
State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
final nameController = TextEditingController();
final emailController = TextEditingController();
final phoneController = TextEditingController();
final passwordController = TextEditingController();

String selectedRole = 'parent';

bool isLoading = false;
bool obscurePassword = true;

Future<void> register() async {
// Check empty fields
if (nameController.text.trim().isEmpty ||
emailController.text.trim().isEmpty ||
phoneController.text.trim().isEmpty ||
passwordController.text.trim().isEmpty) {
showMessage('Please fill in all fields.');
return;
}

// Check password length
if (passwordController.text.trim().length < 6) {
showMessage('Password must be at least 6 characters.');
return;
}

setState(() {
isLoading = true;
});

try {
// Create Firebase Authentication account
UserCredential userCredential =
await FirebaseAuth.instance.createUserWithEmailAndPassword(
email: emailController.text.trim(),
password: passwordController.text.trim(),
);

final User? user = userCredential.user;

if (user == null) {
showMessage('Firebase could not create the user.');
return;
}

// Create user document in Firestore
await FirebaseFirestore.instance
    .collection('users')
    .doc(user.uid)
    .set({
'uid': user.uid,
'name': nameController.text.trim(),
'email': emailController.text.trim(),
'phone': phoneController.text.trim(),
'role': selectedRole,
'createdAt': FieldValue.serverTimestamp(),
});

if (!mounted) return;

showMessage('Account created successfully!');

// Go back to Login screen
Navigator.pop(context);
} on FirebaseAuthException catch (e) {
// Show the actual Firebase Authentication error
String message;

switch (e.code) {
case 'email-already-in-use':
message = 'This email is already registered.';
break;

case 'invalid-email':
message = 'The email address is not valid.';
break;

case 'weak-password':
message = 'Password is too weak. Use at least 6 characters.';
break;

case 'operation-not-allowed':
message =
'Email/password authentication is not enabled in Firebase.';
break;

case 'network-request-failed':
message =
'Network error. Please check your internet connection.';
break;

case 'too-many-requests':
message =
'Too many attempts. Please wait and try again.';
break;

default:
message = 'Firebase Auth error: ${e.code}\n${e.message}';
}

showMessage(message);
} on FirebaseException catch (e) {
// Firestore or another Firebase error
showMessage(
'Firebase error:\n${e.code}\n${e.message}',
);
} catch (e) {
// Any other unexpected error
showMessage(
'Unexpected error:\n$e',
);
} finally {
if (mounted) {
setState(() {
isLoading = false;
});
}
}
}

void showMessage(String message) {
if (!mounted) return;

ScaffoldMessenger.of(context).hideCurrentSnackBar();

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(message),
duration: const Duration(seconds: 5),
),
);
}

@override
void dispose() {
nameController.dispose();
emailController.dispose();
phoneController.dispose();
passwordController.dispose();
super.dispose();
}

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: const Text('Create Account'),
centerTitle: true,
),
body: SafeArea(
child: SingleChildScrollView(
padding: const EdgeInsets.all(24),
child: Column(
crossAxisAlignment: CrossAxisAlignment.stretch,
children: [
const Icon(
Icons.person_add,
size: 70,
color: Colors.blue,
),

const SizedBox(height: 20),

const Text(
'Create Account',
textAlign: TextAlign.center,
style: TextStyle(
fontSize: 28,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 8),

const Text(
'Create your Aghosh School Connect account',
textAlign: TextAlign.center,
style: TextStyle(
color: Colors.grey,
),
),

const SizedBox(height: 30),

// NAME
TextField(
controller: nameController,
textInputAction: TextInputAction.next,
decoration: const InputDecoration(
labelText: 'Full Name',
hintText: 'Enter your full name',
prefixIcon: Icon(Icons.person),
border: OutlineInputBorder(),
),
),

const SizedBox(height: 16),

// EMAIL
TextField(
controller: emailController,
keyboardType: TextInputType.emailAddress,
textInputAction: TextInputAction.next,
decoration: const InputDecoration(
labelText: 'Email',
hintText: 'Enter your email',
prefixIcon: Icon(Icons.email),
border: OutlineInputBorder(),
),
),

const SizedBox(height: 16),

// PHONE
TextField(
controller: phoneController,
keyboardType: TextInputType.phone,
textInputAction: TextInputAction.next,
decoration: const InputDecoration(
labelText: 'Phone Number',
hintText: 'Enter your phone number',
prefixIcon: Icon(Icons.phone),
border: OutlineInputBorder(),
),
),

const SizedBox(height: 16),

// ROLE
DropdownButtonFormField<String>(
value: selectedRole,
decoration: const InputDecoration(
labelText: 'Select Role',
prefixIcon: Icon(Icons.people),
border: OutlineInputBorder(),
),
items: const [
DropdownMenuItem(
value: 'parent',
child: Text('Parent'),
),
DropdownMenuItem(
value: 'teacher',
child: Text('Teacher'),
),
DropdownMenuItem(
value: 'admin',
child: Text('Admin'),
),
],
onChanged: (value) {
if (value != null) {
setState(() {
selectedRole = value;
});
}
},
),

const SizedBox(height: 16),

// PASSWORD
TextField(
controller: passwordController,
obscureText: obscurePassword,
textInputAction: TextInputAction.done,
decoration: InputDecoration(
labelText: 'Password',
hintText: 'Enter at least 6 characters',
prefixIcon: const Icon(Icons.lock),
border: const OutlineInputBorder(),
suffixIcon: IconButton(
icon: Icon(
obscurePassword
? Icons.visibility
    : Icons.visibility_off,
),
onPressed: () {
setState(() {
obscurePassword = !obscurePassword;
});
},
),
),
),

const SizedBox(height: 25),

// REGISTER BUTTON
SizedBox(
height: 52,
child: ElevatedButton(
onPressed: isLoading ? null : register,
child: isLoading
? const SizedBox(
height: 24,
width: 24,
child: CircularProgressIndicator(
strokeWidth: 2,
),
)
    : const Text(
'Create Account',
style: TextStyle(
fontSize: 17,
),
),
),
),

const SizedBox(height: 20),

// BACK TO LOGIN
TextButton(
onPressed: isLoading
? null
    : () {
Navigator.pop(context);
},
child: const Text(
'Already have an account? Login',
),
),
],
),
),
),
);
}
}
