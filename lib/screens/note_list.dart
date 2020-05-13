import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notesqflite/utils/database_helper.dart';
import 'note_detail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:notesqflite/models/note.dart';
import 'dart:async';
class NoteList extends StatefulWidget {
  // int count = 0;
  @override
  _NoteListState createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Note> noteList;
  int count = 0;
  @override
  Widget build(BuildContext context) {
    if (noteList == null) {
      noteList = List<Note>();
      updateListView();
    }
    return Scaffold(
      appBar: AppBar(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(25),
              bottomLeft: Radius.circular(25)),
        ),
        backgroundColor: Colors.teal[100],
        title: Text(
          'S O L O N O T E S',
          style: TextStyle(
              fontSize: 30,
              fontStyle: FontStyle.italic,
              color: Colors.teal[900]),
        ),
        centerTitle: true,
        brightness: Brightness.dark,
        textTheme: TextTheme(
            title: TextStyle(
          fontWeight: FontWeight.bold,
          //  fontFamily: 'Pacifico',
        )),
      ),
      body: Padding(
        child: getNoteListView(),
        padding: EdgeInsets.all(15),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add note',
        child: Icon(Icons.plus_one),
        disabledElevation: 5300,
        focusElevation: 2,
        focusColor: Colors.teal[900],
        backgroundColor: Colors.teal[200],
        foregroundColor: Colors.teal[50],
        onPressed: () {
          navigateToDetail(Note('', '', 2), 'Add note');
        },
      ),
    );
  }

  ListView getNoteListView() {
    TextStyle titleStyle = Theme.of(context).textTheme.subhead;
    return ListView.builder(
      itemCount: count,
      itemBuilder: (BuildContext context, int position) {
        return Card(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20))),
          color: Colors.teal[200],
          elevation: 5.0,
          child: ListTile(
            onTap: () {
              navigateToDetail(this.noteList[position], 'Edit Note');
//              Navigator.push(context, MaterialPageRoute(builder: (context){
//                return NoteDetail();
//              }));
            },

            trailing: GestureDetector(
                onTap: () {
                  _delete(context, noteList[position]);
                },
                child: Icon(Icons.delete, color: Colors.teal[900])),

            leading: CircleAvatar(
              backgroundColor:
                  getPriorityColor(this.noteList[position].priority),
              child: getPriorityIcon(this.noteList[position].priority),
            ),
            title: Text(noteList[position].title, style: titleStyle),
            subtitle: Text(this.noteList[position].date),
          ),
        );
      },
    );
  }

  //helper function to get priority color
  Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.teal;
        break;
      case 2:
        return Colors.green;
        break;
      default:
        return Colors.green;
    }
  }

  Icon getPriorityIcon(int priority) {
    switch (priority) {
      case 1:
        return Icon(Icons.chevron_right);
        break;

      case 2:
        return Icon(Icons.keyboard_arrow_right);
        break;
      default:
        return Icon(Icons.keyboard_arrow_right);
    }
  }

  void _delete(BuildContext context, Note note) async {
    int result = await databaseHelper.deleteNote(note.id);
    if (result != 0) {
      _showSnackBar(context, 'Note deleted');
      updateListView();
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void navigateToDetail(Note note, String title) async {
    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return NoteDetail(note, title);
    }));
    if(result==true){
      updateListView();
    }
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Note>> noteListFuture = databaseHelper.getNoteList();
      noteListFuture.then((noteList) {
        setState(() {
          this.noteList = noteList;
          this.count = noteList.length;
        });
      });
    });
  }
}
