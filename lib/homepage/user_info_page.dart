// user_info_page.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../postView/view_post.dart';
class UserInfoPage extends StatefulWidget {
  @override
  _UserInfoPageState createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  String? userName;
  String? userDescription;
  String? userPhotoUrl;

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null) {
      final url = Uri.parse('https://submit.dsoffice.org/wp-json/wp/v2/users/me');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          userName = data['name'];
          userDescription = data['description'];
          userPhotoUrl = data['url'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch user details')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        userName == null
            ? CircularProgressIndicator()
            : Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(width: 10),
            if (userPhotoUrl != null)
              Container(
                height: 40,
                width: 40,
                child: CircleAvatar(
                  backgroundImage: NetworkImage(userPhotoUrl!),
                  radius: 50,
                ),
              ),
            SizedBox(width: 10),
            Text(
              userName ?? '',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              userDescription ?? 'No description available',
              style: TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(right: 5.0),
          child: Theme(
            data: Theme.of(context).copyWith(
              filledButtonTheme: FilledButtonThemeData(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.transparent), // Set background color to white
                  foregroundColor: MaterialStateProperty.all(Colors.transparent), // Set text/icon color to black for contrast
                ),
              ),
            ),
            child: FilledButton.icon(
              icon: Icon(Icons.newspaper,color: Colors.black,),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PostListScreen(),
                  ),
                );
              },
              label: Text("All News",style: TextStyle(color: Colors.black),),
            ),
          ),
        )

      ],
    );
  }
}
