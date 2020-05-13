import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:notesqflite/models/note.dart';

class DatabaseHelper {
  static DatabaseHelper
      _databaseHelper; //singleton -- initiated only once throughout the app
  static Database _database; //singleton database
  String noteTable = 'note_table';
  String colId = 'id';
  String colTitle = 'title';
  String colDescription = 'description';
  String colPriority = 'priority';
  String colDate = 'date';

  DatabaseHelper._createInstance(); //named constructor to create instance of DatabaseHelper
  //factory allows us to return some value from the constructor
  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._createInstance();
    } // thus statement will only be executed once.

    return _databaseHelper;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {
    //Get the directory path for both Android and iOS to store database.
    Directory directory =
        await getApplicationDocumentsDirectory(); //read theory of the getApplicationDocumentsDirectory
    String path = directory.path + 'notes.db';
    var notesDatabase = openDatabase(path, version: 1, onCreate: _createDb);
    return notesDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute('CREATE TABLE $noteTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, '
        '$colDescription TEXT, $colPriority INTEGER, $colDate TEXT)');
         //SQL STATEMENT
  }


  //1. FETCH OPS: GET ALL NOTE OBJECTS FROM DATABASE
  Future<List<Map<String, dynamic>>> getNoteMapList() async {
    Database db = await this.database;
//      var result = await db.rawQuery('SELECT * FROM $noteTable order by $colId ASC');
    var result = await db.query(noteTable, orderBy: '$colPriority ASC');
    return result;
  }
  Future<int> insertNote(Note note) async {
    Database db = await this.database;
    var result = await db.insert(noteTable, note.toMap());
    return result;
  }

  //INSERT OPS: INSERT A NOTE OBJECT TO DATABASE


  //UPDATE OPS: UPDATE A NOTE OBJECT AND SAVE IT TO DATABASE
  Future<int> updateNote(Note note) async {
    var db = await this.database;
    var result = await db.update(noteTable, note.toMap(),
        where: '$colId = ?', whereArgs: [note.id]);
    return result;
  }

  //DELETE OPS: DELETE A NOTE OBJECT FROM DATABASE
  Future<int> deleteNote(int id) async {
    var db = await this.database;
    int result = await db.rawDelete('DELETE FROM $noteTable WHERE $colId= $id');
    return result;
  }

  //GET NUMBER OF NOTE OBJECTS IN DATABASE
  Future<int> getCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT (*) from $noteTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<List<Note>> getNoteList() async {
    var noteMapList = await getNoteMapList();
    int count = noteMapList.length;
    List<Note> noteList = List<Note>();
    for (int i = 0; i < count; i++) {
      noteList.add(Note.fromMapObject(noteMapList[i]));
    }
    return noteList;
  }
}
