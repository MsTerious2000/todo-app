import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:todo_app/controllers/authentication.dart';
import 'package:todo_app/screens/authentication/login.dart';
import 'package:todo_app/widgets/colors.dart';
import 'package:todo_app/widgets/dialogs.dart';
import 'package:todo_app/widgets/streams.dart';
import 'package:todo_app/widgets/texts.dart';

class TasksScreen extends StatefulWidget {
  final User user;
  const TasksScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  TextEditingController _taskTitle = TextEditingController();
  final TextEditingController _taskDescription = TextEditingController();
  final List<String> _tasks = [];
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: text('TO-DO APP', weight: bold), actions: [
        IconButton(onPressed: () => logout(), icon: const Icon(Icons.logout))
      ]),
      body: StreamBuilder(
          stream: tasksCollection
              .where('userID', isEqualTo: widget.user.uid)
              .orderBy('createdOn', descending: true)
              .snapshots(),
          builder: (context, ts) {
            if (ts.hasError) {
              return streamError(ts);
            } else if (ts.connectionState == ConnectionState.waiting) {
              return streamLoading();
            } else if (ts.data!.docs.isEmpty) {
              return streamEmpty('EMPTY RECORD');
            } else {
              return ListView.builder(
                  itemCount: ts.data!.docs.length,
                  itemBuilder: (context, index) {
                    var taskDocument = ts.data!.docs[index];
                    var taskData = taskDocument.data() as Map<String, dynamic>;
                    String title = taskData['title'] as String;
                    List<dynamic> tasks =
                        (taskData['tasks'] ?? []) as List<dynamic>;
                    bool allTasksChecked =
                        tasks.every((task) => task['isChecked']);

                    return ListTile(
                        onTap: () => viewTaskDetails(taskDocument.id),
                        tileColor: allTasksChecked
                            ? Colors.blue.shade50
                            : Colors.red.shade50,
                        leading: text('${index + 1}',
                            color: darkBlue, size: 20, weight: bold),
                        title: text(title, weight: bold),
                        subtitle: text(dateTimeToString(taskData['createdOn'])),
                        trailing: allTasksChecked
                            ? Icon(Icons.check_box, color: darkGreen)
                            : Icon(Icons.pending, color: darkRed));
                  });
            }
          }),
      floatingActionButton: FloatingActionButton(
          onPressed: () => assignNewTask(), child: const Icon(Icons.add)));

  assignNewTask() => showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
          child: SingleChildScrollView(
              child: StatefulBuilder(
                  builder: (context, setState) => AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)),
                      titlePadding: EdgeInsets.zero,
                      title: Card(
                          color: darkBlue,
                          margin: EdgeInsets.zero,
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(4),
                                  topRight: Radius.circular(4))),
                          child: ListTile(
                              leading: InkWell(
                                  onTap: () {
                                    _taskTitle.clear();
                                    _taskDescription.clear();
                                    _tasks.clear();
                                    Navigator.pop(context);
                                  },
                                  child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Icon(Icons.arrow_back,
                                          color: white))),
                              title: text('NEW TASK',
                                  color: white,
                                  size: 20,
                                  weight: bold,
                                  textAlign: taCenter),
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              trailing: InkWell(
                                  onTap: () => _taskDescription.text.isNotEmpty
                                      ? null
                                      : addTaskToDB(
                                          context, _taskTitle.text, _tasks),
                                  child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child:
                                          Icon(Icons.check, color: white))))),
                      contentPadding: EdgeInsets.zero,
                      content: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: Column(children: [
                            const SizedBox(height: 10),
                            Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 7.5),
                                child: TextField(
                                    controller: _taskTitle,
                                    maxLines: null,
                                    decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: 'TITLE'))),
                            Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 7.5),
                                child: TextField(
                                    controller: _taskDescription,
                                    maxLines: null,
                                    onChanged: (value) => setState(() {}),
                                    decoration: InputDecoration(
                                        border: const OutlineInputBorder(),
                                        labelText: 'ADD TASK',
                                        suffixIcon: _taskDescription
                                                .text.isEmpty
                                            ? const SizedBox.shrink()
                                            : IconButton(
                                                onPressed: () => setState(() {
                                                      _tasks.insert(
                                                          0,
                                                          _taskDescription
                                                              .text);
                                                      _taskDescription.clear();
                                                    }),
                                                icon: Icon(Icons.add,
                                                    color: darkGreen))))),
                            const Divider(),
                            ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: _tasks.length,
                                itemBuilder: (context, index) => ListTile(
                                    dense: true,
                                    title: Text(_tasks[index]),
                                    trailing: InkWell(
                                        onTap: () => setState(
                                            () => _tasks.removeAt(index)),
                                        child: Padding(
                                            padding: const EdgeInsets.all(5),
                                            child: Icon(Icons.close,
                                                color: darkRed))))),
                            const SizedBox(height: 10)
                          ])))))));

  addTaskToDB(context, String title, List<String> tasks) async {
    if (title.isEmpty) {
      showDialog(
          context: context,
          builder: (_) =>
              errorDialog(context, 'Update Failed', 'Title is empty!'));
    } else if (tasks.isEmpty) {
      showDialog(
          context: context,
          builder: (_) =>
              errorDialog(context, 'Update Failed', 'Please add a task!'));
    } else {
      List<Map<String, dynamic>> tasksList = tasks.map((description) {
        return {'description': description, 'isChecked': false};
      }).toList();
      try {
        EasyLoading.show(status: 'Creating task...');
        String taskID = tasksCollection.doc().id;
        await tasksCollection.doc(taskID).set({
          'taskID': taskID,
          'createdOn': DateTime.now(),
          'title': _taskTitle.text,
          'tasks': tasksList,
          'userID': widget.user.uid
        }).then((value) {
          EasyLoading.dismiss();
          showDialog(
                  context: context,
                  builder: (_) => successDialog(context, 'Add Task Success',
                      'Task has been added successfully!'))
              .then((value) => Navigator.pop(context));
        });
        _taskTitle.clear();
        _taskDescription.clear();
        tasks.clear();
      } catch (e) {
        showDialog(
            context: context,
            builder: (_) => errorDialog(context, 'Add Task Failed', '$e'));
      }
    }
  }

  viewTaskDetails(String taskID) => showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
          child: SingleChildScrollView(
              child: StatefulBuilder(
                  builder: (context, setState) => StreamBuilder(
                      stream: tasksCollection
                          .where('taskID', isEqualTo: taskID)
                          .snapshots(),
                      builder: (context, ts) {
                        if (ts.hasError) {
                          return streamError(ts);
                        } else if (ts.connectionState ==
                                ConnectionState.waiting ||
                            ts.data!.docs.isEmpty) {
                          return streamLoading();
                        } else {
                          var taskDocument = ts.data!.docs[0];
                          var taskData =
                              taskDocument.data() as Map<String, dynamic>;
                          String taskTitle = taskData['title'] as String;
                          List<dynamic> tasks =
                              (taskData['tasks'] ?? []) as List<dynamic>;

                          return AlertDialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4)),
                              titlePadding: EdgeInsets.zero,
                              title: Card(
                                  color: darkBlue,
                                  margin: EdgeInsets.zero,
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(4),
                                          topRight: Radius.circular(4))),
                                  child: ListTile(
                                      title: text(taskTitle,
                                          color: white, size: 20),
                                      contentPadding: const EdgeInsets.only(
                                          left: 20, right: 5),
                                      trailing: InkWell(
                                          onTap: () => Navigator.pop(context),
                                          child: const Padding(
                                              padding: EdgeInsets.all(10),
                                              child: Icon(Icons.close,
                                                  color: Colors.white))))),
                              contentPadding: EdgeInsets.zero,
                              content: taskList(taskID, tasks),
                              actionsAlignment: MainAxisAlignment.spaceEvenly,
                              actions: [
                                IconButton(
                                    onPressed: () =>
                                        deleteTask(context, taskID),
                                    icon: Icon(Icons.delete, color: darkRed)),
                                IconButton(
                                    onPressed: () =>
                                        editTasks(taskID, taskTitle, tasks),
                                    icon: Icon(Icons.edit, color: darkGreen))
                              ]);
                        }
                      })))));

  Widget taskList(String taskID, List<dynamic> tasks) => SizedBox(
      width: MediaQuery.of(context).size.width,
      child: ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            String description = tasks[index]['description'] as String;
            bool isChecked = tasks[index]['isChecked'] as bool;

            return ListTile(
                onTap: () async {
                  List<Map<String, dynamic>> updatedTasks = List.from(tasks);
                  updatedTasks[index]['isChecked'] = !isChecked;
                  await updateCheckbox(context, taskID, updatedTasks);
                  setState(() => tasks[index]['isChecked'] = !isChecked);
                },
                leading: Icon(isChecked
                    ? Icons.check_box
                    : Icons.check_box_outline_blank),
                title: Text(description,
                    style: TextStyle(
                        decoration: isChecked
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        decorationColor: darkRed,
                        decorationStyle: TextDecorationStyle.double)));
          }));

  Future<void> editTasks(
      String taskID, String title, List<dynamic> taskList) async {
    _taskTitle = TextEditingController(text: title);
    List<String> tasks =
        taskList.map((task) => task['description'].toString()).toList();

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Center(
            child: SingleChildScrollView(
                child: StatefulBuilder(
                    builder: (context, setState) => AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4)),
                        titlePadding: EdgeInsets.zero,
                        title: Card(
                            color: darkBlue,
                            margin: EdgeInsets.zero,
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(4),
                                    topRight: Radius.circular(4))),
                            child: ListTile(
                                leading: InkWell(
                                    onTap: () {
                                      _taskTitle.clear();
                                      _taskDescription.clear();
                                      Navigator.pop(context);
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Icon(Icons.arrow_back,
                                          color: Colors.white),
                                    )),
                                title: text('EDIT TASK',
                                    color: Colors.white,
                                    size: 20,
                                    weight: bold,
                                    textAlign: taCenter),
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                trailing: InkWell(
                                    onTap: () =>
                                        _taskDescription.text.isNotEmpty
                                            ? null
                                            : updateTasks(context, taskID,
                                                _taskTitle.text, tasks),
                                    child: const Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Icon(Icons.check,
                                          color: Colors.white),
                                    )))),
                        contentPadding: EdgeInsets.zero,
                        content: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: Column(children: [
                              const SizedBox(height: 10),
                              Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 7.5),
                                  child: TextField(
                                      controller: _taskTitle,
                                      maxLines: null,
                                      decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          labelText: 'TITLE'))),
                              Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 7.5),
                                  child: TextField(
                                      controller: _taskDescription,
                                      maxLines: null,
                                      onChanged: (value) => setState(() {}),
                                      decoration: InputDecoration(
                                          border: const OutlineInputBorder(),
                                          labelText: 'ADD TASK',
                                          suffixIcon: _taskDescription
                                                  .text.isEmpty
                                              ? const SizedBox.shrink()
                                              : IconButton(
                                                  onPressed: () => setState(() {
                                                        tasks.insert(
                                                            0,
                                                            _taskDescription
                                                                .text);
                                                        _taskDescription
                                                            .clear();
                                                      }),
                                                  icon: Icon(Icons.add,
                                                      color: darkGreen))))),
                              const Divider(),
                              ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: tasks.length,
                                  itemBuilder: (context, index) => ListTile(
                                      dense: true,
                                      title: Text(tasks[index]),
                                      trailing: InkWell(
                                          onTap: () => setState(
                                              () => tasks.removeAt(index)),
                                          child: Padding(
                                              padding: const EdgeInsets.all(5),
                                              child: Icon(Icons.close,
                                                  color: darkRed))))),
                              const SizedBox(height: 10)
                            ])))))));
  }

  Future<void> updateTasks(
      context, String taskID, String title, List<dynamic> tasks) async {
    if (title.isEmpty) {
      showDialog(
          context: context,
          builder: (_) =>
              errorDialog(context, 'Update Failed', 'Title is empty!'));
    } else if (tasks.isEmpty) {
      showDialog(
          context: context,
          builder: (_) =>
              errorDialog(context, 'Update Failed', 'Please add a task!'));
    } else {
      try {
        EasyLoading.show(status: 'Updating task...');
        var existingTasks = await tasksCollection.doc(taskID).get();
        var existingTaskData = existingTasks.data() as Map<String, dynamic>;
        var existingTaskList = existingTaskData['tasks'] as List<dynamic>;

        List<Map<String, dynamic>> updatedTasksList = [];

        for (var existingTask in existingTaskList) {
          updatedTasksList.add({
            'description': existingTask['description'],
            'isChecked': existingTask['isChecked'],
          });
        }
        for (var description in tasks) {
          bool taskExists = updatedTasksList.any((task) =>
              task['description'].toString().toLowerCase() ==
              description.toString().toLowerCase());
          if (!taskExists) {
            updatedTasksList.add({
              'description': description,
              'isChecked': false,
            });
          }
        }
        await tasksCollection.doc(taskID).set({
          'taskID': taskID,
          'createdOn': DateTime.now(),
          'title': title,
          'tasks': updatedTasksList,
        }).then((value) {
          EasyLoading.dismiss();
          showDialog(
                  context: context,
                  builder: (_) => successDialog(context, 'Update Success',
                      'Task has been updated successfully!'))
              .then((value) => Navigator.pop(context));
        });
        tasks.clear();
      } catch (e) {
        showDialog(
            context: context,
            builder: (_) => errorDialog(context, 'Update Failed', '$e!'));
      }
    }
  }

  Future<void> updateCheckbox(
      context, String taskID, List<Map<String, dynamic>> updatedTasks) async {
    try {
      await tasksCollection.doc(taskID).update({'tasks': updatedTasks});
    } catch (e) {
      showDialog(
          context: context,
          builder: (_) => successDialog(context, 'Update Failed', '$e!'));
    }
  }

  Future<void> deleteTask(context, String taskID) async => showDialog(
      context: context,
      builder: (_) => AlertDialog(
              title: text('Delete Task', weight: bold),
              content: text('Do you want to continue?'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: text('No', weight: bold)),
                ElevatedButton(
                    onPressed: () async {
                      EasyLoading.show(status: 'Deleting task...');
                      try {
                        Navigator.pop(context);
                        final DocumentReference documentReference =
                            tasksCollection.doc(taskID);
                        await documentReference.delete().then((value) {
                          EasyLoading.dismiss();
                          showDialog(
                                  context: context,
                                  builder: (_) => successDialog(
                                      context,
                                      'Delete Success',
                                      'Task has been deleted successfully!'))
                              .then((value) => Navigator.pop(context));
                        });
                      } catch (e) {
                        showDialog(
                            context: context,
                            builder: (_) =>
                                errorDialog(context, 'Delete Failed', '$e!'));
                      }
                    },
                    child: text('Yes', weight: bold))
              ]));

  void logout() => showDialog(
      context: context,
      builder: (_) => AlertDialog(
              title: text('Logout', weight: bold),
              content: text('Do you want to continue?'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: text('No', weight: bold)),
                ElevatedButton(
                    onPressed: () {
                      FirebaseAuth.instance.signOut();
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen()),
                          (route) => false);
                    },
                    child: text('Yes', weight: bold))
              ]));
}
