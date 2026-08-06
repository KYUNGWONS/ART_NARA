enum AppLanguage { ko, en, ja, zh }

class AppStrings {
  AppStrings._();

  // ─── 온보딩 공통 ───
  static const Map<AppLanguage, String> back = {
    AppLanguage.ko: '돌아가기',
    AppLanguage.en: 'Back',
    AppLanguage.ja: '戻る',
    AppLanguage.zh: '返回',
  };

  // ─── 로그인 화면 ───
  static const Map<AppLanguage, String> loginTitle = {
    AppLanguage.ko: '나만의 작품을 만나볼까요?',
    AppLanguage.en: 'Ready to discover your art?',
    AppLanguage.ja: '自分だけの作品に出会いましょう',
    AppLanguage.zh: '准备遇见属于你的艺术品了吗？',
  };

  static const Map<AppLanguage, String> loginWithKakao = {
    AppLanguage.ko: '카카오로 시작하기',
    AppLanguage.en: 'Continue with Kakao',
    AppLanguage.ja: 'カカオでログイン',
    AppLanguage.zh: '使用Kakao登录',
  };

  static const Map<AppLanguage, String> loginWithNaver = {
    AppLanguage.ko: '네이버로 시작하기',
    AppLanguage.en: 'Continue with Naver',
    AppLanguage.ja: 'NAVERでログイン',
    AppLanguage.zh: '使用NAVER登录',
  };

  static const Map<AppLanguage, String> loginError = {
    AppLanguage.ko: '로그인에 실패했어요. 다시 시도해주세요.',
    AppLanguage.en: 'Login failed. Please try again.',
    AppLanguage.ja: 'ログインに失敗しました。もう一度お試しください。',
    AppLanguage.zh: '登录失败，请重试。',
  };

  // ─── 역할 선택 화면 ───
  static const Map<AppLanguage, String> roleTitle = {
    AppLanguage.ko: '어떤 회원으로 시작할까요?',
    AppLanguage.en: 'How would you like to start?',
    AppLanguage.ja: 'どちらで始めますか？',
    AppLanguage.zh: '您想以什么身份开始？',
  };

  static const Map<AppLanguage, String> roleSubtitle = {
    AppLanguage.ko: '역할에 맞는 화면과 기능을 준비해드려요',
    AppLanguage.en: 'We tailor the experience to your role',
    AppLanguage.ja: '役割に合わせた機能をご用意します',
    AppLanguage.zh: '我们会为您的角色定制体验',
  };

  static const Map<AppLanguage, String> roleKoreanStudent = {
    AppLanguage.ko: '작가',
    AppLanguage.en: 'Artist',
    AppLanguage.ja: '作家',
    AppLanguage.zh: '艺术家',
  };

  static const Map<AppLanguage, String> roleKoreanStudentDesc = {
    AppLanguage.ko: '내 작품을 등록하고 판매하고 싶어요',
    AppLanguage.en: 'I want to list and sell my artworks',
    AppLanguage.ja: '自分の作品を登録して販売したい',
    AppLanguage.zh: '我想上传并出售我的作品',
  };

  static const Map<AppLanguage, String> roleForeigner = {
    AppLanguage.ko: '컬렉터',
    AppLanguage.en: 'Collector',
    AppLanguage.ja: 'コレクター',
    AppLanguage.zh: '收藏家',
  };

  static const Map<AppLanguage, String> roleForeignerDesc = {
    AppLanguage.ko: '마음에 드는 작품을 발견하고 소장하고 싶어요',
    AppLanguage.en: 'I want to discover and collect artworks',
    AppLanguage.ja: '気に入った作品を見つけて所蔵したい',
    AppLanguage.zh: '我想发现并收藏喜欢的作品',
  };

  /// 요일 약자 7개. 일요일부터 토요일 순서, 쉼표로 구분.

  static const Map<AppLanguage, String> navMap = {
    AppLanguage.ko: '지도',
    AppLanguage.en: 'Map',
    AppLanguage.ja: 'マップ',
    AppLanguage.zh: '地图',
  };

  static const Map<AppLanguage, String> navSell = {
    AppLanguage.ko: '판매',
    AppLanguage.en: 'Sell',
    AppLanguage.ja: '出品',
    AppLanguage.zh: '出售',
  };

  static const Map<AppLanguage, String> navCommission = {
    AppLanguage.ko: '제작의뢰',
    AppLanguage.en: 'Request',
    AppLanguage.ja: '依頼',
    AppLanguage.zh: '定制',
  };

  static const Map<AppLanguage, String> navHome = {
    AppLanguage.ko: '홈',
    AppLanguage.en: 'Home',
    AppLanguage.ja: 'ホーム',
    AppLanguage.zh: '首页',
  };

  static const Map<AppLanguage, String> navNotifications = {
    AppLanguage.ko: '알림',
    AppLanguage.en: 'Alerts',
    AppLanguage.ja: '通知',
    AppLanguage.zh: '通知',
  };

  static const Map<AppLanguage, String> navMyPage = {
    AppLanguage.ko: '마이페이지',
    AppLanguage.en: 'My',
    AppLanguage.ja: 'マイページ',
    AppLanguage.zh: '我的',
  };

  // ─── 설정 / 로그아웃 ───
  static const Map<AppLanguage, String> settings = {
    AppLanguage.ko: '설정',
    AppLanguage.en: 'Settings',
    AppLanguage.ja: '設定',
    AppLanguage.zh: '设置',
  };

  static const Map<AppLanguage, String> logout = {
    AppLanguage.ko: '로그아웃',
    AppLanguage.en: 'Log out',
    AppLanguage.ja: 'ログアウト',
    AppLanguage.zh: '退出登录',
  };

  static const Map<AppLanguage, String> logoutConfirm = {
    AppLanguage.ko: '정말 로그아웃 하시겠어요?',
    AppLanguage.en: 'Are you sure you want to log out?',
    AppLanguage.ja: '本当にログアウトしますか？',
    AppLanguage.zh: '确定要退出登录吗？',
  };

  static const Map<AppLanguage, String> cancel = {
    AppLanguage.ko: '취소',
    AppLanguage.en: 'Cancel',
    AppLanguage.ja: 'キャンセル',
    AppLanguage.zh: '取消',
  };

}
