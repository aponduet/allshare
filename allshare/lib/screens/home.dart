import 'package:allshare/view/users.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(widget.title),
      // ),
      body: Center(
        child: Container(
          // constraints: const BoxConstraints(
          //     minWidth: 420, maxWidth: 800, minHeight: 500, maxHeight: 600),
          padding: const EdgeInsets.all(20),
          width: 550,
          height: 800,
          decoration: BoxDecoration(
            border: Border.all(width: 1, color: Colors.grey),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                //width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    Users(
                        name: "Sohel Rana",
                        id: "abce676546UUUrrr",
                        status: true),
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: Center(
                          child: Icon(
                        Icons.sync_alt,
                        color: Colors.green,
                      )),
                    ),
                    Users(
                        name: "Juel Rony",
                        id: "abce676546UUUrrr",
                        status: true),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              GestureDetector(
                onTap: () {
                  print('Clicked Button');
                },
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(width: 1, color: Colors.grey),
                      borderRadius: const BorderRadius.all(Radius.circular(5))),
                  width: 300,
                  height: 60,
                  child: const Center(
                    child: Text("Connected"),
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text('Sohel rana.jpg'),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                      onPressed: () {}, child: const Text('Select File')),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              GestureDetector(
                onTap: () {
                  print('Clicked Button');
                },
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(width: 1, color: Colors.grey),
                      borderRadius: const BorderRadius.all(Radius.circular(5))),
                  width: 300,
                  height: 60,
                  child: const Center(
                    child: Text("Send File"),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              //Received Files Area
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      border: Border.all(width: 1, color: Colors.grey),
                      borderRadius: const BorderRadius.all(Radius.circular(3))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                            border: Border.all(width: 1, color: Colors.grey),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(5))),
                        child: const Center(
                          child: Icon(Icons.image),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      const Expanded(child: Text('Sohelrana.jpg')),
                      ElevatedButton(
                          onPressed: () {},
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('View'),
                          ))
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
