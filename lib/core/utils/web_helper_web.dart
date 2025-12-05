// Web implementation
import 'dart:html' as html;

void injectGoogleClientId(String clientId) {
  try {
    final metaElement = html.document.querySelector('#google-signin-client-id') as html.MetaElement?;
    if (metaElement != null) {
      metaElement.content = clientId.trim();
      print('✅ Injected GOOGLE_CLIENT_ID into HTML meta tag');
    } else {
      print('⚠️ Could not find #google-signin-client-id meta tag in HTML');
    }
  } catch (e) {
    print('⚠️ Error injecting Google Client ID: $e');
  }
}

