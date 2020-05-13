
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notesqflite/utils/database_helper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:notesqflite/models/note.dart';

class NoteDetail extends StatefulWidget {
  final String appBarTitle;
  final Note note;
  NoteDetail(this.note, this.appBarTitle);
  @override
  NoteDetailState createState() =>
      NoteDetailState(this.note, this.appBarTitle);
}

class NoteDetailState extends State<NoteDetail> {
  DatabaseHelper helper = DatabaseHelper();
  String appBarTitle;
  Note note;
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  static var _priorities = ['High', 'Low'];
  NoteDetailState(this.note, this.appBarTitle);

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;
    titleController.text = note.title;
    descriptionController.text = note.description;
    //doubt--> error when this declaration is out of build method.
    return WillPopScope(
      onWillPop: () {
        moveToLastScreen();
      },
      child: Scaffold(
        //backgroundColor: Colors.teal[100],
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.teal[900],
            ),
            onPressed: () {
              moveToLastScreen();
            },
          ),
          centerTitle: true,
          backgroundColor: Colors.teal[200],
          title: Text(
            appBarTitle,
            style: TextStyle(color: Colors.teal[900]),
          ),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30))),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          child: ListView(
            children: <Widget>[
              ListTile(
                title: DropdownButton(
                  items: _priorities.map(
                    (String dropDownStringItem) {
                      return DropdownMenuItem<String>(
                        value: dropDownStringItem,
                        child: Text(dropDownStringItem),
                      );
                    },
                  ).toList(),
                  style: textStyle,
                  value: getPriorityAsString(note.priority),
                  onChanged: (valueselected) {
                    setState(
                      () {
                        updatePriorityAsInt(valueselected);
                        debugPrint('$valueselected Option selected');
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 15, bottom: 15),
                child: TextField(
                  controller: titleController,
                  style: textStyle,
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: (value) {
                    updateTitle();
                    debugPrint('task $value');
                  },
                  decoration: InputDecoration(
                    hintText: 'Title',
                    //  labelText: 'Title',
                    labelStyle: textStyle,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(30),
                      ),
                    ),
               //     errorText: 'This field is required',
                    icon: Icon(Icons.title),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 15, bottom: 15),
                child: TextField(
                  controller: descriptionController,
                  style: textStyle,
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: (valueDescription) {
                    debugPrint('task $valueDescription');
                    updateDescription();
                    },
                  decoration: InputDecoration(
                    hintText: 'Description',
                    //  labelText: 'DESCRIPTION',
                    labelStyle: textStyle,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(30),
                      ),
                    ),

                    icon: Icon(Icons.description),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 16),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                        textColor: Colors.white70,
                        child: Text(
                          'Save',
                          textScaleFactor: 1.5,
                        ),
                        color: Colors.teal[500],
                        onPressed: () {
                          if(note.title == null){
                            Navigator.pop(context);}
                          setState(() {
                              _save();
                              }
                          //  debugPrint('Save');
                              );
                        },
                      ),
                    ),
                    SizedBox(
                      height: 12,
                      width: 15,
                    ),
                    Expanded(
                      child: RaisedButton(
                        colorBrightness: Brightness.light,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                        textColor: Colors.white70,
                        child: Text(
                          'Delete',
                          textScaleFactor: 1.5,
                        ),
                        color: Colors.teal[900],
                        onPressed: () {
                          setState(() {
                            _delete();
                            debugPrint('Delete');
                          });
                        },
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  int updatePriorityAsInt(String value) {
    //Convert the string priority in the form of an integer before saving it to the database.
    switch (value) {
      case 'High':
        note.priority = 1;
        break;
      case 'Low':
        note.priority = 2;
        break;
    }
    return null;
  }

  String getPriorityAsString(int value) {
    String priority;
    switch (value) {
      case 1:
        priority = _priorities[0];  // 'High'
        break;
      case 2:
        priority = _priorities[1];  // 'Low'
        break;
    }
    return priority;
  }
  void updateTitle(){
    note.title = titleController.text;
  }
  void updateDescription(){
    note.description= descriptionController.text;
  }
  void _save() async{
    moveToLastScreen();
    note.date = DateFormat.yMMMd().format(DateTime.now());//using from the intl package.
   int result;
    if(note.id != null) {
       result= await helper.updateNote(note);
   }else{
      result = await helper.insertNote(note);
   }
    if (result != 0) {  // Success
      _showAlertDialog('Status', 'Note Saved Successfully');
    } else {  // Failure
      _showAlertDialog('Status', 'Problem Saving Note');
    }
  }

  void _showAlertDialog(String title,String message){
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
  showDialog(
    context: context,
    builder: (_)=> alertDialog
  );
  }
  void _delete() async{
    moveToLastScreen();
    if(note.id==null){
      _showAlertDialog('Status', 'No note was deleted');
      return ;

    }
    int result=await helper.deleteNote(note.id);
    (result!=0)== true ? _showAlertDialog('Status','Note deleted'): _showAlertDialog('Status','Error occurred while deleting');

  }


  void moveToLastScreen() {
    Navigator.pop(context,true);
  }

}
