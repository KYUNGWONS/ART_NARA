import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// 카카오 네이티브 앱 키는 커스텀 스킴(kakao{키}://oauth)에 들어가야 해서 매니페스트에 필요하다.
// 저장소에 커밋되지 않도록 git 미추적 파일 android/local.properties 에서 읽는다.
//   kakaoNativeAppKey=xxxxxxxx
// (CI 등에서는 KAKAO_NATIVE_APP_KEY 환경변수로도 넣을 수 있다)
val localProperties = Properties().apply {
    val file = rootProject.file("local.properties")
    if (file.exists()) file.inputStream().use { load(it) }
}

val kakaoNativeAppKey: String = localProperties.getProperty("kakaoNativeAppKey")
    ?: System.getenv("KAKAO_NATIVE_APP_KEY")
    ?: ""

// 네이버 지도 SDK 는 매니페스트 meta-data 의 클라이언트 ID 도 읽는다.
val naverMapClientId: String = localProperties.getProperty("naverMapClientId")
    ?: System.getenv("NAVER_MAP_CLIENT_ID")
    ?: ""

android {
    namespace = "com.artnara.artnara"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.artnara.artnara"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // AndroidManifest 의 카카오 로그인 리다이렉트 스킴에 주입된다.
        manifestPlaceholders["kakaoNativeAppKey"] = kakaoNativeAppKey
        manifestPlaceholders["naverMapClientId"] = naverMapClientId
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
