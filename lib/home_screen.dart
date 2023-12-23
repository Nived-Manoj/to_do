import 'package:cool_alert/cool_alert.dart';
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
      body: Column(children: [
        Expanded(
          child: ListView.builder(
            itemCount: keylist.length,
            itemBuilder: (context, index) => Padding(
              padding: EdgeInsets.only(
                left: 25,
                right: 25,
                top: 25,
              ),
              child: ListTile(
                leading: Checkbox(
                    activeColor: Colors.black,
                    value: box.get(keylist[index])["isCompleted"],
                    onChanged: (bool? value) {
                      box.put(keylist[index], {
                        "title": box.get(keylist[index])["title"],
                        "isCompleted": value
                      });
                      setState(() {});
                    }),
                title: Text(
                  box.get(keylist[index])["title"],
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),
                onLongPress: () {
                  CoolAlert.show(
                    onCancelBtnTap: () {
                      Navigator.pop;
                    },
                    onConfirmBtnTap: () {
                      box.delete(keylist[index]);
                    },
                    context: context,
                    type: CoolAlertType.confirm,
                    text: 'Do you want to Delete task?',
                    confirmBtnText: 'confirm',
                    cancelBtnText: 'cancel',
                    confirmBtnColor: Colors.green,
                  );
                },
                // trailing: IconButton(
                //     onPressed: () {
                //       box.delete(keylist[index]);
                //     },
                //     icon: Icon(Icons.delete_outline)),
                tileColor: Colors.cyanAccent,
              ),
            ),
          ),
        ),
      ]),
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
                          style: ButtonStyle(
                              backgroundColor: MaterialStatePropertyAll(
                                  Colors.purpleAccent)),
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
                          child: Text(
                            "save",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          )),
                    ],
                  ));
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
