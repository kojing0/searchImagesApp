import 'package:flutter/material.dart';

class SecondPage extends StatelessWidget {
  const SecondPage(this.name);
  final String name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          const SizedBox(
            child: Image(image: AssetImage('images/sample.jpeg')),
          ),
          ElevatedButton(
            onPressed: () => {Navigator.pop(context)},
            child: Text("New $name Page"),
          ),
        ],
      ),
    );
  }
}
