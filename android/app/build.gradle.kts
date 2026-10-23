plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.keev.ledger"
    buildFeatures {
        resValues = true
    }
    // Google Play mobile submissions after August 2026 require Android 16.
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.keev.ledger"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        // Official Google sample App ID is a safe no-revenue fallback. Release
        // advertising remains disabled in Dart until owner banner IDs exist.
        manifestPlaceholders["admobAppId"] =
            providers.gradleProperty("ADMOB_APP_ID")
                .orElse("ca-app-pub-3940256099942544~3347511713")
                .get()
    }

    flavorDimensions += "environment"
    productFlavors {
        create("development") {
            dimension = "environment"
            applicationIdSuffix = ".dev"
            resValue("string", "app_name", "KeEv Ledger Dev")
        }
        create("staging") {
            dimension = "environment"
            applicationIdSuffix = ".staging"
            resValue("string", "app_name", "KeEv Ledger Staging")
        }
        create("production") {
            dimension = "environment"
            resValue("string", "app_name", "KeEv Ledger")
        }
    }
    // Upload signing material is supplied only by the owner's CI/local
    // environment. A partial configuration fails instead of silently signing
    // with a different key; absent configuration leaves the RC unsigned.
    val uploadValues = listOf(
        providers.environmentVariable("KEEV_UPLOAD_STORE_FILE").orNull,
        providers.environmentVariable("KEEV_UPLOAD_STORE_PASSWORD").orNull,
        providers.environmentVariable("KEEV_UPLOAD_KEY_ALIAS").orNull,
        providers.environmentVariable("KEEV_UPLOAD_KEY_PASSWORD").orNull,
    )
    val hasUploadSigning = uploadValues.all { !it.isNullOrBlank() }
    require(hasUploadSigning || uploadValues.all { it.isNullOrBlank() }) {
        "Incomplete KeEv upload signing configuration"
    }
    if (hasUploadSigning) {
        val uploadFile = file(uploadValues[0]!!)
        require(uploadFile.isFile) { "KeEv upload keystore file is missing" }
        signingConfigs.create("upload") {
            storeFile = uploadFile
            storePassword = uploadValues[1]
            keyAlias = uploadValues[2]
            keyPassword = uploadValues[3]
        }
        buildTypes.getByName("release") {
            signingConfig = signingConfigs.getByName("upload")
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
