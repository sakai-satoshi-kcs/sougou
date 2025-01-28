import 'package:flutter/material.dart';

class TimetableConScreen extends StatefulWidget {
  const TimetableConScreen({Key? key}) : super(key: key);

  @override
  _TimetableConScreenState createState() => _TimetableConScreenState();
}

class _TimetableConScreenState extends State<TimetableConScreen> {
  final List<Map<String, String>> templates = [];
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController roomController = TextEditingController();

  void _addTemplate() {
    if (subjectController.text.isNotEmpty && roomController.text.isNotEmpty) {
      setState(() {
        templates.add({
          'subject': subjectController.text,
          'room': roomController.text,
        });
        subjectController.clear();
        roomController.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('教科名と教室名を入力してください。')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('時間割管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              Navigator.pop(context, templates);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: subjectController,
              decoration: const InputDecoration(labelText: '教科名'),
            ),
            TextField(
              controller: roomController,
              decoration: const InputDecoration(labelText: '教室名'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addTemplate,
              child: const Text('テンプレート追加'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: templates.length,
                itemBuilder: (context, index) {
                  final template = templates[index];
                  return ListTile(
                    title: Text(template['subject']!),
                    subtitle: Text(template['room']!),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          templates.removeAt(index);
                        });
                      },
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