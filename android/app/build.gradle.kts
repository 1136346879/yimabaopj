plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.yimabao"
//    compileSdk = flutter.compileSdkVersion
    compileSdk = 36
//    ndkVersion = flutter.ndkVersion
    ndkVersion = "26.3.11579264"
//    ndkVersion = "27.0.12077973"

    compileOptions {
        // 1. 必须开启核心库脱糖以兼容低版本Android
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.yimabao"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
//        minSdk = flutter.minSdkVersion
        minSdk = 24
        targetSdk = flutter.targetSdkVersion
        versionCode = 5
        versionName = "2.0.3" as String?
    }

    signingConfigs {
        register("release") {
            storeFile = rootProject.file("key/ymb.jsk")
            storePassword = "123456"
            keyAlias = "ymb"
            keyPassword = "123456"
        }
        named("debug") {
            storeFile = rootProject.file("key/ymb.jsk")
            storePassword = "123456"
            keyAlias = "ymb"
            keyPassword = "123456"
        }
    }
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
        debug {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}


dependencies {
    // 核心脱糖库
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")

    // 其他依赖...
    implementation("org.jetbrains.kotlin:kotlin-stdlib:1.9.22")
}

flutter {
    source = "../.."
}
