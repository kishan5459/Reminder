import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:reminder_with_local_notification/database/db_helper.dart';
import 'package:reminder_with_local_notification/screens/add_edit_screen.dart';

class ReminderDetailScreen extends StatefulWidget {
  final int reminderId;

  const ReminderDetailScreen({super.key, required this.reminderId});

  @override
  State<ReminderDetailScreen> createState() => _ReminderDetailScreenState();
}

class _ReminderDetailScreenState extends State<ReminderDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: DbHelper.getRemindersById(widget.reminderId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator(color: Colors.teal)),
          );
        }
        final reminder = snapshot.data!;
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            iconTheme: IconThemeData(color: Colors.teal),
            backgroundColor: Colors.white,
            title: Text(
              "Reminder Details",
              style: TextStyle(color: Colors.teal),
            ),
            centerTitle: true,
          ),
          body: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailCard(
                  label: "Title",
                  icon: Icons.title,
                  content: reminder['title'],
                ),
                SizedBox(height: 20),
                _buildDetailCard(
                  label: "Description",
                  icon: Icons.description,
                  content: reminder['description'],
                ),
                SizedBox(height: 20),
                _buildDetailCard(
                  label: "Category",
                  icon: Icons.category,
                  content: reminder['category'],
                ),
                SizedBox(height: 20),
                _buildDetailCard(
                  label: "Reminder Time",
                  icon: Icons.access_time,
                  content: DateFormat(
                    'yyyy-MM-dd hh:mm a',
                  ).format(DateTime.parse(reminder['reminderTime'])),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            child: Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          AddEditReminderScreen(reminderId: widget.reminderId),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildDetailCard({
    required String label,
    required IconData icon,
    required String content,
  }) {
    return Card(
      elevation: 6,
      color: Colors.teal.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.teal),
                SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              content,
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
