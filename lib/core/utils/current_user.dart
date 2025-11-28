import 'package:firebase_auth/firebase_auth.dart';

import '../firebase/sample_data.dart';

String get currentUserId =>
    FirebaseAuth.instance.currentUser?.uid ?? demoUserId;

