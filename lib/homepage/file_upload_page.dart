import 'dart:convert';
import 'dart:io';

import 'package:doinik_sokal2/authentication/login_page.dart';
import 'package:doinik_sokal2/homepage/user_info_page.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FileUploadPage extends StatefulWidget {
  final String username;
  final String password;

  FileUploadPage({required this.username, required this.password});

  @override
  _FileUploadPageState createState() => _FileUploadPageState();
}

class _FileUploadPageState extends State<FileUploadPage> {
  final quill.QuillController _controller = quill.QuillController.basic();
  final TextEditingController _titleController = TextEditingController();
  List<File> _selectedFiles = [];
  bool _isLoading = false;
  String? _authToken;

  final String _baseUrl = 'https://submit.dsoffice.org';

  @override
  void initState() {
    super.initState();
    _loadAuthToken();
  }

  Future<void> _getAuthToken() async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/wp-json/jwt-auth/v1/token'),
        body: {
          'username': widget.username,
          'password': widget.password,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final token = data['token'];
        setState(() {
          _authToken = token;
        });
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('authToken', token); // Save token
        print('Token obtained successfully');
      } else {
        print('Failed to get token: ${response.body}');
      }
    } catch (e) {
      print('Error getting token: $e');
    }
  }

  Future<void> _loadAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    if (token != null) {
      setState(() {
        _authToken = token;
      });
    } else {
      // Get token if not available locally
      await _getAuthToken();
    }
  }

  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'png', 'jpeg', 'mp4', 'mov'],
      );

      if (result != null) {
        setState(() {
          _selectedFiles = result.paths.map((path) => File(path!)).toList();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking files: ${e.toString()}')),
      );
    }
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  Widget _buildToolbar() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Wrap(
        children: [
          _formatButton(Icons.format_bold, () => _toggleFormat('bold')),
          _formatButton(Icons.format_italic, () => _toggleFormat('italic')),
          _formatButton(Icons.format_underline, () => _toggleFormat('underline')),
          _formatButton(Icons.format_list_bulleted, () => _toggleFormat('bullet')),
          _formatButton(Icons.format_list_numbered, () => _toggleFormat('number')),
        ],
      ),
    );
  }

  Widget _formatButton(IconData icon, VoidCallback onPressed) {
    return IconButton(
      icon: Icon(icon),
      onPressed: onPressed,
    );
  }

  void _toggleFormat(String format) {
    if (format == 'bold') {
      _controller.formatSelection(quill.Attribute.bold);
    } else if (format == 'italic') {
      _controller.formatSelection(quill.Attribute.italic);
    } else if (format == 'underline') {
      _controller.formatSelection(quill.Attribute.underline);
    } else if (format == 'bullet') {
      _controller.formatSelection(quill.Attribute.list);
    } else if (format == 'number') {
      _controller.formatSelection(quill.Attribute.list);
    }
  }

  Widget _buildSelectedFilesDisplay() {
    return Expanded(
      child: Wrap(
        spacing: 8,
        children: _selectedFiles.asMap().entries.map((entry) {
          int index = entry.key;
          File file = entry.value;

          return Chip(
            label: Text(
              file.path.split('/').last,
              overflow: TextOverflow.ellipsis,
            ),
            onDeleted: () => _removeFile(index),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      height: 50,
      width: MediaQuery.of(context).size.width / 2,
      color: Colors.black,
      child: TextButton(
        onPressed: _isLoading || _authToken == null ? null : _submitData,
        child: Text(
          _authToken == null ? 'Authenticating...' : 'Submit',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );

  }
//==========exit app code===============//
  DateTime? lastPressed;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          final now = DateTime.now();
          const exitTime = Duration(seconds: 2);

          if (lastPressed == null || now.difference(lastPressed!) > exitTime) {
            lastPressed = now;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Press back again to exit')),
            );
            return false; // Do not exit the app yet
          }

          SystemNavigator.pop();
          return true;
        },
    child: Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  alignment: Alignment.topCenter,

                  height: 50,
                  margin: EdgeInsets.only(top: 5,left: 100),
                  width: MediaQuery.of(context).size.width/2,
                  child: Image.asset('assets/header.png'),
                ),
                SizedBox(height: 20,),
                UserInfoPage(),
                SizedBox(height: 10,),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Enter Title',
                  ),
                ),
                SizedBox(height: 16.0),
                _buildToolbar(),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: quill.QuillEditor(
                      controller: _controller,
                      scrollController: ScrollController(),
                      focusNode: FocusNode(),
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                Row(
                  children: [
                    _buildPickFilesButton(),
                    SizedBox(width: 16.0),
                    _buildSelectedFilesDisplay(),
                  ],
                ),
                SizedBox(height: 16.0),
                _buildSubmitButton(),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    )
    );
  }

  Widget _buildPickFilesButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ElevatedButton.icon(
        onPressed: _selectedFiles.length < 3 ? _pickFiles : null,
        icon: Icon(Icons.attach_file, color: Colors.black),
        label: Text(
          'Attach Documents',
          style: TextStyle(color: Colors.black),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
        ),
      ),
    );
  }

  // Future<void> _submitData() async {
  //   if (_selectedFiles.isEmpty || _authToken == null || _titleController.text.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Please enter a title, select a file, and ensure you\'re authenticated')),
  //     );
  //     return;
  //   }
  Future<void> _submitData() async {
    if (_selectedFiles.isEmpty || _authToken == null || _titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a title, select a file, and ensure you\'re authenticated')),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Start loading state
    });

    try {
      final mediaIds = await Future.wait(_selectedFiles.map((file) => _uploadMedia(file)));
      await _createPost(mediaIds);

      // Show the success snack bar and clear the form fields once data is successfully uploaded
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Data submitted successfully')),
      // );

      // Clear form fields
      setState(() {
        _selectedFiles.clear();
        _titleController.clear();
        _controller.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Stop loading state
      });
    }
  }


  Future<String> _uploadMedia(File file) async {
    final url = Uri.parse('$_baseUrl/wp-json/wp/v2/media');
    final bytes = await file.readAsBytes();
    final filename = file.path.split('/').last;

    final request = http.MultipartRequest('POST', url);
    request.headers.addAll({
      'Authorization': 'Bearer $_authToken',
      'Content-Type': 'image/jpeg',
      'Content-Disposition': 'attachment; filename="$filename"',
    });
    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: filename,
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      return data['id'].toString();
    } else {
      throw Exception('Failed to upload media: ${response.body}');
    }
  }

  Future<void> _createPost(List<String> mediaIds) async {
    final url = Uri.parse('$_baseUrl/wp-json/wp/v2/posts');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $_authToken',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'title': _titleController.text,
        'content': _controller.document.toPlainText(),
        'status': 'publish',
        'featured_media': mediaIds.isNotEmpty ? mediaIds[0] : null,
        '_embedded': {
          'wp:featuredmedia': mediaIds.map((id) => {'id': id}).toList(),
        },
      }),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post created successfully')),
      );
    } else {
      throw Exception('Failed to create post: ${response.body}');
    }
  }
}
