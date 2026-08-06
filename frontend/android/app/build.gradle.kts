import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// 푸시는 Firebase 설정 파일이 있을 때만 켠다. 파일이 없으면 플러그인이 빌드를 깨뜨리므로
// (google-services.json 은 계정 자산이라 저장소에 없다) 존재할 때만 적용한다.
if (file("google-services.json").exists()) {
    apply(plugin = "com.google.gms.google-services")
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

// 네이버 로그인 SDK 는 매니페스트 메타데이터로 앱 정보를 읽는다.
// 클라이언트 시크릿까지 필요하므로(네이버 SDK 규격) 같은 미추적 파일에서 읽어 주입한다.
//   naverClientId=xxxx / naverClientSecret=xxxx / naverClientName=ART NARA
fun localOrEnv(key: String, env: String, fallback: String = ""): String =
    localProperties.getProperty(key) ?: System.getenv(env) ?: fallback

val naverClientId: String = localOrEnv("naverClientId", "NAVER_CLIENT_ID")
val naverClientSecret: String = localOrEnv("naverClientSecret", "NAVER_CLIENT_SECRET")
val naverClientName: String = localOrEnv("naverClientName", "NAVER_CLIENT_NAME", "ART NARA")

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
        manifestPlaceholders["naverClientId"] = naverClientId
        manifestPlaceholders["naverClientSecret"] = naverClientSecret
        manifestPlaceholders["naverClientName"] = naverClientName
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
