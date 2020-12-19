import 'package:get/get.dart' hide Node;
import 'package:sonar_app/data/contact_sql.dart';
import 'package:sonar_app/data/meta_sql.dart';
import 'package:sonr_core/sonr_core.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

const DATABASE_PATH = 'cards.db';

class SQLService extends GetxService {
  // Database Reference
  Database _db;
  String _dbPath;

  // ** Initialize CardService ** //
  Future<SQLService> init() async {
    // Get a location using getDatabasesPath
    var databasesPath = await getDatabasesPath();
    _dbPath = join(databasesPath, DATABASE_PATH);

    // Open Databases for Cards
    _db = await openDatabase(_dbPath, version: 3,
        onCreate: (Database db, int version) async {
      // Create Meta Table
      await db.execute('''
create table $metaTable (
  $fileColumnId integer primary key autoincrement,
  $fileColumnName text not null,
  $fileColumnPath text not null,
  $fileColumnSize integer not null,
  $fileColumnMime text not null,
  $fileColumnOwner text not null,
  $fileColumnlastOpened integer not null)
''');

      // Create Cards Table
      await db.execute('''
create table $contactTable (
  $contactColumnId integer primary key autoincrement,
  $contactColumnFirstName text not null,
  $contactColumnLastName text not null,
  $contactColumnData text not null,
  $contactColumnlastOpened integer not null)
''');
    });
    return this;
  }

  // ** Close SQL Database ** //
  onClose() async {
    await _db.close();
  }

  // ^ Insert Metadata into SQL DB ^ //
  Future<Metadata> saveFile(Metadata metadata) async {
    metadata.id = await _db.insert(metaTable, MetaSQL(metadata).toSQL());
    return metadata;
  }

  // ^ Delete a Metadata from SQL DB ^ //
  Future deleteFile(int id) async {
    var i = await _db
        .delete(metaTable, where: '$fileColumnId = ?', whereArgs: [id]);
    return i;
  }

  // ^ Update Metadata in DB ^ //
  Future updateFile(Metadata metadata) async {
    await _db.update(metaTable, MetaSQL(metadata).toSQL(),
        where: '$fileColumnId = ?', whereArgs: [metadata.id]);
  }

  // ^ Get All Files ^ //
  Future<List<MetaSQL>> fetchFiles() async {
    // Init List
    List<MetaSQL> result = new List<MetaSQL>();
    List<Map> records = await _db.query(
      metaTable,
      columns: [
        fileColumnId,
        fileColumnName,
        fileColumnPath,
        fileColumnSize,
        fileColumnMime,
        fileColumnOwner,
        fileColumnlastOpened
      ],
    );
    if (records.length > 0) {
      // Convert Each Record into Object
      records.forEach((element) {
        // Implement SQL Bindings for Metadata Protobuf
        MetaSQL meta = MetaSQL.fromSQL(element);
        result.add(meta);
      });
    }
    // Update All Files
    return result;
  }

  // ^ Insert Contact into SQL DB ^ //
  Future<Contact> saveContact(Contact contact) async {
    await _db.insert(contactTable, ContactSQL(contact).toSQL());
    return contact;
  }

  // ^ Delete a Contact from SQL DB ^ //
  Future deleteContact(int id) async {
    var i = await _db
        .delete(contactTable, where: '$fileColumnId = ?', whereArgs: [id]);
    return i;
  }

  // ^ Update Contact in DB ^ //
  Future updateContact(ContactSQL contact) async {
    await _db.update(contactTable, contact.toSQL(),
        where: '$fileColumnId = ?', whereArgs: [contact.id]);
  }

  // ^ Get All Contacts ^ //
  Future<List<ContactSQL>> fetchContacts() async {
    // Init List
    List<ContactSQL> result = new List<ContactSQL>();
    List<Map> records = await _db.query(
      contactTable,
      columns: [
        contactColumnId,
        contactColumnFirstName,
        contactColumnLastName,
        contactColumnData,
        contactColumnlastOpened
      ],
    );
    if (records.length > 0) {
      // Convert Each Record into Object
      records.forEach((element) {
        // Implement SQL Bindings for Metadata Protobuf
        ContactSQL meta = ContactSQL.fromSQL(element);
        result.add(meta);
      });
    }

    // Update All Files
    return result;
  }
}