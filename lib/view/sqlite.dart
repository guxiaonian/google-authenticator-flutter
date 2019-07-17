import 'package:sqflite/sqflite.dart';
import 'dart:async';

final String tableOTP = 'OTP';
final String columnId = '_id';
final String columnPath = 'path';
final String columnSecret = 'secret';
final String columnPeriod = 'period';
final String columnIssuer = 'issuer';
final String columnIsTotp = 'isTotp';

class OTP {
  int id;
  String path;
  String secret;
  String period;
  String issuer;
  bool isTotp;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnPath: path,
      columnSecret: secret,
      columnPeriod: period,
      columnIssuer: issuer,
      columnIsTotp: isTotp == true ? 1 : 0
    };
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }

  OTP(this.id, this.path, this.secret, this.period, this.issuer, this.isTotp);

  OTP.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    path = map[columnPath];
    secret = map[columnSecret];
    period = map[columnPeriod];
    issuer = map[columnIssuer];
    isTotp = map[columnIsTotp] == 1;
  }
}

class OTPProvider {
  Database db;

  Future open(String path) async {
    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
          await db.execute('''
create table $tableOTP ( 
  $columnId integer primary key autoincrement, 
  $columnPath text,
  $columnSecret text,
  $columnPeriod text,
  $columnIssuer text,
  $columnIsTotp integer not null)
''');
        });
  }

  Future<OTP> insert(OTP otp) async {
    otp.id = await db.insert(tableOTP, otp.toMap());
    return otp;
  }

  Future<OTP> getOTP(String path) async {
    List<Map> maps = await db.query(tableOTP,
        columns: [columnId, columnPath, columnSecret,columnPeriod,columnIssuer,columnIsTotp],
        where: '$columnPath = ?',
        whereArgs: [path]);
    if (maps.length > 0) {
      return OTP.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Map>> query() async {
    List<Map> maps = await db.query(tableOTP);
    if (maps.length > 0) {
      return maps;
    }
    return List<Map>();
  }

  Future<int> delete(int id) async {
    return await db.delete(tableOTP, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> update(OTP otp) async {
    return await db.update(tableOTP, otp.toMap(),
        where: '$columnId = ?', whereArgs: [otp.id]);
  }

  Future close() async => db.close();
}