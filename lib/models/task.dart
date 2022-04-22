import 'package:objectbox/objectbox.dart';
import 'package:todo_list/models/group.dart';

@Entity()
class Task {
  int id = 0;
  String description;
  bool completed = false;

  final group = ToOne<Group>();

  Task({
    required this.description,
  });
}
