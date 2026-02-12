import 'package:drift/drift.dart';

class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get floor => integer().nullable()();
  IntColumn get apartmentNumber => integer().nullable()();
  TextColumn get role => text().withDefault(const Constant('resident'))(); // resident, syndic, adjoint, concierge
  RealColumn get balance => real().withDefault(const Constant(0.0))();
  TextColumn get accessCode => text().nullable()();
  BoolColumn get isBlocked => boolean().withDefault(const Constant(false))();
}
