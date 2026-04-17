import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}


/// APP


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const HomeScreen(),
    );
  }
}


/// MODELS


class Task {
  String title;
  DateTime dateTime;
  bool isDone;

  Task({
    required this.title,
    required this.dateTime,
    this.isDone = false,
  });
}

class Note {
  String title;
  String content;

  Note({
    required this.title,
    required this.content,
  });
}


/// HOME SCREEN (STATE MANAGEMENT HERE)


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int index = 0;

  final List<Task> tasks = [];
  final List<Note> notes = [];

  @override
  Widget build(BuildContext context) {
    final screens = [
      TasksScreen(tasks: tasks),
      ScheduleScreen(tasks: tasks),
      NotesScreen(notes: notes),
    ];

    return Scaffold(
      body: screens[index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blueAccent,
        onTap: (i) => setState(() => index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.check), label: "Tasks"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Schedule"),
          BottomNavigationBarItem(icon: Icon(Icons.note), label: "Notes"),
        ],
      ),
    );
  }
}


/// TASK SCREEN


class TasksScreen extends StatefulWidget {
  final List<Task> tasks;

  const TasksScreen({super.key, required this.tasks});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  void addTask() async {
    String title = "";
    DateTime? date;
    TimeOfDay? time;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Task"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              onChanged: (v) => title = v,
              decoration: const InputDecoration(labelText: "Task Title"),
            ),
            ElevatedButton(
              onPressed: () async {
                date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
              },
              child: const Text("Pick Date"),
            ),
            ElevatedButton(
              onPressed: () async {
                time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
              },
              child: const Text("Pick Time"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (title.isNotEmpty && date != null && time != null) {
                final dt = DateTime(
                  date!.year,
                  date!.month,
                  date!.day,
                  time!.hour,
                  time!.minute,
                );

                setState(() {
                  widget.tasks.add(Task(title: title, dateTime: dt));
                });
              }
              Navigator.pop(context);
            },
            child: const Text("Add"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tasks"), centerTitle: true),
      floatingActionButton: FloatingActionButton(
        onPressed: addTask,
        child: const Icon(Icons.add),
      ),
      body: widget.tasks.isEmpty
          ? const Center(child: Text("No Tasks Yet"))
          : ListView.builder(
              itemCount: widget.tasks.length,
              itemBuilder: (_, i) {
                final task = widget.tasks[i];

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: Icon(
                      task.isDone
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: task.isDone ? Colors.green : Colors.grey,
                    ),
                    title: Text(
                      task.title,
                      style: TextStyle(
                        decoration:
                            task.isDone ? TextDecoration.lineThrough : null,
                        color: task.isDone ? Colors.grey : Colors.white,
                      ),
                    ),
                    subtitle: Text(
                      DateFormat('dd MMM yyyy – hh:mm a')
                          .format(task.dateTime),
                    ),
                    onTap: () {
                      setState(() {
                        task.isDone = !task.isDone;
                      });
                    },
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() => widget.tasks.removeAt(i));
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}


/// SCHEDULE SCREEN


class ScheduleScreen extends StatelessWidget {
  final List<Task> tasks;

  const ScheduleScreen({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    final todayTasks = tasks.where((task) {
      return task.dateTime.year == now.year &&
          task.dateTime.month == now.month &&
          task.dateTime.day == now.day;
    }).toList();

    final upcomingTasks = tasks.where((task) {
      return task.dateTime.isAfter(
        DateTime(now.year, now.month, now.day, 23, 59),
      );
    }).toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Schedule"),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: "Today"),
              Tab(text: "Upcoming"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            /// TODAY
            todayTasks.isEmpty
                ? const Center(child: Text("No Tasks Today"))
                : ListView.builder(
                    itemCount: todayTasks.length,
                    itemBuilder: (_, i) {
                      final task = todayTasks[i];
                      return ListTile(
                        leading: const Icon(Icons.today),
                        title: Text(task.title),
                        subtitle: Text(
                          DateFormat('hh:mm a')
                              .format(task.dateTime),
                        ),
                      );
                    },
                  ),

            /// UPCOMING
            upcomingTasks.isEmpty
                ? const Center(child: Text("No Upcoming Tasks"))
                : ListView.builder(
                    itemCount: upcomingTasks.length,
                    itemBuilder: (_, i) {
                      final task = upcomingTasks[i];
                      return ListTile(
                        leading: const Icon(Icons.schedule),
                        title: Text(task.title),
                        subtitle: Text(
                          DateFormat('dd MMM – hh:mm a')
                              .format(task.dateTime),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}


/// NOTES SCREEN


class NotesScreen extends StatefulWidget {
  final List<Note> notes;

  const NotesScreen({super.key, required this.notes});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  void addNote() async {
    String title = "";
    String content = "";

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Note"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              onChanged: (v) => title = v,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            TextField(
              onChanged: (v) => content = v,
              decoration: const InputDecoration(labelText: "Content"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (title.isNotEmpty) {
                setState(() {
                  widget.notes.add(
                    Note(title: title, content: content),
                  );
                });
              }
              Navigator.pop(context);
            },
            child: const Text("Add"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notes"), centerTitle: true),
      floatingActionButton: FloatingActionButton(
        onPressed: addNote,
        child: const Icon(Icons.add),
      ),
      body: widget.notes.isEmpty
          ? const Center(child: Text("No Notes Yet"))
          : GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: widget.notes.length,
              itemBuilder: (_, i) {
                final note = widget.notes[i];

                return Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey[800],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(note.title,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      Text(note.content),
                    ],
                  ),
                );
              },
            ),
    );
  }
}