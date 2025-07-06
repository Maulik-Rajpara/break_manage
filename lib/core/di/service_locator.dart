import 'package:get_it/get_it.dart';
import '../services/user_service.dart';
import '../services/preference_service.dart';
import '../services/network_service.dart';
import '../services/onboarding_service.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton<UserService>(() => UserService());
  locator.registerLazySingleton<PreferenceService>(() => PreferenceService());
  locator.registerLazySingleton<NetworkService>(() => NetworkService());
  locator.registerLazySingleton<OnboardingService>(() => OnboardingService());
} 