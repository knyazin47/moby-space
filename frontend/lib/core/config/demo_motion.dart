/// Replay timing is a local scenario setting, not a measured bank response SLA.
abstract final class DemoMotion {
  // Video ~174.5–175.25 shows a loader before the unavailable sheet.
  static const bodyLoad = Duration(milliseconds: 300);
  static const bannerLoad = Duration(milliseconds: 300);
  static const routeTransition = Duration(milliseconds: 300);
  static const cardApplicationLoad = Duration(milliseconds: 900);
  static const sheetEnter = Duration(milliseconds: 300);
  static const sheetExit = Duration(milliseconds: 200);
}
