/// Firestore collection path constants.
/// Single source of truth — prevents typos across the codebase.
class FirestorePaths {
  FirestorePaths._();

  static const String users = 'users';
  static const String groups = 'groups';
  static const String courses = 'courses';
  static const String categories = 'categories';
  static const String aiConversations = 'ai_conversations';
  static const String adminSettings = 'admin_settings';

  // Subcollections
  static String groupMessages(String groupId) => 'groups/$groupId/messages';
  static String aiMessages(String conversationId) =>
      'ai_conversations/$conversationId/messages';

  // Singleton documents
  static const String globalSettings = 'admin_settings/global';
}
