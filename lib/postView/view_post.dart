// lib/models/post.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;

class WordPressPost {
  final int id;
  final String title;
  final String content;
  final String date;

  WordPressPost({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
  });

  factory WordPressPost.fromJson(Map<String, dynamic> json) {
    return WordPressPost(
      id: json['id'],
      title: json['title']['rendered'] ?? '',
      content: json['content']['rendered'] ?? '',
      date: json['date'] ?? '',
    );
  }
}

class WordPressService {
  final String baseUrl = 'https://submit.dsoffice.org/wp-json/wp/v2';

  Future<List<WordPressPost>> fetchPosts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/posts'));

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => WordPressPost.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load posts');
      }
    } catch (e) {
      throw Exception('Error fetching posts: $e');
    }
  }
}

class PostListScreen extends StatefulWidget {
  @override
  _PostListScreenState createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> {
  final WordPressService _wordPressService = WordPressService();
  late Future<List<WordPressPost>> _postsFuture;
  List<WordPressPost> _allPosts = [];
  List<WordPressPost> _filteredPosts = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _postsFuture = _wordPressService.fetchPosts();
    _postsFuture.then((posts) {
      setState(() {
        _allPosts = posts;
        _filteredPosts = posts;
      });
    });
    _searchController.addListener(_filterPosts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterPosts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredPosts = _allPosts
          .where((post) => post.title.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: Container(
        //   height: 45,
        //   child: Image.asset(
        //     'assets/header.png',
        //     fit: BoxFit.contain,
        //     alignment: Alignment.center,
        //   ),
        // ),
        centerTitle: true,
        backgroundColor: Colors.white54,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search posts by title...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<WordPressPost>>(
        future: _postsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'Error loading posts',
                    style: TextStyle(fontSize: 18),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _postsFuture = _wordPressService.fetchPosts();
                      });
                    },
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (_filteredPosts.isEmpty) {
            return Center(child: Text('No posts found'));
          }

          return ListView.builder(
            itemCount: _filteredPosts.length,
            itemBuilder: (context, index) {
              final post = _filteredPosts[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(
                    post.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    post.date.substring(0, 10),
                    style: TextStyle(color: Colors.grey),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PostDetailScreen(post: post),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}



class PostDetailScreen extends StatelessWidget {
  final WordPressPost post;

  const PostDetailScreen({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //title: Text('বিস্তারিত দেখুন'),
        title: Container(
          height: 55,
          child: Image.asset(
            'assets/header.png',
            fit: BoxFit.contain,
            alignment: Alignment.center,
          ),
        ),
        backgroundColor: Colors.white30,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              post.title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Published on: ${post.date.substring(0, 10)}',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 16),
            Html(
              data: post.content,
              style: {
                "body": Style(

                  fontSize: FontSize.small,
                  lineHeight: LineHeight.number(1.2),
                ),
              },
              // Add these optional callbacks for handling links, images, etc.
              // onLinkTap: (String? url, _, __, ___) {
              //   // Handle link taps
              //   if (url != null) {
              //     // You can add url launching logic here
              //     print('Tapped link: $url');
              //   }
              // },
              // onImageTap: (String? url, _, __, ___) {
              //   // Handle image taps
              //   if (url != null) {
              //     print('Tapped image: $url');
              //   }
              // },
            ),
          ],
        ),
      ),
    );
  }
}