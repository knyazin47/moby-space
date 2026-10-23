package dev.knyazin47.moby

import android.content.Context
import android.content.res.ColorStateList
import android.view.ContextThemeWrapper
import android.view.View
import android.widget.ProgressBar
import android.webkit.WebView
import android.webkit.WebViewClient
import android.webkit.WebChromeClient
import android.webkit.WebResourceRequest
import android.webkit.WebResourceResponse
import android.webkit.WebSettings
import java.io.ByteArrayInputStream
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngine.platformViewsController.registry.registerViewFactory(
            "moby/native-progress", NativeProgressFactory()
        )
        flutterEngine.platformViewsController.registry.registerViewFactory(
            "moby/offline-web", OfflineWebFactory()
        )
    }
}

private class NativeProgressFactory : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        // The reference layout uses framework ProgressBar, not a bundled GIF/Lottie.
        // Keep its native framework/OEM animation on the actual Android device.
        val themed = ContextThemeWrapper(context, android.R.style.Theme_Material_Light_NoActionBar)
        val progress = ProgressBar(themed, null, android.R.attr.progressBarStyle)
        // Android 10+ Force Dark must not recolor the intentionally light native view.
        progress.isForceDarkAllowed = false
        progress.isIndeterminate = true
        progress.indeterminateTintList = ColorStateList.valueOf(0xff1b74fd.toInt())
        return object : PlatformView {
            override fun getView(): View = progress
            override fun dispose() { progress.clearAnimation() }
        }
    }
}

/** Reconstructed public consent layout only. No credentials, transport or bank session. */
private class OfflineWebFactory : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        val html = (args as? Map<*, *>)?.get("html") as? String ?: ""
        val web = WebView(context)
        web.isForceDarkAllowed = false
        web.setBackgroundColor(android.graphics.Color.WHITE)
        web.settings.apply {
            // Only bundled inline checkbox/select-all handlers. No Java interfaces.
            javaScriptEnabled = true
            domStorageEnabled = false
            allowFileAccess = false
            allowContentAccess = false
            blockNetworkLoads = true
            mixedContentMode = WebSettings.MIXED_CONTENT_NEVER_ALLOW
            setSupportMultipleWindows(false)
        }
        web.webViewClient = object : WebViewClient() {
            override fun shouldOverrideUrlLoading(view: WebView?, request: WebResourceRequest?): Boolean = true
            @Deprecated("Compatibility with platform WebView callbacks")
            override fun shouldOverrideUrlLoading(view: WebView?, url: String?): Boolean = true
            override fun shouldInterceptRequest(view: WebView?, request: WebResourceRequest?): WebResourceResponse =
                WebResourceResponse("text/plain", "UTF-8", ByteArrayInputStream(ByteArray(0)))
        }
        web.webChromeClient = WebChromeClient()
        web.loadDataWithBaseURL("https://demo.invalid/", html, "text/html", "UTF-8", null)
        return object : PlatformView {
            override fun getView(): View = web
            override fun dispose() {
                web.stopLoading()
                web.loadUrl("about:blank")
                web.clearHistory()
                web.destroy()
            }
        }
    }
}
