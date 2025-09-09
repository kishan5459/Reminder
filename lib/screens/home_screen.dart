import 'package:flutter/material.dart';
import 'package:reminder_with_local_notification/database/db_helper.dart';
import 'package:reminder_with_local_notification/screens/add_edit_screen.dart';
import 'package:reminder_with_local_notification/services/notification_helper.dart';
import 'package:reminder_with_local_notification/screens/reminder_detail_screen.dart';
import 'package:reminder_with_local_notification/services/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _reminders = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    requestNotificationPermissions();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    final reminders = await DbHelper.getReminders();

    setState(() {
      _reminders = reminders;
    });
  }

  Future<void> _toggleReminder(int id, bool isActive) async {
    await DbHelper.toggleReminder(id, isActive);
    if (isActive) {
      final reminder = _reminders.firstWhere(
        (reminder) => reminder['id'] == id,
      );
      NotificationHelper.scheduleNotification(
        id,
        reminder['title'],
        reminder['category'],
        DateTime.parse(reminder['reminderTime']),
      );
    } else {
      NotificationHelper.cancelNotification(id);
    }

    _loadReminders();
  }

  Future<void> _deleteReminder(int id) async {
    await DbHelper.deleteReminder(id);
    NotificationHelper.cancelNotification(id);
    _loadReminders();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text("Reminders", style: TextStyle(color: Colors.teal)),
          iconTheme: IconThemeData(color: Colors.teal),
        ),
        body:
            _reminders.isEmpty
                ? Center(
                  child: Text(
                    "No Reminders Found",
                    style: TextStyle(fontSize: 18, color: Colors.teal),
                  ),
                )
                : ListView.builder(
                  itemCount: _reminders.length,
                  itemBuilder: (context, index) {
                    final reminder = _reminders[index];
                    return Dismissible(
                      key: Key(reminder['id'].toString()),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.redAccent,
                        padding: EdgeInsets.only(right: 20),
                        alignment: Alignment.centerRight,
                        child: Icon(
                          Icons.delete,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      confirmDismiss: (direction) async {
                        return await _showDeleteConfirmationDialog(context);
                      },
                      onDismissed: (direction) {
                        _deleteReminder(reminder['id']);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Reminder Deleted")),
                        );
                      },
                      child: Card(
                        color: Colors.teal.shade50,
                        elevation: 6,
                        margin: EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => ReminderDetailScreen(
                                      reminderId: reminder['id'],
                                    ),
                              ),
                            );
                          },
                          leading: Icon(
                            Icons.notifications,
                            color: Colors.teal,
                          ),
                          title: Text(
                            reminder['title'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                          subtitle: Text(
                            "Category: ${reminder['category']}",
                            style: TextStyle(),
                          ),
                          trailing: Switch(
                            value: reminder['isActive'] == 1,
                            activeColor: Colors.teal,
                            inactiveTrackColor: Colors.white,
                            inactiveThumbColor: Colors.black54,
                            onChanged: (value) {
                              _toggleReminder(reminder['id'], value);
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddEditReminderScreen()),
            );
          },
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          child: Icon(Icons.add),
        ),
      ),
    );
  }

  // show confirmation dialog before deleting a reminder
  Future<bool?> _showDeleteConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text("Delete Reminder"),
          content: Text("Are your sure you want to delete this reminder ?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // do not delete
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // conirm delete
              },
              child: Text("Delete", style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        );
      },
    );
  }
}
