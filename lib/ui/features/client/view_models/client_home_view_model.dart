import 'package:flutter/foundation.dart';
import 'package:barberblack/data/repositories/profile_repository.dart';

class ClientHomeViewModel extends ChangeNotifier {
  ClientHomeViewModel({ProfileRepository? profileRepository})
    : _profileRepository = profileRepository ?? ProfileRepository();

  final ProfileRepository _profileRepository;

  bool isLoading = true;
  String? errorMessage;
  String userName = '';

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final profile = await _profileRepository.getCurrentProfile();

      userName = profile['nome']?.toString().trim() ?? '';

      if (userName.isEmpty) {
        userName = 'Cliente';
      }
    } catch (_) {
      errorMessage = 'Não foi possível carregar seu perfil.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
