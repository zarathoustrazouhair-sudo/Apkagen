import 'package:drift/drift.dart';

class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get description => text()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  // V6 Updates
  TextColumn get type => text().withDefault(const Constant('todo'))(); // 'todo' or 'incident'
  IntColumn get authorId => integer().nullable()(); // Link to User ID
}
