import 'package:flutter/material.dart';
import 'user_info_page.dart';
import 'file_upload_page.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Container(
              height: 50,
              margin: EdgeInsets.only(top: 5),
              width: MediaQuery.of(context).size.width/2,
              child: Image.asset('assets/header.png'),
            ),
            SizedBox(height: 20,),
            // UserInfo section
            Flexible(
              flex: 1,
              child: UserInfoPage(),
            ),
            // FileUpload section
            // Flexible(
            //   flex: 5,
            //   child: FileUploadPage(username: '', password: '',),
            // ),
            // FileUpload section

          ],
        ),
      ),
    );
  }
}
