import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/datas/user.dart';
import 'package:fren_app/models/user_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// mainly used for messages and querying new bots
class DatabaseService {
  // Singleton pattern
  static final DatabaseService _databaseService = DatabaseService._internal();
  factory DatabaseService() => _databaseService;
  DatabaseService._internal();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    // Initialize the DB first time it is accessed
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();

    // Set the path to the database. Note: Using the `join` function from the
    // `path` package is best practice to ensure the path is correctly
    // constructed for each platform.
    final path = join(databasePath, 'machi_database.db');

    // Set the version. This executes the onCreate function and provides a
    // path to perform database upgrades and downgrades.
    return await openDatabase(
      path,
      onCreate: _onCreate,
      version: 1,
      onConfigure: (db) async => await db.execute('PRAGMA foreign_keys = ON'),
    );
  }


  Future<void> _onCreate(Database db, int version) async {
    //fbId = Firebase DocId
    // await db.execute("DROP TABLE IF EXISTS table");

    // Run the CREATE {USER} TABLE statement on the database.
    await db.execute(
      'CREATE TABLE IF NOT EXISTS user(id INTEGER PRIMARY KEY, '
          'fbId TEXT KEY UNIQUE, '
          'name TEXT, '
          'status TEXT, '
          'updatedAt INT)',
    );
    // bot table
    await db.execute(
      'CREATE TABLE IF NOT EXISTS bot(id INTEGER PRIMARY KEY, '
          'createdAt INT, '
          'updatedAt INT, '
          'fbId TEXT KEY UNIQUE, '
          'price REAL, '
          'name TEXT, '
          'domain TEXT, '
          'subdomain TEXT, '
          'repoId TEXT, '
          'about TEXT)',
    );

    // msg table createdAt, updatedAt - millisecondsSinceEpoch
    await db.execute(
      'CREATE TABLE IF NOT EXISTS message(id INTEGER PRIMARY KEY, '
          'createdAt INT,'
          'updatedAt INT, '
          'fbId TEXT KEY UNIQUE, '
          'botId TEXT, '
          'authorId TEXT, '
          'message Text, '
          'messageType TEXT)',
    );
  }

  // Get user
  Future<List<Map>> getOrAddUser(DocumentSnapshot<Map<String, dynamic>> user) async {
    // Get a reference to the database.
    final db = await _databaseService.database;
    List<Map> result = await db.rawQuery('Select * from user where fbId=?', [user.id]);
    if (result.isEmpty) {
      await db.rawInsert('INSERT INTO user(fbId, name, status, updatedAt) VALUES(?, ?, ?, ?)', [user.id, user[USER_FULLNAME], user[USER_STATUS], user[UPDATED_AT].millisecondsSinceEpoch]);
    }
    return result;
  }

  /// get or save bot info
  /// mainly concerned with about, price, domain on update
  Future<List<Map>> getOrAddBot(DocumentSnapshot<Map<String, dynamic>> bot) async {
    final db = await _databaseService.database;
    List<Map> result = await db.rawQuery('Select * from bot where fbId=?', [bot.id]);
    if (result.isEmpty) {
      await db.rawInsert('INSERT INTO bot(createdAt, '
          'updatedAt, '
          'fbId, '
          'price, '
          'name, '
          'domain, '
          'subdomain, '
          'repoId, '
          'about) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?)', [
            bot[CREATED_AT].millisecondsSinceEpoch,
        bot[UPDATED_AT].millisecondsSinceEpoch,
        bot[BOT_ID],
        bot[BOT_PRICE],
        bot[BOT_NAME],
        bot[BOT_DOMAIN], bot[BOT_SUBDOMAIN], bot[BOT_REPO_ID], bot[BOT_ABOUT]]);
    }
    return result;
  }

  Future<void> updateUser(Map<String, dynamic> user) async {
    var dt = DateTime.now();

    final db = await _databaseService.database;
    await db.rawUpdate('''
    UPDATE user 
    SET name = ?, status = ?, updatedAt = ? 
    WHERE fbId = ?
    ''',
        [user[USER_FULLNAME], user[USER_STATUS], dt.millisecondsSinceEpoch, UserModel().user.userId ]);
  }


  Future<Map> getUser(User user) async {
    final db = await _databaseService.database;
    List<Map> result = await db.rawQuery('Select * from user where fbId=?', [user.userId]);
    return result[0];
  }


  // Future<void> insertChat(Message message) async {
  //   final db = await _databaseService.database;
  //
  //   db.rawInsert('INSERT INTO chat(createdAt, name, status) VALUES(?, ?)', [user.userId, user.name, user.userStatus]);
  //
  // }

  // A method that retrieves all the breeds from the breeds table.
  // Future<List<User>> breeds() async {
  //   // Get a reference to the database.
  //   final db = await _databaseService.database;
  //
  //   // Query the table for all the Breeds.
  //   final List<Map<String, dynamic>> maps = await db.query('users');
  //
  //   // Convert the List<Map<String, dynamic> into a List<Breed>.
  //   return List.generate(maps.length, (index) => Breed.fromMap(maps[index]));
  // }


  // A method that deletes a breed data from the breeds table.
  Future<void> deleteBreed(int id) async {
    // Get a reference to the database.
    final db = await _databaseService.database;

    // Remove the Breed from the database.
    await db.delete(
      'breeds',
      // Use a `where` clause to delete a specific breed.
      where: 'id = ?',
      // Pass the Breed's id as a whereArg to prevent SQL injection.
      whereArgs: [id],
    );
  }

  Future<void> deleteDog(int id) async {
    final db = await _databaseService.database;
    await db.delete('dogs', where: 'id = ?', whereArgs: [id]);
  }
}