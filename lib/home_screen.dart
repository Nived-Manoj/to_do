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
  final descontroller = TextEditingController();
  var keylist = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.black),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Center(
            child: Expanded(
              child: ListView.builder(
                itemCount: keylist.length,
                itemBuilder: (context, index) => Container(
                  color: Colors.grey,
                  child: Text(box.get(keylist[index])),
                ),
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
                      TextField(
                        controller: descontroller,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                            hintText: "enter detaiils of the task"),
                      ),
                      TextField(
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                            hintText: "enter date"),
                      ),
                      ElevatedButton(
                          onPressed: () {
                            box.add(titlecontroller.text);
                            keylist = box.keys.toList();
                            setState(() {});
                          },
                          child: Text("save"))
                    ],
                  ));
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
