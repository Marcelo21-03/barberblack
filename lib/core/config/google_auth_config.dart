import 'package:google_sign_in/google_sign_in.dart';

const googleWebClientId =
    '16998387185-q2rhqu18210dvhvs46hjq9ubg09l3pbo.apps.googleusercontent.com';

const googleIosClientId =
    '16998387185-22ugn6qni290cfh9j30bmjvcm0m7633i.apps.googleusercontent.com';

Future<void> initializeGoogleSignIn() async {
  await GoogleSignIn.instance.initialize(
    clientId: googleIosClientId,
    serverClientId: googleWebClientId,
  );
}
