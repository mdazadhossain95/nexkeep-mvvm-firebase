import 'package:firebase_analytics/firebase_analytics.dart';


class AnalyticsService {
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  Future<void> logTodoCreated() => analytics.logEvent(name: 'todo_created');
}