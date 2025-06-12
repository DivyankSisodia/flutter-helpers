import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:googleapis_auth/auth_io.dart';
import 'package:helper_1/google_meet/auth_manager.dart';
import 'package:http/http.dart' as http;

class GoogleMeetService {
  static const List<String> _scopes = [
    'https://www.googleapis.com/auth/calendar',
    'https://www.googleapis.com/auth/calendar.events',
  ];

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: _scopes,
    // Add this for better iOS compatibility
    clientId: null, // Will be read from Info.plist
  );

  calendar.CalendarApi? _calendarApi;

  // Sign in to Google
  Future<bool> isSignedIn() async {
    try {
      // First check if we have recent valid tokens
      if (await AuthManager.areTokensValid()) {
        final tokens = await AuthManager.getSavedAuthTokens();
        if (tokens != null && tokens['accessToken'] != null) {
          // Try to restore API client with saved tokens
          final credentials = AccessCredentials(
            AccessToken(
              'Bearer',
              tokens['accessToken'],
              DateTime.now().add(Duration(hours: 1)).toUtc(),
            ),
            null,
            _scopes,
          );

          final client = authenticatedClient(http.Client(), credentials);
          _calendarApi = calendar.CalendarApi(client);
          return true;
        }
      }

      // Fallback to checking Google Sign-In state
      final GoogleSignInAccount? account = _googleSignIn.currentUser;
      if (account != null) {
        final GoogleSignInAuthentication auth = await account.authentication;
        if (auth.accessToken != null) {
          // Update saved tokens
          await AuthManager.saveUserAuth(
            email: account.email,
            displayName: account.displayName ?? '',
            accessToken: auth.accessToken!,
            refreshToken: auth.idToken,
          );

          final credentials = AccessCredentials(
            AccessToken(
              'Bearer',
              auth.accessToken!,
              DateTime.now().add(Duration(hours: 1)).toUtc(),
            ),
            null,
            _scopes,
          );

          final client = authenticatedClient(http.Client(), credentials);
          _calendarApi = calendar.CalendarApi(client);
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Error checking sign-in state: $e');
      return false;
    }
  }

  // Enhanced silent sign in
  Future<bool> signInSilently() async {
    try {
      // Check if we have recent sign-in data
      if (await AuthManager.hasRecentSignIn()) {
        final GoogleSignInAccount? account = await _googleSignIn.signInSilently();
        if (account != null) {
          final GoogleSignInAuthentication auth = await account.authentication;
          
          // Update saved auth data
          await AuthManager.saveUserAuth(
            email: account.email,
            displayName: account.displayName ?? '',
            accessToken: auth.accessToken!,
            refreshToken: auth.idToken,
          );
          
          final credentials = AccessCredentials(
            AccessToken(
              'Bearer',
              auth.accessToken!,
              DateTime.now().add(Duration(hours: 1)).toUtc(),
            ),
            null,
            _scopes,
          );

          final client = authenticatedClient(http.Client(), credentials);
          _calendarApi = calendar.CalendarApi(client);
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Silent sign in failed: $e');
      return false;
    }
  }

  // Sign in to Google
  Future<bool> signIn() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account != null) {
        final GoogleSignInAuthentication auth = await account.authentication;
        
        // Save authentication data
        await AuthManager.saveUserAuth(
          email: account.email,
          displayName: account.displayName ?? '',
          accessToken: auth.accessToken!,
          refreshToken: auth.idToken,
        );
        
        final credentials = AccessCredentials(
          AccessToken(
            'Bearer',
            auth.accessToken!,
            DateTime.now().add(Duration(hours: 1)).toUtc(),
          ),
          null, // refresh token
          _scopes,
        );

        final client = authenticatedClient(http.Client(), credentials);
        _calendarApi = calendar.CalendarApi(client);
        return true;
      }
      return false;
    } catch (e) {
      print('Sign in error: $e');
      return false;
    }
  }

  // Create Google Meet meeting
  Future<MeetingResult?> createMeeting({
    required String title,
    required String description,
    required DateTime startTime,
    required DateTime endTime,
    required List<UserModel> participants,
  }) async {
    if (_calendarApi == null) {
      throw Exception('Not authenticated. Please sign in first.');
    }

    // Validate time range
    if (endTime.isBefore(startTime) || endTime.isAtSameMomentAs(startTime)) {
      throw Exception('End time must be after start time');
    }

    try {
      // Create calendar event with Google Meet
      final event = calendar.Event()
        ..summary = title
        ..description = description
        ..start = calendar.EventDateTime()
        ..end = calendar.EventDateTime()
        ..conferenceData = calendar.ConferenceData()
        ..attendees = participants.map((user) => 
          calendar.EventAttendee()
            ..email = user.email
            ..responseStatus = 'needsAction'
        ).toList();

      // Set start and end times with proper timezone handling
      final localTimeZone = DateTime.now().timeZoneName;
      
      event.start!.dateTime = startTime;
      event.start!.timeZone = localTimeZone;
      event.end!.dateTime = endTime;
      event.end!.timeZone = localTimeZone;

      // Configure Google Meet
      event.conferenceData!.createRequest = calendar.CreateConferenceRequest()
        ..requestId = 'meet-${DateTime.now().millisecondsSinceEpoch}'
        ..conferenceSolutionKey = calendar.ConferenceSolutionKey()
        ..conferenceSolutionKey!.type = 'hangoutsMeet';

      print('Creating event with:');
      print('Start: ${event.start!.dateTime} (${event.start!.timeZone})');
      print('End: ${event.end!.dateTime} (${event.end!.timeZone})');
      print('Participants: ${participants.map((u) => u.email).join(', ')}');

      // Create the event
      final createdEvent = await _calendarApi!.events.insert(
        event,
        'primary', // calendar ID
        conferenceDataVersion: 1,
        sendUpdates: 'all', // Send invites to all attendees
      );

      print('Event created: ${createdEvent.id}');
      print('Conference data: ${createdEvent.conferenceData}');

      if (createdEvent.conferenceData?.entryPoints?.isNotEmpty == true) {
        final meetingUrl = createdEvent.conferenceData!.entryPoints!
            .firstWhere(
              (entry) => entry.entryPointType == 'video',
              orElse: () => createdEvent.conferenceData!.entryPoints!.first,
            )
            .uri;

        return MeetingResult(
          meetingUrl: meetingUrl!,
          eventId: createdEvent.id!,
          meetingId: createdEvent.conferenceData!.conferenceId ?? '',
        );
      }

      throw Exception('Failed to create Google Meet link');
    } catch (e) {
      print('Error creating meeting: $e');
      rethrow;
    }
  }

  // Add participants to existing meeting
  Future<bool> addParticipants({
    required String eventId,
    required List<UserModel> newParticipants,
  }) async {
    if (_calendarApi == null) {
      throw Exception('Not authenticated. Please sign in first.');
    }

    try {
      // Get existing event
      final event = await _calendarApi!.events.get('primary', eventId);
      
      // Add new attendees to existing list
      final existingAttendees = event.attendees ?? [];
      final newAttendees = newParticipants.map((user) => 
        calendar.EventAttendee()..email = user.email
      ).toList();

      event.attendees = [...existingAttendees, ...newAttendees];

      // Update the event
      await _calendarApi!.events.update(
        event,
        'primary',
        eventId,
        sendUpdates: 'all',
      );

      return true;
    } catch (e) {
      print('Error adding participants: $e');
      return false;
    }
  }

  // Remove participants from meeting
  Future<bool> removeParticipants({
    required String eventId,
    required List<String> emailsToRemove,
  }) async {
    if (_calendarApi == null) {
      throw Exception('Not authenticated. Please sign in first.');
    }

    try {
      final event = await _calendarApi!.events.get('primary', eventId);
      
      if (event.attendees != null) {
        event.attendees!.removeWhere(
          (attendee) => emailsToRemove.contains(attendee.email)
        );

        await _calendarApi!.events.update(
          event,
          'primary',
          eventId,
          sendUpdates: 'all',
        );
      }

      return true;
    } catch (e) {
      print('Error removing participants: $e');
      return false;
    }
  }

  // Get meeting details
  Future<MeetingDetails?> getMeetingDetails(String eventId) async {
    if (_calendarApi == null) {
      throw Exception('Not authenticated. Please sign in first.');
    }

    try {
      final event = await _calendarApi!.events.get('primary', eventId);
      
      final meetingUrl = event.conferenceData?.entryPoints
          ?.firstWhere((entry) => entry.entryPointType == 'video',
              orElse: () => calendar.EntryPoint())
          ?.uri;

      return MeetingDetails(
        title: event.summary ?? '',
        description: event.description ?? '',
        startTime: event.start?.dateTime ?? DateTime.now(),
        endTime: event.end?.dateTime ?? DateTime.now(),
        meetingUrl: meetingUrl ?? '',
        participants: event.attendees?.map((attendee) => 
          attendee.email ?? ''
        ).toList() ?? [],
      );
    } catch (e) {
      print('Error getting meeting details: $e');
      return null;
    }
  }

  // Sign out and clear all data
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await AuthManager.clearAuthData();
    _calendarApi = null;
  }
}

// Data models
class UserModel {
  final String id;
  final String name;
  final String email;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }
}

class MeetingResult {
  final String meetingUrl;
  final String eventId;
  final String meetingId;

  MeetingResult({
    required this.meetingUrl,
    required this.eventId,
    required this.meetingId,
  });
}

class MeetingDetails {
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final String meetingUrl;
  final List<String> participants;

  MeetingDetails({
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.meetingUrl,
    required this.participants,
  });
}