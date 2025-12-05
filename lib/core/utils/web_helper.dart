// Helper for web-specific operations
// Uses conditional import to only include dart:html on web platform

// Conditional import: use web implementation on web, stub on other platforms
import 'web_helper_stub.dart'
    if (dart.library.html) 'web_helper_web.dart' as web_helper;

/// Inject Google Client ID into HTML meta tag (web only)
void injectGoogleClientId(String clientId) {
  web_helper.injectGoogleClientId(clientId);
}

