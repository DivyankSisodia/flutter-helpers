import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:helper_1/google_meet/google_service.dart';

class MeetingCreatorWidget extends StatefulWidget {
  final List<UserModel> availableUsers;
  final Function(List<UserModel>) onUsersChanged;

  const MeetingCreatorWidget({
    Key? key,
    required this.availableUsers,
    required this.onUsersChanged,
  }) : super(key: key);

  @override
  State<MeetingCreatorWidget> createState() => _MeetingCreatorWidgetState();
}

class _MeetingCreatorWidgetState extends State<MeetingCreatorWidget> {
  final GoogleMeetService _meetService = GoogleMeetService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  List<UserModel> _selectedUsers = [];
  DateTime _selectedDate = DateTime.now();
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  
  bool _isLoading = false;
  bool _isSignedIn = false;
  String? _meetingUrl;

  @override
  void initState() {
    super.initState();
    _initializeTimes();
    _checkSignInStatus();
  }

  void _initializeTimes() {
    final now = TimeOfDay.now();
    _startTime = TimeOfDay(hour: now.hour, minute: now.minute);
    
    // Set end time to 1 hour after start time, handling day overflow
    int endHour = now.hour + 1;
    if (endHour >= 24) {
      endHour = 23;
      _endTime = TimeOfDay(hour: endHour, minute: 59);
    } else {
      _endTime = TimeOfDay(hour: endHour, minute: now.minute);
    }
  }

  Future<void> _checkSignInStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // First check if user is already signed in
      bool isSignedIn = await _meetService.isSignedIn();
      
      if (!isSignedIn) {
        // Try silent sign-in
        isSignedIn = await _meetService.signInSilently();
      }

      setState(() {
        _isSignedIn = isSignedIn;
        _isLoading = false;
      });

