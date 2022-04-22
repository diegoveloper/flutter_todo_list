import 'package:flutter/material.dart';
import 'package:todo_list/models/group.dart';
import 'package:todo_list/models/task.dart';
import 'package:todo_list/objectbox.g.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({required this.group, required this.store, Key? key})
      : super(key: key);

  final Group group;
  final Store store;

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final textController = TextEditingController();
  final _tasks = <Task>[];

  void _onSave() {
    final description = textController.text.trim();
    if (description.isNotEmpty) {
      textController.clear();
      final task = Task(description: description);
      task.group.target = widget.group;
      widget.store.box<Task>().put(task);
      _reloadTasks();
    }
  }

  void _reloadTasks() {
    _tasks.clear();
    QueryBuilder<Task> builder = widget.store.box<Task>().query();
    builder.link(Task_.group, Group_.id.equals(widget.group.id));
    Query<Task> query = builder.build();
    List<Task> tasksResult = query.find();
    setState(() {
      _tasks.addAll(tasksResult);
    });
    query.close();
  }

  void _onDelete(Task task) {
    widget.store.box<Task>().remove(task.id);
    _reloadTasks();
  }

  void _onUpdate(int index, bool completed) {
    final task = _tasks[index];
    task.completed = completed;
    widget.store.box<Task>().put(task);
    _reloadTasks();
  }

  @override
  void initState() {
    _tasks.addAll(List.from(widget.group.tasks));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.group.name}\'s Tasks'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: textController,
              decoration: const InputDecoration(
                hintText: 'Task',
              ),
            ),
            const SizedBox(height: 10),
            MaterialButton(
              color: Colors.blue,
              child: const Padding(
                padding: EdgeInsets.all(15),
                child: Text(
                  'Create Task',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              onPressed: _onSave,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  final task = _tasks[index];
                  return ListTile(
                    title: Text(
                      task.description,
                      style: TextStyle(
                        decoration:
                            task.completed ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    leading: Checkbox(
                      value: task.completed,
                      onChanged: (val) => _onUpdate(index, val!),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => _onDelete(task),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
