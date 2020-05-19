import 'package:flutter/material.dart';

class NoRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('can\'t find route'),
        ),
        body: Center(
          child: Container(
            child: const Text('can\'t find route'),
          ),
        ));
  }
}
