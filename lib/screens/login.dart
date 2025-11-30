import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:phone_app/screens/Favourite.dart';
import 'package:phone_app/screens/Users_list.dart';
import 'package:phone_app/screens/home.dart';
import 'package:provider/provider.dart';
import 'profile_screen.dart';
import 'package:phone_app/Statemangement/AuthProvider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final locationController = TextEditingController();
  final usernameController = TextEditingController();

  final List<String> _genders = ['Male', 'Female', 'Other'];
  String? _selectedGender;

  bool _isLogin = false;
  final _formKey = GlobalKey<FormState>();
  void _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    print("Form valid: $isValid");
    if (!isValid) return;

    final authProvider = Provider.of<AuthProviderS>(context, listen: false);

    if (_isLogin) {
      print("Trying to log in...");
      await authProvider.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );
      print("Login complete");

      if (authProvider.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authProvider.error!)),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MyHomePage()),
        );
      }
    } else {
      print("Trying to sign up...");
      await authProvider.signup(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        name: usernameController.text.trim(),
        location: locationController.text.trim(),
        gender: _selectedGender ?? "",
      );
      print(
          "${emailController.text.trim()}, ${usernameController.text.trim()},${locationController.text.trim()}, ${_selectedGender}");
      print("Signup complete");

      if (authProvider.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authProvider.error!)),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MyHomePage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEAE6E3),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Container(
            padding: EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Color(0xFFF8F3F3),
              borderRadius: BorderRadius.circular(32.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8.0),
                Center(
                  child: Text(
                    "Welcome To The App",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF464545),
                    ),
                  ),
                ),
                SizedBox(height: 24.0),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!_isLogin) ...[
                        SizedBox(height: 16.0),
                        Text("Username", style: labelStyle()),
                        buildTextField(usernameController, "Username", (value) {
                          if (value == null || value.trim().length < 3) {
                            return "Username must be at least 3 characters";
                          }
                          return null;
                        }),
                        SizedBox(height: 16.0),
                        Row(
                          children: [
                            // LOCATION FIELD
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Location", style: labelStyle()),
                                  buildTextField(locationController, "Location",
                                      (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return "Location is required";
                                    }
                                    return null;
                                  }),
                                ],
                              ),
                            ),

                            SizedBox(width: 16.0),

                            // GENDER DROPDOWN
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Gender", style: labelStyle()),
                                  DropdownButtonFormField<String>(
                                    value: _selectedGender,
                                    decoration:
                                        inputDecoration("Select Gender"),
                                    items: _genders.map((gender) {
                                      return DropdownMenuItem<String>(
                                        value: gender,
                                        child: Text(gender),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedGender = value;
                                      });
                                    },
                                    validator: (value) => value == null
                                        ? "Please select your gender"
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      ],
                      SizedBox(height: 16.0),
                      Text("Email", style: labelStyle()),
                      buildTextField(emailController, "Your email", (value) {
                        if (value == null || !value.contains('@')) {
                          return "Please enter a valid email";
                        }
                        return null;
                      }, keyboardType: TextInputType.emailAddress),
                      SizedBox(height: 16.0),
                      Text("Password", style: labelStyle()),
                      buildTextField(passwordController, "Your password",
                          (value) {
                        if (value == null || value.length < 6) {
                          return "Password should be at least 6 characters long";
                        }
                        return null;
                      }, obscureText: true),
                    ],
                  ),
                ),
                SizedBox(height: 24.0),
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFF8C00),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    elevation: 3,
                  ),
                  child: Center(
                    child: Text(
                      _isLogin ? 'Login' : 'Sign Up',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24.0),
                Row(
                  children: [
                    Expanded(
                        child:
                            Divider(color: Colors.grey[300], thickness: 1.0)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child:
                          Text('Or', style: TextStyle(color: Colors.grey[500])),
                    ),
                    Expanded(
                        child:
                            Divider(color: Colors.grey[300], thickness: 1.0)),
                  ],
                ),
                SizedBox(height: 16.0),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isLogin = !_isLogin;
                    });
                  },
                  child: Center(
                    child: Text(
                      _isLogin
                          ? "Create an Account"
                          : "I Already have an Account",
                      style:
                          TextStyle(fontSize: 16.0, color: Color(0xFF3B82F6)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(
    TextEditingController controller,
    String hint,
    String? Function(String?) validator, {
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: TextStyle(color: Colors.black),
      decoration: inputDecoration(hint),
      validator: validator,
    );
  }

  InputDecoration inputDecoration(String hintText) => InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[400]),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Color(0xFF3B82F6), width: 2.0),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      );

  TextStyle labelStyle() => TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.w500,
        color: Color(0xFF374151),
      );
}
