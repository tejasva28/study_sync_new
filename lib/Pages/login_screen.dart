import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../Provider/auth_provider.dart';
import 'package:study_sync/service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late TokenStorageService _tokenStorageService = TokenStorageService();
  late ApiService _apiService;  // Declare _apiService here as late

  @override
  void initState() {
    super.initState();
    _tokenStorageService = TokenStorageService();
    _apiService = ApiService('https://fe00-117-220-236-245.ngrok-free.app/api', _tokenStorageService); // Initialize ApiService with the base URL
  }

  void _tryLogin() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    if (_formKey.currentState?.validate() ?? false) {
      final token = await _apiService.login(email, password);
      if (token != null) {
        await _tokenStorageService.saveToken(token);
        print('Authentication Successful');
        Fluttertoast.showToast(msg: 'Login Successful');
        context.go('/home'); // Use Navigator for routing
      } else {
        print('Wrong credentials');
        Fluttertoast.showToast(msg: 'Invalid Credentials');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 80),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              ElevatedButton(
                onPressed: _tryLogin,
                child: Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}