import 'package:flutter_test/flutter_test.dart';
import 'package:mini_taskhub/dashboard/task_model.dart';

void main() {
  test('Task model serialization (fromJson & toJson)', () {
    final json = {
      'id': 1,
      'body': 'Test Task',
      'is_completed': true,
      'created_at': '2024-01-01T10:00:00Z',
      'uid': 'user-123',
    };

    final task = Task.fromJson(json);

    expect(task.id, 1);
    expect(task.title, 'Test Task');
    expect(task.isCompleted, true);
    expect(task.userId, 'user-123');

    final serialized = task.toJson();

    expect(serialized['id'], 1);
    expect(serialized['body'], 'Test Task');
    expect(serialized['is_completed'], true);
    expect(serialized['uid'], 'user-123');
  });
}
