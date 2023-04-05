import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

import '../screen_arguments.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _passwFormKey = GlobalKey<FormState>();

  String? _name;
  String? _email;
  String? _oldPassword;
  String? _newPassword;

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as ScreenArguments;

    return FutureBuilder<dynamic>(
      future: _getProfile(args.refreshToken),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text('Failed to fetch data'),
          );
        }

        final body = snapshot.data;

        final name = body['data']['userName'];
        final email = body['data']['email'];

        // Set the initial values of the form fields
        _name = name;
        _email = email;

        return Scaffold(
          appBar: AppBar(
            title: const Text("Profile"),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Name'),
                    initialValue: name,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _name = value;
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Email'),
                    initialValue: email,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _email = value;
                    },
                  ),
                  Form(
                      key: _passwFormKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            obscureText: true,
                            decoration: const InputDecoration(
                                labelText: 'Old Password'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your old password';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _oldPassword = value;
                            },
                          ),
                          TextFormField(
                            obscureText: true,
                            decoration: const InputDecoration(
                                labelText: 'New Password'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your new password';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _newPassword = value;
                            },
                          ),
                        ],
                      )),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                                _updateProfile(args.refreshToken);
                              }
                            },
                            child: const Text('Save Changes'),
                          ),
                        ),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (_passwFormKey.currentState!.validate()) {
                                _passwFormKey.currentState!.save();
                                _changePassword(args.refreshToken);
                              }
                            },
                            child: const Text('Change Password'),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<dynamic> _getProfile(String refreshToken) async {
    final response = await http.get(
      Uri.parse('http://localhost:8888/user'),
      headers: {
        "Content-type": "application/json",
        "Authorization": "Bearer $refreshToken",
      },
    );
    return json.decode(response.body);
  }

  Future<void> _updateProfile(String refreshToken) async {
    const url = 'http://localhost:8888/user';
    final headers = {
      "Content-type": "application/json",
      "Authorization": "Bearer $refreshToken"
    };

    final body = {'userName': _name, 'email': _email};

    final response = await http.post(Uri.parse(url),
        headers: headers, body: jsonEncode(body));

    viewSnack(response.statusCode, 'Profile update is successful',
        'Profile update failed');
  }

  Future<void> _changePassword(String refreshToken) async {
    const url = 'http://localhost:8888/user';
    final headers = {
      "Content-type": "application/json",
      "Authorization": "Bearer $refreshToken"
    };

    final response = await http.put(
        Uri.parse('$url?newPassword=$_newPassword&oldPassword=$_oldPassword'),
        headers: headers);

    viewSnack(response.statusCode, 'Changing your password is successful',
        'Password change failed');
  }

  void viewSnack(int statusCode, String goodPhrase, badPhrase) {
    if (statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(goodPhrase),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(badPhrase),
      ));
    }
  }
}
