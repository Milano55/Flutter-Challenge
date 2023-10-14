import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Post and Comment App',
      home: PostListScreen(),
    );
  }
}


class Post {
  final int id;
  final int userId;
  final String title;
  final String body;

  Post({required this.id, required this.userId, required this.title, required this.body});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      userId: json['userId'],
      title: json['title'],
      body: json['body'],
    );
  }
}

class PostListScreen extends StatefulWidget {
  @override
  _PostListScreenState createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> {
  List<Post> posts = [];

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/posts'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        posts = data.map((post) => Post.fromJson(post)).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Post List'),
        backgroundColor: Color.fromARGB(181, 160, 165, 168),
      ),
        backgroundColor: Color.fromARGB(181, 35, 117, 164),
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {

          int postNumber = index + 1;
          return ListTile(
            leading: CircleAvatar(
              child: Text(postNumber.toString()), 
            ),
            title: Text(posts[index].title),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PostDetailScreen(post: posts[index]),
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
  final Post post;

  PostDetailScreen({required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Post Detail'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(post.title),
            subtitle: Text(post.body),
          ),
          Expanded(
            child: CommentList(postId: post.id),
          ),
          CommentInput(postId: post.id),
        ],
      ),
    );
  }
}



class CommentList extends StatefulWidget {
  final int postId;

  CommentList({required this.postId});

  @override
  _CommentListState createState() => _CommentListState();
}

class _CommentListState extends State<CommentList> {
  List<Comment> comments = [];

  @override
  void initState() {
    super.initState();
    fetchComments();
  }

  Future<void> fetchComments() async {
    final response = await http.get(
        Uri.parse('https://jsonplaceholder.typicode.com/posts/${widget.postId}/comments'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        comments = data.map((comment) => Comment.fromJson(comment)).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Comments:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        ListView.builder(
          shrinkWrap: true,
          itemCount: comments.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(comments[index].name),
              subtitle: Text(comments[index].body),
            );
          },
        ),
      ],
    );
  }
}

class Comment {
  final int id;
  final int postId;
  final String name;
  final String email;
  final String body;

  Comment({required this.id, required this.postId, required this.name, required this.email, required this.body});

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      postId: json['postId'],
      name: json['name'],
      email: json['email'],
      body: json['body'],
    );
  }
}

class CommentInput extends StatefulWidget {
  final int postId;

  CommentInput({required this.postId});

  @override
  _CommentInputState createState() => _CommentInputState();
}

class _CommentInputState extends State<CommentInput> {
  final TextEditingController commentController = TextEditingController();

  void addComment() async {
    final response = await http.post(
      Uri.parse('https://jsonplaceholder.typicode.com/posts/${widget.postId}/comments'),
      body: json.encode({
        'userId': 1, 
        'name': 'Milan Maharjan', 
        'email': 'milan@example.com', 
        'body': commentController.text,
      }),
      headers: {'Content-type': 'application/json; charset=UTF-8'},
    );

    if (response.statusCode == 201) {
      
      commentController.clear();
    } else {
      
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: commentController,
              decoration: InputDecoration(
                hintText: 'Add a comment...',
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: addComment,
          ),
        ],
      ),
    );
  }
}
