import 'package:flutter/material.dart';

class Formsearch {
  void topformsearch(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (builder) {
          return Container(
              child: Center(
            child: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(10),
                  color: Colors.red,
                  child: Center(
                    child: Text(
                      'Search',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            
          ));
        });
  }
}
