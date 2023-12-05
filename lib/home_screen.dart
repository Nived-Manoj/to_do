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
              itemBuilder: (context, index) => Padding(
                padding: EdgeInsets.only(
                  left: 25,
                  right: 25,
                  top: 25,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.cyan,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Checkbox(
                            activeColor: Colors.black,
                            value: box.get(keylist[index])["isCompleted"],
                            onChanged: (bool? value) {
                              box.put(keylist[index], {
                                "title": box.get(keylist[index])["title"],
                                "isCompleted": value
                              });
                              setState(() {});
                            }),
                        Text(
                          box.get(keylist[index])["title"],
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w500),
                        ),
                        IconButton(
                            onPressed: () {
                              box.delete(keylist[index]);
                            },
                            icon: Icon(Icons.delete_outline)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.tealAccent,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        onPressed: () {
          showModalBottomSheet(
              context: context,
              builder: (context) => Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: titlecontroller,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              hintText: "Enter a task"),
                        ),
                      ),
                      ElevatedButton(
                          onPressed: () {
                            box.add({
                              "title": titlecontroller.text,
                              "isCompleted": false
                            });
                            keylist = box.keys.toList();
                            Navigator.pop(context);
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
