import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var box = Hive.box('myBox');
  final titlecontroller = TextEditingController();
  bool? isChecked = false;

  var keylist = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        title: Text(
          "TO DO",
          style: TextStyle(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: keylist.length,
              itemBuilder: (context, index) => ListTile(
                trailing: Checkbox(
                    value: isChecked,
                    onChanged: (value) {
                      isChecked = value;
                      setState(() {});
                    }),
                onTap: () {},
                title: Text(box.get(keylist[index])),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
              context: context,
              builder: (context) => Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: titlecontroller,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              hintText: "enter a task"),
                        ),
                      ),
                      ElevatedButton(
                          onPressed: () {
                            box.add({
                              "title": titlecontroller.text,
                              "isCompleted": false
                            });
                            keylist = box.keys.toList();
                            setState(() {});
                            titlecontroller.clear();
                          },
                          child: Text("save")),
                    ],
                  ));
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
