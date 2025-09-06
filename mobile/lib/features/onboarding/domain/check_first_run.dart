import '../datasources/local_storage.dart';

class CheckFirstRun {
  final LocalStorage localStorage;

  CheckFirstRun(this.localStorage);

  Future<bool> shouldShowOnboarding() async {
    return !(await localStorage.hasSeenOnboarding());
  }

  Future<void> completeOnboarding() async {
    await localStorage.setOnboardingSeen();
  }
}
