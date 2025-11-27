abstract class ChatApiKeys {
  static const baseUrl = String.fromEnvironment(
    'AI_CHAT_API_BASE_URL',
    defaultValue: '',
  ); // TODO: Set in .env
  static const chatEndpoint = '/chat';
}
