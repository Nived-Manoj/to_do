import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  var box = Hive.box('myBox');
  final titleController = TextEditingController();
  late AnimationController _fabAnimationController;
  late AnimationController _listAnimationController;

  var keylist = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _listAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    keylist = box.keys.toList();
    _listAnimationController.forward();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _listAnimationController.dispose();
    titleController.dispose();
    super.dispose();
  }

  void _addTask() async {
    if (titleController.text.trim().isEmpty) return;

    setState(() {
      isLoading = true;
    });

    await box.add({
      "title": titleController.text,
      "isCompleted": false,
      "createdAt": DateTime.now().toString(),
    });

    keylist = box.keys.toList();
    titleController.clear();

    setState(() {
      isLoading = false;
    });

    Navigator.pop(context);
  }

  void _deleteTask(int index) async {
    await box.delete(keylist[index]);
    setState(() {
      keylist = box.keys.toList();
    });
  }

  void _toggleTaskStatus(int index, bool? value) async {
    await box.put(keylist[index], {
      "title": box.get(keylist[index])["title"],
      "isCompleted": value,
      "createdAt":
          box.get(keylist[index])["createdAt"] ?? DateTime.now().toString(),
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      extendBody: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          "TASKS",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            letterSpacing: 2,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.nights_stay_outlined, color: Colors.black54),
            onPressed: () {
              // Theme toggle implementation would go here
            },
          )
        ],
      ),
      body: keylist.isEmpty ? _buildEmptyState() : _buildTaskList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _fabAnimationController.forward(from: 0);
          _showAddTaskBottomSheet();
        },
        backgroundColor: Colors.indigo[600],
        label: Row(
          children: [
            Icon(Icons.add, color: Colors.white),
            SizedBox(width: 8),
            Text('Add Task', style: TextStyle(color: Colors.white)),
          ],
        ),
      )
          .animate(controller: _fabAnimationController)
          .scale(duration: 300.ms, curve: Curves.easeOut)
          .then()
          .shake(hz: 4, curve: Curves.easeOut),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 100,
            color: Colors.grey[300],
          ),
          SizedBox(height: 16),
          Text(
            "No tasks yet",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.grey[500],
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Add a task to get started",
            style: TextStyle(
              color: Colors.grey[400],
            ),
          ),
        ],
      ).animate().fade(duration: 800.ms).slideY(begin: 0.2, end: 0),
    );
  }

  Widget _buildTaskList() {
    return ListView.builder(
      padding: EdgeInsets.only(bottom: 100, top: 16, left: 16, right: 16),
      itemCount: keylist.length,
      itemBuilder: (context, index) {
        final task = box.get(keylist[index]);
        final isCompleted = task["isCompleted"] ?? false;

        return Dismissible(
          key: Key(keylist[index].toString()),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 20),
            margin: EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.red[400],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (direction) => _deleteTask(index),
          child: Card(
            elevation: 0,
            margin: EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color:
                    isCompleted ? Colors.green.shade100 : Colors.grey.shade200,
                width: 1,
              ),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              leading: Checkbox(
                value: isCompleted,
                activeColor: Colors.green[600],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                onChanged: (value) => _toggleTaskStatus(index, value),
              ),
              title: Text(
                task["title"] ?? "",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                  color: isCompleted ? Colors.grey : Colors.black87,
                ),
              ),
              trailing: IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  color: Colors.grey[400],
                ),
                onPressed: () => _showDeleteConfirmation(index),
              ),
            ),
          ).animate(delay: (50 * index).ms).fadeIn(duration: 300.ms).slideX(
              begin: 0.1, end: 0, duration: 300.ms, curve: Curves.easeOut),
        );
      },
    );
  }

  void _showAddTaskBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Add New Task",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: titleController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: "What needs to be done?",
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.indigo),
                    ),
                    prefixIcon:
                        Icon(Icons.check_circle_outline, color: Colors.grey),
                  ),
                ),
                SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _addTask,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo[600],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            "Save Task",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        )
            .animate()
            .slideY(begin: 1, end: 0, duration: 400.ms, curve: Curves.easeOut),
      ),
    );
  }

  void _showDeleteConfirmation(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text("Delete Task"),
        content: Text("Are you sure you want to delete this task?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              _deleteTask(index);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[400],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text("Delete"),
          ),
        ],
      )
          .animate()
          .scale(
              begin: Offset(0.9, 0.9), duration: 300.ms, curve: Curves.easeOut)
          .fadeIn(duration: 300.ms),
    );
  }
}
