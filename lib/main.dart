import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notesqflite/screens/note_detail.dart';
import 'screens/note_list.dart';

void main() {




  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(


      title: "SoloNotes",
      theme: ThemeData.light(
        //colorScheme: ColorScheme(primary: Colors.teal[100],primaryVariant: Colors.teal,background: Colors.green[100],secondary: Colors.teal[200],brightness: Brightness.light,onBackground: Colors.teal[100],onPrimary: Colors.greenAccent,onError: Colors.pink,onSurface: Colors.teal,error: Colors.white,onSecondary: Colors.greenAccent[100],surface: Colors.teal[300],secondaryVariant: Colors.teal[900])
      ),

        //primarySwatch: Colors.green,

      debugShowCheckedModeBanner: false,
      home: NoteList(),
//      darkTheme: ThemeData(
//        fontFamily: 'Pacifico',
//      ),
    );
  }
}
