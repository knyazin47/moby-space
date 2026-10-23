plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val mobyStorePath = System.getenv("MOBY_ANDROID_STORE_FILE")
val mobySignedRelease = !mobyStorePath.isNullOrBlank()

android {
    namespace = "dev.knyazin47.moby"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "dev.knyazin47.moby"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 29
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (mobySignedRelease) {
            create("mobyInternal") {
                storeFile = file(mobyStorePath!!)
                storePassword = requireNotNull(System.getenv("MOBY_ANDROID_STORE_PASSWORD")) { "Moby signing password is missing" }
                keyAlias = "moby-internal"
                keyPassword = requireNotNull(System.getenv("MOBY_ANDROID_STORE_PASSWORD")) { "Moby signing password is missing" }
            }
        }
    }

    buildTypes {
        release {
            // Published CI artifacts use a permanent private internal identity.
            // Local direct Flutter builds remain disposable development builds.
            signingConfig = signingConfigs.getByName(if (mobySignedRelease) "mobyInternal" else "debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
