import Flutter
import UIKit
import WebKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "MobyNativeViews") {
      registrar.register(NativeProgressFactory(), withId: "moby/native-progress")
      registrar.register(OfflineWebFactory(), withId: "moby/offline-web")
    }
  }
}

private final class NativeProgressFactory: NSObject, FlutterPlatformViewFactory {
  func create(
    withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?
  ) -> FlutterPlatformView {
    NativeProgressView(frame: frame)
  }
}

private final class NativeProgressView: NSObject, FlutterPlatformView {
  private let container: ProgressContainer

  init(frame: CGRect) {
    container = ProgressContainer(frame: frame)
    super.init()
  }

  func view() -> UIView { container }

  deinit {
    let releasedContainer = container
    DispatchQueue.main.async { releasedContainer.indicator.stopAnimating() }
  }
}

private final class ProgressContainer: UIView {
  let indicator = UIActivityIndicatorView(style: .medium)

  override init(frame: CGRect) {
    super.init(frame: frame)
    overrideUserInterfaceStyle = .light
    backgroundColor = .clear
    indicator.color = UIColor(red: 27 / 255, green: 116 / 255, blue: 253 / 255, alpha: 1)
    indicator.isAccessibilityElement = false // Dart owns the loading semantic label.
    indicator.translatesAutoresizingMaskIntoConstraints = false
    addSubview(indicator)
    NSLayoutConstraint.activate([
      indicator.centerXAnchor.constraint(equalTo: centerXAnchor),
      indicator.centerYAnchor.constraint(equalTo: centerYAnchor),
    ])
  }

  required init?(coder: NSCoder) { return nil }

  override func didMoveToWindow() {
    super.didMoveToWindow()
    if window == nil {
      indicator.stopAnimating()
    } else {
      indicator.startAnimating()
    }
  }
}

private final class OfflineWebFactory: NSObject, FlutterPlatformViewFactory {
  func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
    FlutterStandardMessageCodec.sharedInstance()
  }

  func create(
    withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?
  ) -> FlutterPlatformView {
    OfflineWebView(frame: frame, arguments: args)
  }
}

