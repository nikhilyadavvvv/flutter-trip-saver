import 'package:map_app/trips_model.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;


class DatabaseHelper {

	static DatabaseHelper _databaseHelper;    // Singleton DatabaseHelper
	static Database _database;                // Singleton Database

	String tripsTable = 'Trips_table';
	String colId = 'id';
	String colTime= 'time';
	String colPath = 'path';
  String colType = 'type';

	DatabaseHelper._createInstance(); // Named constructor to create instance of DatabaseHelper

	factory DatabaseHelper() {

		if (_databaseHelper == null) {
			_databaseHelper = DatabaseHelper._createInstance(); // This is executed only once, singleton object
		}
		return _databaseHelper;
	}

	Future<Database> get database async {

		if (_database == null) {
			_database = await initializeDatabase();
		}
		return _database;
	}

	Future<Database> initializeDatabase() async {
		// Get the directory path for both Android and iOS to store database.
		Directory directory = await getApplicationDocumentsDirectory();
		//String path = directory.path + 'Tripss.db';
    String path = p.join(directory.toString(),'Tripss.db');
		// Open/create the database at a given path
		var TripssDatabase = await openDatabase(path, version: 1, onCreate: _createDb);
		return TripssDatabase;
	}

	void _createDb(Database db, int newVersion) async {

		await db.execute('CREATE TABLE $tripsTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTime TEXT, '
				'$colPath TEXT, $colType TEXT)');
	}

	// Fetch Operation: Get all Trips objects from database
	Future<List<Map<String, dynamic>>> getTripsMapList() async {
		Database db = await this.database;

//		var result = await db.rawQuery('SELECT * FROM $TripsTable order by $colPriority ASC');
		var result = await db.query(tripsTable, orderBy: '$colId ASC');
		return result;
	}

	// Insert Operation: Insert a Trips object to database
	Future<int> insertTrips(Trips trips) async {
		Database db = await this.database;
		var result = await db.insert(tripsTable, trips.toMap());
		return result;
	}

	// Update Operation: Update a Trips object and save it to database
	Future<int> updateTrips(Trips trips) async {
		var db = await this.database;
		var result = await db.update(tripsTable, trips.toMap(), where: '$colId = ?', whereArgs: [trips.id]);
    print(result);
		return result;
	}

	// Delete Operation: Delete a Trips object from database
	Future<int> deleteTrips(int id) async {
		var db = await this.database;
		int result = await db.rawDelete('DELETE FROM $tripsTable WHERE $colId = $id');
		return result;
	}

	// Get number of Trips objects in database
	Future<int> getCount() async {
		Database db = await this.database;
		List<Map<String, dynamic>> x = await db.rawQuery('SELECT COUNT (*) from $tripsTable');
		int result = Sqflite.firstIntValue(x);
		return result;
	}

	// Get the 'Map List' [ List<Map> ] and convert it to 'Trips List' [ List<Trips> ]
	Future<List<Trips>> getTripsList() async {

		var TripsMapList = await getTripsMapList(); // Get 'Map List' from database
		int count = TripsMapList.length;         // Count the number of map entries in db table

		List<Trips> tripsList = List<Trips>();
		// For loop to create a 'Trips List' from a 'Map List'
		for (int i = 0; i < count; i++) {
			tripsList.add(Trips.fromMapObject(TripsMapList[i]));
		}

		return tripsList;
	}

}