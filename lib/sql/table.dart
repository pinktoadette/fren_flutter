// import 'package:sqflite/sqflite.dart';
//
// class DBHelper {
//   Future<Database> database() async {
//     return openDatabase(
//       onCreate: (db, version) async {
//         await db.execute(
//             "CREATE TABLE user_profile(id TEXT PRIMARY KEY, name TEXT, address TEXT,mobileno TEXT,dob TEXT)");
//         await db.execute(
//             "CREATE TABLE user_transactions(id TEXT PRIMARY KEY, date TEXT, amount TEXT,cart TEXT)");
//         return db;
//       },
//       version: 1,
//     );
//   }