/// Only the fixed Dart HTML fragment is loaded. No remote URL, login transport,
/// JavaScript interface/message handler, credentials or persistent website store.
private final class OfflineWebView: NSObject, FlutterPlatformView,
  WKNavigationDelegate, WKUIDelegate {
  private let web: WKWebView
  private let closeLabel: String
  private var initialBlankAllowed = false
  private var initialDocumentPending = false
  private var alertCompletion: (() -> Void)?
  private weak var localAlert: UIAlertController?

  private static let csp = """
    <meta http-equiv="Content-Security-Policy" content="default-src 'none'; \
    style-src 'unsafe-inline'; script-src 'unsafe-inline'; connect-src 'none'; \
    img-src 'none'; font-src 'none'; media-src 'none'; object-src 'none'; \
    frame-src 'none'; child-src 'none'; worker-src 'none'; manifest-src 'none'; \
    base-uri 'none'; form-action 'none'">
    """
  // Block fetched subresources independently of HTML's CSP. Inline styles and
  // checkbox/alert JavaScript are not fetched resources. Main navigation has a
  // separate one-use about:blank allowlist below; no HTTP(S) document can load.
  private static let denyRequests = """
    [
      {"trigger":{"url-filter":".*","resource-type":["image","style-sheet","script","font","raw","svg-document","media"]},"action":{"type":"block"}},
      {"trigger":{"url-filter":"^https?://"},"action":{"type":"block"}}
    ]
    """

  init(frame: CGRect, arguments: Any?) {
    let params = arguments as? [String: Any]
    let html = params?["html"] as? String ?? ""
    closeLabel = params?["closeLabel"] as? String ?? ""
    let configuration = WKWebViewConfiguration()
    configuration.websiteDataStore = .nonPersistent()
    configuration.userContentController = WKUserContentController()
    configuration.defaultWebpagePreferences.allowsContentJavaScript = true
    configuration.preferences.javaScriptCanOpenWindowsAutomatically = false
    configuration.mediaTypesRequiringUserActionForPlayback = .all
    configuration.dataDetectorTypes = []
    web = WKWebView(frame: frame, configuration: configuration)
    super.init()
    web.overrideUserInterfaceStyle = .light
    web.backgroundColor = .white
    web.isOpaque = false
    web.allowsBackForwardNavigationGestures = false
    web.allowsLinkPreview = false
    web.scrollView.contentInsetAdjustmentBehavior = .never
    web.navigationDelegate = self
    web.uiDelegate = self
    if #available(iOS 16.4, *) { web.isInspectable = false }

    // Never load even the local document until both the blocker and CSP exist.
    // Unknown HTML shape or a failed rule compile stays blank (fail closed).
    guard !closeLabel.isEmpty,
      let head = html.range(of: "<head>", options: .caseInsensitive)
    else { return }
    let protectedHTML = String(html[..<head.upperBound]) + Self.csp
      + String(html[head.upperBound...])
    WKContentRuleListStore.default().compileContentRuleList(
      forIdentifier: "moby-offline-deny-requests-v1",
      encodedContentRuleList: Self.denyRequests
    ) { [weak self] rule, error in
      guard let rule = rule, error == nil else { return }
      DispatchQueue.main.async { [weak self] in
        guard let self = self else { return }
        self.web.configuration.userContentController.add(rule)
        self.initialBlankAllowed = true
        self.initialDocumentPending = true
        self.web.loadHTMLString(protectedHTML, baseURL: nil)
      }
    }
  }

  func view() -> UIView { web }

  func webView(
    _ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
    decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
  ) {
    let allowed = initialBlankAllowed && navigationAction.navigationType == .other
      && navigationAction.targetFrame?.isMainFrame == true
      && navigationAction.request.url?.absoluteString == "about:blank"
    initialBlankAllowed = false
    decisionHandler(allowed ? .allow : .cancel)
  }

  func webView(
    _ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse,
    decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void
  ) {
    decisionHandler(initialDocumentPending && navigationResponse.isForMainFrame
      && navigationResponse.response.url?.absoluteString == "about:blank" ? .allow : .cancel)
  }

  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    initialDocumentPending = false
  }

  func webView(
    _ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!,
    withError error: Error
  ) {
    initialDocumentPending = false
  }

  func webView(
    _ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge,
    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
  ) {
    completionHandler(.cancelAuthenticationChallenge, nil)
  }

  func webView(
    _ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration,
    for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures
  ) -> WKWebView? { nil }

  func webView(
    _ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String,
    initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void
  ) {
    var presenter = webView.window?.rootViewController
    while let presented = presenter?.presentedViewController { presenter = presented }
    guard frame.isMainFrame, frame.request.url?.absoluteString == "about:blank",
      alertCompletion == nil, let presenter = presenter,
      !(presenter is UIAlertController), !presenter.isBeingDismissed,
      presenter.viewIfLoaded?.window != nil
    else {
      completionHandler()
      return
    }
    alertCompletion = completionHandler
    let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
    alert.overrideUserInterfaceStyle = .light
    alert.addAction(UIAlertAction(title: closeLabel, style: .default) { [weak self] _ in
      self?.finishAlert()
    })
    localAlert = alert
    presenter.present(alert, animated: true)
  }

  func webView(
    _ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String,
    initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void
  ) { completionHandler(false) }

  func webView(
    _ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String,
    defaultText: String?, initiatedByFrame frame: WKFrameInfo,
    completionHandler: @escaping (String?) -> Void
  ) { completionHandler(nil) }

  func webView(
    _ webView: WKWebView, requestMediaCapturePermissionFor origin: WKSecurityOrigin,
    initiatedByFrame frame: WKFrameInfo, type: WKMediaCaptureType,
    decisionHandler: @escaping (WKPermissionDecision) -> Void
  ) { decisionHandler(.deny) }

  func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
    finishAlert()
    localAlert?.dismiss(animated: false)
    initialBlankAllowed = false
    initialDocumentPending = false
  }

  private func finishAlert() {
    let completion = alertCompletion
    alertCompletion = nil
    completion?()
  }

  deinit {
    // A Swift deinitializer is not guaranteed to execute on the UI executor.
    // Capture resources (never self) and release native work on the main queue.
    let releasedWeb = web
    let completion = alertCompletion
    let releasedAlert = localAlert
    DispatchQueue.main.async {
      releasedWeb.stopLoading()
      releasedWeb.navigationDelegate = nil
      releasedWeb.uiDelegate = nil
      releasedWeb.configuration.userContentController.removeAllUserScripts()
      releasedWeb.configuration.userContentController.removeAllContentRuleLists()
      completion?()
      releasedAlert?.dismiss(animated: false)
    }
    // The fresh nonpersistent website store holds no durable document state.
  }
}