      if (isSignedIn) {
        print('User is already signed in');
      } else {
        print('User needs to sign in');
      }
    } catch (e) {
      print('Error checking sign-in status: $e');
      setState(() {
        _isSignedIn = false;
        _isLoading = false;
      });
    }
  }

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
    });

    final success = await _meetService.signIn();
    
    setState(() {
      _isSignedIn = success;
      _isLoading = false;
    });

    if (!success) {
      _showSnackBar('Failed to sign in to Google');
    }
  }

  Future<void> _createMeeting() async {
    if (_titleController.text.isEmpty) {
      _showSnackBar('Please enter a meeting title');
      return;
    }

    if (_selectedUsers.isEmpty) {
      _showSnackBar('Please select at least one participant');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final startDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _startTime.hour,
      _startTime.minute,
    );

    final endDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _endTime.hour,
      _endTime.minute,
    );

    // Validate time range
    if (endDateTime.isBefore(startDateTime) || endDateTime.isAtSameMomentAs(startDateTime)) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('End time must be after start time');
      return;
    }

    // Ensure minimum meeting duration (15 minutes)
    if (endDateTime.difference(startDateTime).inMinutes < 15) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('Meeting must be at least 15 minutes long');
      return;
    }

    print('Creating meeting:');
    print('Start: $startDateTime');
    print('End: $endDateTime');
    print('Duration: ${endDateTime.difference(startDateTime).inMinutes} minutes');

    try {
      final result = await _meetService.createMeeting(
        title: _titleController.text,
        description: _descriptionController.text,
        startTime: startDateTime,
        endTime: endDateTime,
        participants: _selectedUsers,
      );

      if (result != null) {
        setState(() {
          _meetingUrl = result.meetingUrl;
        });
        _showSnackBar('Meeting created successfully!');
      } else {
        _showSnackBar('Failed to create meeting');
      }
    } catch (e) {
      print('Create meeting error: $e');
      _showSnackBar('Error: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _toggleUserSelection(UserModel user) {
    setState(() {
      if (_selectedUsers.contains(user)) {
        _selectedUsers.remove(user);
      } else {
        _selectedUsers.add(user);
      }
    });
    widget.onUsersChanged(_selectedUsers);
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
          // Auto-adjust end time if it's now before or same as start time
          final startMinutes = _startTime.hour * 60 + _startTime.minute;
          final endMinutes = _endTime.hour * 60 + _endTime.minute;
          
          if (endMinutes <= startMinutes) {
            // Set end time to 1 hour after start time
            int newEndHour = _startTime.hour + 1;
            int newEndMinute = _startTime.minute;
            
            if (newEndHour >= 24) {
              newEndHour = 23;
              newEndMinute = 59;
            }
            
            _endTime = TimeOfDay(hour: newEndHour, minute: newEndMinute);
          }
        } else {
          final startMinutes = _startTime.hour * 60 + _startTime.minute;
          final pickedMinutes = picked.hour * 60 + picked.minute;
          
          if (pickedMinutes > startMinutes) {
            _endTime = picked;
          } else {
            _showSnackBar('End time must be after start time');
          }
        }
      });
    }
  }

  void _copyMeetingUrl() {
    if (_meetingUrl != null) {
      Clipboard.setData(ClipboardData(text: _meetingUrl!));
      _showSnackBar('Meeting URL copied to clipboard');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Google Meet'),
        actions: [
          if (_isSignedIn)
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () async {
                await _meetService.signOut();
                setState(() {
                  _isSignedIn = false;
                  _meetingUrl = null;
                });
              },
            ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : !_isSignedIn
              ? _buildSignInScreen()
              : _buildMeetingForm(),
    );
  }

  Widget _buildSignInScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.video_call, size: 64, color: Colors.blue),
          SizedBox(height: 16),
          Text(
            'Welcome to Google Meet Creator',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            'Sign in once to create meetings anytime',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _signIn,
            icon: Icon(Icons.login),
            label: Text('Sign in with Google'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.symmetric(horizontal: 32),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Icon(Icons.info, color: Colors.blue, size: 20),
                SizedBox(height: 8),
                Text(
                  'Your sign-in will be remembered for 30 days',
                  style: TextStyle(
                    color: Colors.blue.shade800,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeetingForm() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_meetingUrl != null) _buildMeetingUrlCard(),
          
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Meeting Details',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 16),
                  
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Meeting Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  
                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description (Optional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          title: Text('Date'),
                          subtitle: Text(_selectedDate.toString().split(' ')[0]),
                          trailing: Icon(Icons.calendar_today),
                          onTap: _selectDate,
                        ),
                      ),
                    ],
                  ),
                  
                  Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          title: Text('Start Time'),
                          subtitle: Text(_startTime.format(context)),
                          trailing: Icon(Icons.access_time),
                          onTap: () => _selectTime(true),
                        ),
                      ),
                      Expanded(
                        child: ListTile(
                          title: Text('End Time'),
                          subtitle: Text(_endTime.format(context)),
                          trailing: Icon(Icons.access_time),
                          onTap: () => _selectTime(false),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 16),
          
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Participants (${_selectedUsers.length} selected)',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 16),
                  
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: widget.availableUsers.length,
                    itemBuilder: (context, index) {
                      final user = widget.availableUsers[index];
                      final isSelected = _selectedUsers.contains(user);
                      
                      return CheckboxListTile(
                        title: Text(user.name),
                        subtitle: Text(user.email),
                        value: isSelected,
                        onChanged: (bool? value) {
                          _toggleUserSelection(user);
                        },
                        secondary: CircleAvatar(
                          child: Text(user.name[0].toUpperCase()),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 24),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _createMeeting,
              icon: Icon(Icons.video_call),
              label: Text('Create Google Meet'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeetingUrlCard() {
    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'Meeting Created Successfully!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text('Meeting URL:'),
            SizedBox(height: 4),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _meetingUrl!,
                      style: TextStyle(fontFamily: 'monospace'),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.copy),
                    onPressed: _copyMeetingUrl,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}