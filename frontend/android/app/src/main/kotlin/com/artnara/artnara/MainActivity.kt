package com.artnara.artnara

import io.flutter.embedding.android.FlutterFragmentActivity

// 네이버 로그인 SDK 가 프래그먼트를 띄우므로 FlutterActivity 가 아니라
// FlutterFragmentActivity 를 써야 한다(플러그인 요구사항).
class MainActivity : FlutterFragmentActivity()
