// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:helper_1/riverpod/screen/ui.dart';


// void main() {
//   runApp(ProviderScope(child: const MainApp()));
// }

// class MainApp extends StatelessWidget {
//   const MainApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: PaginatedListScreen(),
//     );
//   }
// }


import 'package:flutter/material.dart';

import 'google_meet/google_service.dart';
import 'google_meet/meeting_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Meet Integration',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<UserModel> _users = [];
  List<UserModel> _selectedUsers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  // Simulate loading users from your API
  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });

    // Replace this with your actual API call
    await Future.delayed(Duration(seconds: 1));
    
    final users = [
      UserModel(id: '1', name: 'John Doe', email: 'john@example.com'),
      UserModel(id: '2', name: 'Jane Smith', email: 'jane@example.com'),
      UserModel(id: '3', name: 'Bob Johnson', email: 'bob@example.com'),
      UserModel(id: '4', name: 'Alice Brown', email: 'alice@example.com'),
      UserModel(id: '5', name: 'Charlie Wilson', email: 'charlie@example.com'),
    ];

    setState(() {
      _users = users;
      _isLoading = false;
    });
  }

  void _handleSelectedUsersChanged(List<UserModel> selectedUsers) {
    setState(() {
      _selectedUsers = selectedUsers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Google Meet Integration'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  color: Colors.blue.shade50,
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Create Google Meet meetings and invite participants from your user list.',
                          style: TextStyle(color: Colors.blue.shade800),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: MeetingCreatorWidget(
                    availableUsers: _users,
                    onUsersChanged: _handleSelectedUsersChanged,
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showSelectedUsers();
        },
        icon: Icon(Icons.people),
        label: Text('Selected (${_selectedUsers.length})'),
      ),
    );
  }

  void _showSelectedUsers() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Selected Participants'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _selectedUsers.map((user) => 
            ListTile(
              leading: CircleAvatar(
                child: Text(user.name[0].toUpperCase()),
              ),
              title: Text(user.name),
              subtitle: Text(user.email),
            )
          ).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}

// Service class to fetch users from your API
class UserApiService {
  static Future<List<UserModel>> fetchUsers() async {
    // Replace with your actual API endpoint
    try {
      // final response = await http.get(Uri.parse('your-api-endpoint/users'));
      // if (response.statusCode == 200) {
      //   final List<dynamic> jsonData = json.decode(response.body);
      //   return jsonData.map((json) => UserModel.fromJson(json)).toList();
      // }
      
      // Mock data for example
      return [
        UserModel(id: '1', name: 'John Doe', email: 'john@example.com'),
        UserModel(id: '2', name: 'Jane Smith', email: 'jane@example.com'),
        // Add more users from your API
      ];
    } catch (e) {
      print('Error fetching users: $e');
      return [];
    }
  }
}