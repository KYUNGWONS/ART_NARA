enum AppLanguage { ko, en, ja, zh }

class AppStrings {
  AppStrings._();

  // 언어 표시 정보
  static const Map<AppLanguage, String> languageLabels = {
    AppLanguage.ko: '한국어',
    AppLanguage.en: 'English',
    AppLanguage.ja: '日本語',
    AppLanguage.zh: '中文',
  };

  static const Map<AppLanguage, String> languageFlags = {
    AppLanguage.ko: '🇰🇷',
    AppLanguage.en: '🇺🇸',
    AppLanguage.ja: '🇯🇵',
    AppLanguage.zh: '🇨🇳',
  };

  // ─── 랜딩 화면 ───
  static const Map<AppLanguage, String> landingTagline = {
    AppLanguage.ko: '한국의 진짜를 경험하는 여행',
    AppLanguage.en: 'Experience the Real Korea',
    AppLanguage.ja: '本当の韓国を体験する旅',
    AppLanguage.zh: '体验真正的韩国之旅',
  };

  static const Map<AppLanguage, String> landingSubtagline = {
    AppLanguage.ko: '한국 대학생 친구와 함께하는 로컬 여행 매칭',
    AppLanguage.en: 'Local travel matching with Korean university students',
    AppLanguage.ja: '韓国の大学生と一緒にローカル旅行マッチング',
    AppLanguage.zh: '与韩国大学生一起的本地旅行匹配',
  };

  static const Map<AppLanguage, String> landingStart = {
    AppLanguage.ko: '시작하기',
    AppLanguage.en: 'Get Started',
    AppLanguage.ja: 'はじめる',
    AppLanguage.zh: '开始',
  };

  // ─── 온보딩 공통 ───
  static const Map<AppLanguage, String> back = {
    AppLanguage.ko: '돌아가기',
    AppLanguage.en: 'Back',
    AppLanguage.ja: '戻る',
    AppLanguage.zh: '返回',
  };

  static const Map<AppLanguage, String> skip = {
    AppLanguage.ko: '건너뛰기',
    AppLanguage.en: 'Skip',
    AppLanguage.ja: 'スキップ',
    AppLanguage.zh: '跳过',
  };

  static const Map<AppLanguage, String> next = {
    AppLanguage.ko: '다음으로',
    AppLanguage.en: 'Next',
    AppLanguage.ja: '次へ',
    AppLanguage.zh: '下一步',
  };

  static const Map<AppLanguage, String> getStarted = {
    AppLanguage.ko: '지금, 바로 시작해보세요!',
    AppLanguage.en: 'Start ArtNara 🎉',
    AppLanguage.ja: 'ArtNaraをはじめよう 🎉',
    AppLanguage.zh: '开始ArtNara 🎉',
  };

  static const Map<AppLanguage, String> loginComingSoon = {
    AppLanguage.ko: '로그인 화면은 곧 만들어질 거예요! 🚀',
    AppLanguage.en: 'Login screen is coming soon! 🚀',
    AppLanguage.ja: 'ログイン画面はもうすぐ完成します！🚀',
    AppLanguage.zh: '登录页面即将上线！🚀',
  };

  static const Map<AppLanguage, String> selectLanguage = {
    AppLanguage.ko: '언어 선택',
    AppLanguage.en: 'Select Language',
    AppLanguage.ja: '言語を選択',
    AppLanguage.zh: '选择语言',
  };

  // ─── 온보딩 1페이지 (대학생 친화·친근 톤) ───
  static const Map<AppLanguage, String> onboarding1Title = {
    AppLanguage.ko: '한국 대학생이랑\n진짜 한국 맛보기',
    AppLanguage.en: 'Explore Korea with\nFellow Students',
    AppLanguage.ja: '同じ大学生と\n本当の韓国を味わおう',
    AppLanguage.zh: '和同龄大学生一起\n体验真正的韩国',
  };

  static const Map<AppLanguage, String> onboarding1Desc = {
    AppLanguage.ko:
        '우리 서비스는 한국 대학생이랑\n방문한 외국인 친구들을 이어줘요.\n가이드북엔 없는 숨은 맛집·골목까지!',
    AppLanguage.en:
        'We connect Korean uni students\nwith visitors from abroad.\nHidden spots & local eats, not in guidebooks!',
    AppLanguage.ja: '韓国の大学生と訪れた外国人を\nつなぐサービス。\nガイドに載ってない穴場まで！',
    AppLanguage.zh: '连接韩国大学生和来访的外国朋友。\n连旅行指南里没有的宝藏地都能一起去！',
  };

  // ─── 온보딩 2페이지 ───
  static const Map<AppLanguage, String> onboarding2Title = {
    AppLanguage.ko: '취향 맞는 친구\n한 명이면 충분해요',
    AppLanguage.en: 'One Buddy Who\nGets You',
    AppLanguage.ja: '趣味が合う友達が\nいれば十分',
    AppLanguage.zh: '有一个志趣相投的伙伴就够啦',
  };

  static const Map<AppLanguage, String> onboarding2Desc = {
    AppLanguage.ko:
        '관심사, 여행 스타일만 골라두면\n나랑 잘 맞는 메이트를 추천해줘요.\n서울·부산·제주 어디든 현지 대학생이랑 같이!',
    AppLanguage.en:
        'Pick your interests & travel style—\nwe’ll suggest a mate who fits.\nSeoul, Busan, Jeju: a local student’s with you!',
    AppLanguage.ja: '興味と旅行スタイルを選ぶだけ。\nぴったりのメイトを紹介！\nソウル・釜山・済州、現地の大学生と。',
    AppLanguage.zh: '选好兴趣和旅行风格，\n我们会推荐和你合得来的伙伴。\n首尔、釜山、济州，都有当地大学生一起！',
  };

  // ─── 온보딩 3페이지 ───
  static const Map<AppLanguage, String> onboarding3Title = {
    AppLanguage.ko: '일정은 우리끼리\n채팅으로 OK',
    AppLanguage.en: 'Plan It Together\nin Chat',
    AppLanguage.ja: '予定はチャットで\n私たちでOK',
    AppLanguage.zh: '行程我们聊天里定就行',
  };

  static const Map<AppLanguage, String> onboarding3Desc = {
    AppLanguage.ko:
        '추천 코스 참고하거나 맘대로 짜도 되고,\n채팅으로 약속만 잡으면 끝!\n이제 진짜 로컬 여행 시작해볼까요?',
    AppLanguage.en:
        'Use suggested routes or plan your own.\nJust chat and set a date—done!\nReady for a real local trip?',
    AppLanguage.ja: 'おすすめコースを参考にしても、自分で組んでもOK。\nチャットで約束するだけ！\n本当のローカル旅、始めよう。',
    AppLanguage.zh: '可以参考推荐路线，也可以自己排。\n聊着天把约定定好就行！\n要开始真正的本地旅行了吗？',
  };

  // ─── 로그인 화면 ───
  static const Map<AppLanguage, String> loginTitle = {
    AppLanguage.ko: '여행을 시작해볼까요?',
    AppLanguage.en: 'Ready to start your trip?',
    AppLanguage.ja: '旅を始めましょう！',
    AppLanguage.zh: '准备开始旅行了吗？',
  };

  static const Map<AppLanguage, String> loginWithKakao = {
    AppLanguage.ko: '카카오로 시작하기',
    AppLanguage.en: 'Continue with Kakao',
    AppLanguage.ja: 'カカオでログイン',
    AppLanguage.zh: '使用Kakao登录',
  };

  static const Map<AppLanguage, String> loginWithGoogle = {
    AppLanguage.ko: 'Google로 시작하기',
    AppLanguage.en: 'Continue with Google',
    AppLanguage.ja: 'Googleでログイン',
    AppLanguage.zh: '使用Google登录',
  };

  static const Map<AppLanguage, String> loginError = {
    AppLanguage.ko: '로그인에 실패했어요. 다시 시도해주세요.',
    AppLanguage.en: 'Login failed. Please try again.',
    AppLanguage.ja: 'ログインに失敗しました。もう一度お試しください。',
    AppLanguage.zh: '登录失败，请重试。',
  };

  static const Map<AppLanguage, String> loginSuccess = {
    AppLanguage.ko: '로그인 성공! 환영합니다 🎉',
    AppLanguage.en: 'Login successful! Welcome 🎉',
    AppLanguage.ja: 'ログイン成功！ようこそ 🎉',
    AppLanguage.zh: '登录成功！欢迎 🎉',
  };

  // ─── 역할 선택 화면 ───
  static const Map<AppLanguage, String> roleTitle = {
    AppLanguage.ko: '당신은 누구인가요?',
    AppLanguage.en: 'Who are you?',
    AppLanguage.ja: 'あなたはどちらですか？',
    AppLanguage.zh: '你是谁？',
  };

  static const Map<AppLanguage, String> roleSubtitle = {
    AppLanguage.ko: '맞춤형 여행 경험을 위해 알려주세요',
    AppLanguage.en: 'Let us know for a personalized experience',
    AppLanguage.ja: 'カスタマイズされた体験のために教えてください',
    AppLanguage.zh: '请告诉我们以获得个性化体验',
  };

  static const Map<AppLanguage, String> roleKoreanStudent = {
    AppLanguage.ko: '한국인 대학생',
    AppLanguage.en: 'Korean Student',
    AppLanguage.ja: '韓国人大学生',
    AppLanguage.zh: '韩国大学生',
  };

  static const Map<AppLanguage, String> roleKoreanStudentDesc = {
    AppLanguage.ko: '외국인 친구에게 한국을 소개하고 싶어요',
    AppLanguage.en: 'I want to show Korea to foreign friends',
    AppLanguage.ja: '外国人の友達に韓国を紹介したい',
    AppLanguage.zh: '我想向外国朋友介绍韩国',
  };

  static const Map<AppLanguage, String> roleForeigner = {
    AppLanguage.ko: '외국인 여행자',
    AppLanguage.en: 'Foreign Traveler',
    AppLanguage.ja: '外国人旅行者',
    AppLanguage.zh: '外国旅行者',
  };

  static const Map<AppLanguage, String> roleForeignerDesc = {
    AppLanguage.ko: '한국 현지 친구와 함께 여행하고 싶어요',
    AppLanguage.en: 'I want to travel with a local Korean friend',
    AppLanguage.ja: '韓国の現地の友達と旅行したい',
    AppLanguage.zh: '我想和韩国当地朋友一起旅行',
  };

  // ─── 프로필 설정 화면 ───
  static const Map<AppLanguage, String> profileTitle = {
    AppLanguage.ko: '프로필 설정',
    AppLanguage.en: 'Profile Setup',
    AppLanguage.ja: 'プロフィール設定',
    AppLanguage.zh: '个人资料设置',
  };

  static const Map<AppLanguage, String> profileSubtitle = {
    AppLanguage.ko: '이 정보는 여행 파트너에게 공개됩니다',
    AppLanguage.en: 'This info is shared with your travel partner',
    AppLanguage.ja: 'この情報は旅行パートナーに公開されます',
    AppLanguage.zh: '此信息将向您的旅行伙伴公开',
  };

  // ─── 프로필 설정 개편 (단일 폼) 신규 문자열 ───
  static const Map<AppLanguage, String> profileName = {
    AppLanguage.ko: '이름',
    AppLanguage.en: 'Name',
    AppLanguage.ja: '名前',
    AppLanguage.zh: '姓名',
  };

  static const Map<AppLanguage, String> profileNameHint = {
    AppLanguage.ko: '이름을 입력하세요',
    AppLanguage.en: 'Enter your name',
    AppLanguage.ja: '名前を入力してください',
    AppLanguage.zh: '请输入姓名',
  };

  static const Map<AppLanguage, String> profileNicknameInputHint = {
    AppLanguage.ko: '닉네임을 입력하세요',
    AppLanguage.en: 'Enter a nickname',
    AppLanguage.ja: 'ニックネームを入力してください',
    AppLanguage.zh: '请输入昵称',
  };

  static const Map<AppLanguage, String> profileCurrentRegion = {
    AppLanguage.ko: '현재 거주지역',
    AppLanguage.en: 'Current Region',
    AppLanguage.ja: '現在の居住地域',
    AppLanguage.zh: '当前居住地区',
  };

  static const Map<AppLanguage, String> regionPickerHint = {
    AppLanguage.ko: '지역을 선택하세요',
    AppLanguage.en: 'Select a region',
    AppLanguage.ja: '地域を選択してください',
    AppLanguage.zh: '请选择地区',
  };

  static const Map<AppLanguage, String> travelerInfoTitle = {
    AppLanguage.ko: '여행자 정보',
    AppLanguage.en: 'Traveler Info',
    AppLanguage.ja: '旅行者情報',
    AppLanguage.zh: '旅行者信息',
  };

  static const Map<AppLanguage, String> travelerInfoSubtitle = {
    AppLanguage.ko: '한국에서의 여행 매칭에 활용됩니다',
    AppLanguage.en: 'Used for travel matching in Korea',
    AppLanguage.ja: '韓国での旅行マッチングに活用されます',
    AppLanguage.zh: '用于在韩国的旅行匹配',
  };

  static const Map<AppLanguage, String> profileLanguage = {
    AppLanguage.ko: '언어',
    AppLanguage.en: 'Language',
    AppLanguage.ja: '言語',
    AppLanguage.zh: '语言',
  };

  static const Map<AppLanguage, String> languageSelectHint = {
    AppLanguage.ko: '구사 가능한 언어를 모두 선택하세요',
    AppLanguage.en: 'Select all languages you speak',
    AppLanguage.ja: '話せる言語をすべて選択してください',
    AppLanguage.zh: '请选择您会说的所有语言',
  };

  static const Map<AppLanguage, String> interestsPick = {
    AppLanguage.ko: '관심사 선택',
    AppLanguage.en: 'Select Interests',
    AppLanguage.ja: '興味を選択',
    AppLanguage.zh: '选择兴趣',
  };

  static const Map<AppLanguage, String> interestsPickSubtitle = {
    AppLanguage.ko: '딱 맞는 여행 메이트를 찾아드려요',
    AppLanguage.en: 'We\'ll find your perfect travel mate',
    AppLanguage.ja: 'ぴったりの旅行メイトを見つけます',
    AppLanguage.zh: '为您找到合适的旅行伙伴',
  };

  static const Map<AppLanguage, String> interestsPickHelper = {
    AppLanguage.ko: '관심 있는 항목을 선택하세요',
    AppLanguage.en: 'Choose the items you\'re interested in',
    AppLanguage.ja: '興味のある項目を選択してください',
    AppLanguage.zh: '请选择您感兴趣的项目',
  };

  static const Map<AppLanguage, String> travelStyleTitle = {
    AppLanguage.ko: '나의 여행 스타일',
    AppLanguage.en: 'My Travel Style',
    AppLanguage.ja: '私の旅行スタイル',
    AppLanguage.zh: '我的旅行风格',
  };

  static const Map<AppLanguage, String> travelStyleSubtitle = {
    AppLanguage.ko: '슬라이더로 나를 표현해보세요',
    AppLanguage.en: 'Express yourself with the sliders',
    AppLanguage.ja: 'スライダーで自分を表現しましょう',
    AppLanguage.zh: '用滑块表达自己',
  };

  // 슬라이더 라벨 4개
  static const Map<AppLanguage, String> planStyleLabel = {
    AppLanguage.ko: '계획 스타일',
    AppLanguage.en: 'Planning Style',
    AppLanguage.ja: '計画スタイル',
    AppLanguage.zh: '计划风格',
  };

  static const Map<AppLanguage, String> vibeLabel = {
    AppLanguage.ko: '분위기',
    AppLanguage.en: 'Vibe',
    AppLanguage.ja: '雰囲気',
    AppLanguage.zh: '氛围',
  };

  static const Map<AppLanguage, String> roleLabel = {
    AppLanguage.ko: '역할',
    AppLanguage.en: 'Role',
    AppLanguage.ja: '役割',
    AppLanguage.zh: '角色',
  };

  static const Map<AppLanguage, String> activityAmountLabel = {
    AppLanguage.ko: '활동량',
    AppLanguage.en: 'Activity',
    AppLanguage.ja: '活動量',
    AppLanguage.zh: '活动量',
  };

  // 슬라이더 양끝 라벨 8개
  static const Map<AppLanguage, String> spontaneousLabel = {
    AppLanguage.ko: '즉흥적',
    AppLanguage.en: 'Spontaneous',
    AppLanguage.ja: '即興的',
    AppLanguage.zh: '随性',
  };

  static const Map<AppLanguage, String> thoroughPlanLabel = {
    AppLanguage.ko: '철저한 계획',
    AppLanguage.en: 'Well-planned',
    AppLanguage.ja: '綿密な計画',
    AppLanguage.zh: '周密计划',
  };

  static const Map<AppLanguage, String> energeticLabel = {
    AppLanguage.ko: '에너지 넘치는',
    AppLanguage.en: 'Energetic',
    AppLanguage.ja: 'エネルギッシュ',
    AppLanguage.zh: '充满活力',
  };

  static const Map<AppLanguage, String> relaxedLabel = {
    AppLanguage.ko: '여유로운',
    AppLanguage.en: 'Relaxed',
    AppLanguage.ja: 'ゆったり',
    AppLanguage.zh: '悠闲',
  };

  static const Map<AppLanguage, String> leadLabel = {
    AppLanguage.ko: '리드하는 편',
    AppLanguage.en: 'Leader',
    AppLanguage.ja: 'リードする',
    AppLanguage.zh: '主导型',
  };

  static const Map<AppLanguage, String> followLabel = {
    AppLanguage.ko: '따라가는 편',
    AppLanguage.en: 'Follower',
    AppLanguage.ja: '付いていく',
    AppLanguage.zh: '跟随型',
  };

  static const Map<AppLanguage, String> quietLabel = {
    AppLanguage.ko: '조용하게',
    AppLanguage.en: 'Quiet',
    AppLanguage.ja: '静かに',
    AppLanguage.zh: '安静',
  };

  static const Map<AppLanguage, String> veryActiveLabel = {
    AppLanguage.ko: '매우 활동적',
    AppLanguage.en: 'Very active',
    AppLanguage.ja: 'とても活動的',
    AppLanguage.zh: '非常活跃',
  };

  // 관심사 8개 (피그마 개편)
  static const Map<AppLanguage, String> interestFoodCafe = {
    AppLanguage.ko: '음식 & 카페',
    AppLanguage.en: 'Food & Cafe',
    AppLanguage.ja: 'グルメ & カフェ',
    AppLanguage.zh: '美食 & 咖啡',
  };

  static const Map<AppLanguage, String> interestLocal = {
    AppLanguage.ko: '로컬 탐방',
    AppLanguage.en: 'Local Exploring',
    AppLanguage.ja: 'ローカル探訪',
    AppLanguage.zh: '本地探索',
  };

  static const Map<AppLanguage, String> interestShopping = {
    AppLanguage.ko: '팝업스토어 & 쇼핑',
    AppLanguage.en: 'Pop-up & Shopping',
    AppLanguage.ja: 'ポップアップ & ショッピング',
    AppLanguage.zh: '快闪店 & 购物',
  };

  static const Map<AppLanguage, String> interestNature = {
    AppLanguage.ko: '자연 & 피크닉',
    AppLanguage.en: 'Nature & Picnic',
    AppLanguage.ja: '自然 & ピクニック',
    AppLanguage.zh: '自然 & 野餐',
  };

  static const Map<AppLanguage, String> interestTraditionalActivity = {
    AppLanguage.ko: '전통놀이 & 액티비티',
    AppLanguage.en: 'Tradition & Activity',
    AppLanguage.ja: '伝統遊び & アクティビティ',
    AppLanguage.zh: '传统游戏 & 活动',
  };

  static const Map<AppLanguage, String> interestPhoto = {
    AppLanguage.ko: '사진',
    AppLanguage.en: 'Photography',
    AppLanguage.ja: '写真',
    AppLanguage.zh: '摄影',
  };

  static const Map<AppLanguage, String> interestFestival = {
    AppLanguage.ko: '축제 & 행사',
    AppLanguage.en: 'Festival & Event',
    AppLanguage.ja: 'フェス & イベント',
    AppLanguage.zh: '庆典 & 活动',
  };

  static const Map<AppLanguage, String> interestArtCulture = {
    AppLanguage.ko: '예술 & 문화',
    AppLanguage.en: 'Art & Culture',
    AppLanguage.ja: 'アート & 文化',
    AppLanguage.zh: '艺术 & 文化',
  };

  static const Map<AppLanguage, String> profilePhoto = {
    AppLanguage.ko: '프로필 사진',
    AppLanguage.en: 'Profile Photo',
    AppLanguage.ja: 'プロフィール写真',
    AppLanguage.zh: '头像',
  };

  static const Map<AppLanguage, String> profileNickname = {
    AppLanguage.ko: '닉네임',
    AppLanguage.en: 'Nickname',
    AppLanguage.ja: 'ニックネーム',
    AppLanguage.zh: '昵称',
  };

  static const Map<AppLanguage, String> profileNicknameHint = {
    AppLanguage.ko: '다른 사용자에게 보여질 이름이에요',
    AppLanguage.en: 'This name will be visible to others',
    AppLanguage.ja: '他のユーザーに表示される名前です',
    AppLanguage.zh: '此名称将对其他用户可见',
  };

  static const Map<AppLanguage, String> profileAge = {
    AppLanguage.ko: '나이',
    AppLanguage.en: 'Age',
    AppLanguage.ja: '年齢',
    AppLanguage.zh: '年龄',
  };

  static const Map<AppLanguage, String> profileAgeHint = {
    AppLanguage.ko: '만 나이를 입력하세요 (예: 24)',
    AppLanguage.en: 'Enter your age (e.g. 24)',
    AppLanguage.ja: '年齢を入力してください（例：24）',
    AppLanguage.zh: '请输入您的年龄（例如：24）',
  };

  static const Map<AppLanguage, String> profileAddress = {
    AppLanguage.ko: '주소',
    AppLanguage.en: 'Address',
    AppLanguage.ja: '住所',
    AppLanguage.zh: '地址',
  };

  static const Map<AppLanguage, String> profileAddressHint = {
    AppLanguage.ko: '도시 또는 지역을 입력하세요',
    AppLanguage.en: 'Enter your city or region',
    AppLanguage.ja: '都市または地域を入力してください',
    AppLanguage.zh: '请输入城市或地区',
  };

  static const Map<AppLanguage, String> profileAddressDetail = {
    AppLanguage.ko: '상세 주소',
    AppLanguage.en: 'Detail Address',
    AppLanguage.ja: '詳細住所',
    AppLanguage.zh: '详细地址',
  };

  static const Map<AppLanguage, String> profileAddressDetailHint = {
    AppLanguage.ko: '건물명, 호수 등 (선택)',
    AppLanguage.en: 'Building, room number, etc. (optional)',
    AppLanguage.ja: '建物名、部屋番号など（任意）',
    AppLanguage.zh: '楼栋、门牌号等（选填）',
  };

  // ─── 관심사 선택 화면 ───
  static const Map<AppLanguage, String> interestsTitle = {
    AppLanguage.ko: '관심사를 선택해주세요',
    AppLanguage.en: 'Choose your interests',
    AppLanguage.ja: '興味を選んでください',
    AppLanguage.zh: '选择您的兴趣',
  };

  static const Map<AppLanguage, String> interestsSubtitle = {
    AppLanguage.ko: '딱 맞는 여행 버디를 찾는 데 도움이 돼요',
    AppLanguage.en: 'Helps us find your perfect travel buddy',
    AppLanguage.ja: 'ぴったりの旅行バディを探すのに役立ちます',
    AppLanguage.zh: '帮助我们为您找到完美的旅行伙伴',
  };

  static const Map<AppLanguage, String> interestTravel = {
    AppLanguage.ko: '여행',
    AppLanguage.en: 'Travel',
    AppLanguage.ja: '旅行',
    AppLanguage.zh: '旅行',
  };

  static const Map<AppLanguage, String> interestFood = {
    AppLanguage.ko: '맛집',
    AppLanguage.en: 'Gourmet',
    AppLanguage.ja: 'グルメ',
    AppLanguage.zh: '美食',
  };

  static const Map<AppLanguage, String> interestActivity = {
    AppLanguage.ko: '액티비티',
    AppLanguage.en: 'Activity',
    AppLanguage.ja: 'アクティビティ',
    AppLanguage.zh: '活动',
  };

  static const Map<AppLanguage, String> interestCulture = {
    AppLanguage.ko: '문화/예술',
    AppLanguage.en: 'Culture/Art',
    AppLanguage.ja: '文化/芸術',
    AppLanguage.zh: '文化/艺术',
  };

  static const Map<AppLanguage, String> interestCafe = {
    AppLanguage.ko: '카페',
    AppLanguage.en: 'Cafe',
    AppLanguage.ja: 'カフェ',
    AppLanguage.zh: '咖啡厅',
  };

  static const Map<AppLanguage, String> interestUnique = {
    AppLanguage.ko: '이색체험',
    AppLanguage.en: 'Unique Experience',
    AppLanguage.ja: 'ユニーク体験',
    AppLanguage.zh: '特色体验',
  };

  static const Map<AppLanguage, String> complete = {
    AppLanguage.ko: '완료',
    AppLanguage.en: 'Done',
    AppLanguage.ja: '完了',
    AppLanguage.zh: '完成',
  };

  static const Map<AppLanguage, String> profileSetupComplete = {
    AppLanguage.ko: '프로필 설정 완료! 🎉',
    AppLanguage.en: 'Profile setup complete! 🎉',
    AppLanguage.ja: 'プロフィール設定完了！🎉',
    AppLanguage.zh: '个人资料设置完成！🎉',
  };

  // 회원가입(POST /api/users) 실패 안내
  static const Map<AppLanguage, String> signupEmailConflict = {
    AppLanguage.ko: '이미 가입된 이메일이에요',
    AppLanguage.en: 'This email is already registered',
    AppLanguage.ja: 'すでに登録されているメールです',
    AppLanguage.zh: '该邮箱已被注册',
  };

  static const Map<AppLanguage, String> profileSetupError = {
    AppLanguage.ko: '프로필 저장에 실패했어요. 다시 시도해주세요',
    AppLanguage.en: 'Failed to save profile. Please try again',
    AppLanguage.ja: 'プロフィールの保存に失敗しました。もう一度お試しください',
    AppLanguage.zh: '保存个人资料失败，请重试',
  };

  // ─── 성향 슬라이더 ───
  static const Map<AppLanguage, String> personalityTitle = {
    AppLanguage.ko: '나의 여행 성향',
    AppLanguage.en: 'My Travel Style',
    AppLanguage.ja: '私の旅行スタイル',
    AppLanguage.zh: '我的旅行风格',
  };

  static const Map<AppLanguage, String> personalitySubtitle = {
    AppLanguage.ko: '슬라이더를 움직여 나를 표현해보세요',
    AppLanguage.en: 'Move the sliders to express yourself',
    AppLanguage.ja: 'スライダーを動かして自分を表現しよう',
    AppLanguage.zh: '滑动滑块来表达自己',
  };

  static const Map<AppLanguage, String> planningLabel = {
    AppLanguage.ko: '계획성',
    AppLanguage.en: 'Planning',
    AppLanguage.ja: '計画性',
    AppLanguage.zh: '计划性',
  };

  static const Map<AppLanguage, String> spontaneous = {
    AppLanguage.ko: '즉흥형',
    AppLanguage.en: 'Spontaneous',
    AppLanguage.ja: '即興型',
    AppLanguage.zh: '即兴型',
  };

  static const Map<AppLanguage, String> planned = {
    AppLanguage.ko: '계획형',
    AppLanguage.en: 'Planned',
    AppLanguage.ja: '計画型',
    AppLanguage.zh: '计划型',
  };

  static const Map<AppLanguage, String> activityLevelLabel = {
    AppLanguage.ko: '활발도',
    AppLanguage.en: 'Activity Level',
    AppLanguage.ja: '活発さ',
    AppLanguage.zh: '活跃度',
  };

  static const Map<AppLanguage, String> veryActive = {
    AppLanguage.ko: '활발한 편',
    AppLanguage.en: 'Very Active',
    AppLanguage.ja: '活発な方',
    AppLanguage.zh: '非常活跃',
  };

  static const Map<AppLanguage, String> quiet = {
    AppLanguage.ko: '조용한 편',
    AppLanguage.en: 'Quiet',
    AppLanguage.ja: '静かな方',
    AppLanguage.zh: '安静型',
  };

  // ─── 자기소개 ───
  static const Map<AppLanguage, String> bioTitle = {
    AppLanguage.ko: '자기소개',
    AppLanguage.en: 'About Me',
    AppLanguage.ja: '自己紹介',
    AppLanguage.zh: '自我介绍',
  };

  static const Map<AppLanguage, String> bioHint = {
    AppLanguage.ko: '간단한 자기소개를 작성해보세요',
    AppLanguage.en: 'Write a short introduction about yourself',
    AppLanguage.ja: '簡単な自己紹介を書いてみましょう',
    AppLanguage.zh: '写一段简短的自我介绍',
  };

  // ─── 외국인 전용: 국적 & 언어 ───
  static const Map<AppLanguage, String> nationalityTitle = {
    AppLanguage.ko: '국적',
    AppLanguage.en: 'Nationality',
    AppLanguage.ja: '国籍',
    AppLanguage.zh: '国籍',
  };

  static const Map<AppLanguage, String> nationalityHint = {
    AppLanguage.ko: '국가를 검색하세요',
    AppLanguage.en: 'Search your country',
    AppLanguage.ja: '国を検索してください',
    AppLanguage.zh: '搜索您的国家',
  };

  static const Map<AppLanguage, String> languageTitle = {
    AppLanguage.ko: '구사 언어',
    AppLanguage.en: 'Languages',
    AppLanguage.ja: '使用言語',
    AppLanguage.zh: '语言能力',
  };

  static const Map<AppLanguage, String> languageSubtitle = {
    AppLanguage.ko: '구사할 수 있는 언어를 모두 선택하세요',
    AppLanguage.en: 'Select all languages you speak',
    AppLanguage.ja: '話せる言語をすべて選択してください',
    AppLanguage.zh: '选择您会说的所有语言',
  };

  // ─── 외국인 전용: 한국 방문 이력 ───
  static const Map<AppLanguage, String> visitHistoryTitle = {
    AppLanguage.ko: '한국 방문 경험',
    AppLanguage.en: 'Visited Korea Before?',
    AppLanguage.ja: '韓国訪問経験',
    AppLanguage.zh: '是否去过韩国？',
  };

  static const Map<AppLanguage, String> visitYes = {
    AppLanguage.ko: '있어요',
    AppLanguage.en: 'Yes',
    AppLanguage.ja: 'あります',
    AppLanguage.zh: '是的',
  };

  static const Map<AppLanguage, String> visitNo = {
    AppLanguage.ko: '처음이에요',
    AppLanguage.en: 'First time',
    AppLanguage.ja: '初めてです',
    AppLanguage.zh: '第一次',
  };

  static const Map<AppLanguage, String> visitCount = {
    AppLanguage.ko: '방문 횟수',
    AppLanguage.en: 'Number of visits',
    AppLanguage.ja: '訪問回数',
    AppLanguage.zh: '访问次数',
  };

  static const Map<AppLanguage, String> visitCountHint = {
    AppLanguage.ko: '몇 번 방문하셨나요?',
    AppLanguage.en: 'How many times?',
    AppLanguage.ja: '何回訪問しましたか？',
    AppLanguage.zh: '您去过几次？',
  };

  static const Map<AppLanguage, String> foreignerInfoTitle = {
    AppLanguage.ko: '여행자 정보',
    AppLanguage.en: 'Traveler Info',
    AppLanguage.ja: '旅行者情報',
    AppLanguage.zh: '旅行者信息',
  };

  static const Map<AppLanguage, String> foreignerInfoSubtitle = {
    AppLanguage.ko: '한국 여행 매칭에 활용돼요',
    AppLanguage.en: 'Used for travel matching in Korea',
    AppLanguage.ja: '韓国旅行のマッチングに活用されます',
    AppLanguage.zh: '用于韩国旅行匹配',
  };

  // ─── 메인 홈 화면 ───
  static const Map<AppLanguage, String> heroTitle = {
    AppLanguage.ko: 'Ready to knot your thread\nwith a mate?',
    AppLanguage.en: 'Ready to knot your thread\nwith a mate?',
    AppLanguage.ja: 'Ready to knot your thread\nwith a mate?',
    AppLanguage.zh: 'Ready to knot your thread\nwith a mate?',
  };

  // 추천 지역 섹션 (홈 화면, 위치 기반 추천 관광지)
  static const Map<AppLanguage, String> recommendedRegionsTitle = {
    AppLanguage.ko: '추천 지역',
    AppLanguage.en: 'Recommended',
    AppLanguage.ja: 'おすすめ',
    AppLanguage.zh: '推荐地区',
  };

  // 추천 지역 2 섹션 (홈 화면, 예시 데이터 기반 — TODO 서버 연동)
  static const Map<AppLanguage, String> recommendedRegions2Title = {
    AppLanguage.ko: '추천 지역 2',
    AppLanguage.en: 'Recommended 2',
    AppLanguage.ja: 'おすすめ 2',
    AppLanguage.zh: '推荐地区 2',
  };

  // 다가오는 축제 섹션 (홈 화면, 한국관광공사 행사정보조회)
  static const Map<AppLanguage, String> upcomingFestivalsTitle = {
    AppLanguage.ko: '다가오는 축제',
    AppLanguage.en: 'Upcoming Festivals',
    AppLanguage.ja: 'これからのお祭り',
    AppLanguage.zh: '即将举行的庆典',
  };

  // ─── 앰배서더 쇼케이스 (홈 화면 + 상세 화면, mock 데이터 기반 — TODO 서버 연동) ───
  static const Map<AppLanguage, String> ambassadorLabel = {
    AppLanguage.ko: 'KNOT AMBASSADOR',
    AppLanguage.en: 'KNOT AMBASSADOR',
    AppLanguage.ja: 'KNOT AMBASSADOR',
    AppLanguage.zh: 'KNOT AMBASSADOR',
  };

  static const Map<AppLanguage, String> ambassadorTitle = {
    AppLanguage.ko: '1기 앰배서더',
    AppLanguage.en: '1st Ambassadors',
    AppLanguage.ja: '1期アンバサダー',
    AppLanguage.zh: '第1期大使',
  };

  static const Map<AppLanguage, String> ambassadorDetailTitle = {
    AppLanguage.ko: '앰배서더',
    AppLanguage.en: 'Ambassador',
    AppLanguage.ja: 'アンバサダー',
    AppLanguage.zh: '大使',
  };

  static const Map<AppLanguage, String> ambassadorBack = {
    AppLanguage.ko: '뒤로',
    AppLanguage.en: 'Back',
    AppLanguage.ja: '戻る',
    AppLanguage.zh: '返回',
  };

  static const Map<AppLanguage, String> spokenLanguagesLabel = {
    AppLanguage.ko: '구사 언어',
    AppLanguage.en: 'Languages',
    AppLanguage.ja: '使用言語',
    AppLanguage.zh: '使用语言',
  };

  static const Map<AppLanguage, String> ongoingContentLabel = {
    AppLanguage.ko: '진행 중인 콘텐츠',
    AppLanguage.en: 'Ongoing Content',
    AppLanguage.ja: '進行中のコンテンツ',
    AppLanguage.zh: '进行中的内容',
  };

  // Mate Stories 섹션 탭 (홈 화면, mock 데이터 기반 — TODO 서버 연동)
  static const Map<AppLanguage, String> mateStoriesBestTab = {
    AppLanguage.ko: 'BEST MATES STORIES',
    AppLanguage.en: 'BEST MATES STORIES',
    AppLanguage.ja: 'BEST MATES STORIES',
    AppLanguage.zh: 'BEST MATES STORIES',
  };

  static const Map<AppLanguage, String> mateStoriesGuideTab = {
    AppLanguage.ko: 'KNOT GUIDE',
    AppLanguage.en: 'KNOT GUIDE',
    AppLanguage.ja: 'KNOT GUIDE',
    AppLanguage.zh: 'KNOT GUIDE',
  };

  static const Map<AppLanguage, String> mateStoriesQnaTab = {
    AppLanguage.ko: 'Q&A',
    AppLanguage.en: 'Q&A',
    AppLanguage.ja: 'Q&A',
    AppLanguage.zh: '问答',
  };

  static const Map<AppLanguage, String> seeMoreLabel = {
    AppLanguage.ko: '더보기',
    AppLanguage.en: 'See more',
    AppLanguage.ja: 'もっと見る',
    AppLanguage.zh: '查看更多',
  };

  // 날짜 선택 (홈 화면 일정 선택 영역)
  static const Map<AppLanguage, String> homeDateLabel = {
    AppLanguage.ko: '날짜 선택',
    AppLanguage.en: 'Select dates',
    AppLanguage.ja: '日付を選択',
    AppLanguage.zh: '选择日期',
  };

  /// 요일 약자 7개. 일요일부터 토요일 순서, 쉼표로 구분.
  static const Map<AppLanguage, String> homeWeekdayShort = {
    AppLanguage.ko: '일,월,화,수,목,금,토',
    AppLanguage.en: 'Sun,Mon,Tue,Wed,Thu,Fri,Sat',
    AppLanguage.ja: '日,月,火,水,木,金,土',
    AppLanguage.zh: '日,一,二,三,四,五,六',
  };

  static const Map<AppLanguage, String> navMap = {
    AppLanguage.ko: '맵',
    AppLanguage.en: 'Map',
    AppLanguage.ja: 'マップ',
    AppLanguage.zh: '地图',
  };

  static const Map<AppLanguage, String> navCategory = {
    AppLanguage.ko: '카테고리',
    AppLanguage.en: 'Category',
    AppLanguage.ja: 'カテゴリ',
    AppLanguage.zh: '分类',
  };

  static const Map<AppLanguage, String> navBoard = {
    AppLanguage.ko: '게시판',
    AppLanguage.en: 'Board',
    AppLanguage.ja: '掲示板',
    AppLanguage.zh: '论坛',
  };

  static const Map<AppLanguage, String> navMagazine = {
    AppLanguage.ko: '매거진',
    AppLanguage.en: 'Magazine',
    AppLanguage.ja: 'マガジン',
    AppLanguage.zh: '杂志',
  };

  static const Map<AppLanguage, String> navHome = {
    AppLanguage.ko: '홈',
    AppLanguage.en: 'Home',
    AppLanguage.ja: 'ホーム',
    AppLanguage.zh: '首页',
  };

  static const Map<AppLanguage, String> navChat = {
    AppLanguage.ko: '채팅',
    AppLanguage.en: 'Chat',
    AppLanguage.ja: 'チャット',
    AppLanguage.zh: '聊天',
  };

  static const Map<AppLanguage, String> navWish = {
    AppLanguage.ko: '위시',
    AppLanguage.en: 'Wish',
    AppLanguage.ja: 'ウィッシュ',
    AppLanguage.zh: '心愿',
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

  // ─── 콘텐츠 생성 플로우 ───
  // 상단 단계 라벨
  static const Map<AppLanguage, String> ccLabelGuideline = {
    AppLanguage.ko: 'READY TO KNOT',
    AppLanguage.en: 'READY TO KNOT',
    AppLanguage.ja: 'READY TO KNOT',
    AppLanguage.zh: 'READY TO KNOT',
  };

  static const Map<AppLanguage, String> ccLabelPlace = {
    AppLanguage.ko: '장소 선택',
    AppLanguage.en: 'Choose a place',
    AppLanguage.ja: '場所を選ぶ',
    AppLanguage.zh: '选择地点',
  };

  static const Map<AppLanguage, String> ccLabelActivity = {
    AppLanguage.ko: '활동 선택',
    AppLanguage.en: 'Choose an activity',
    AppLanguage.ja: 'アクティビティを選ぶ',
    AppLanguage.zh: '选择活动',
  };

  static const Map<AppLanguage, String> ccLabelConfirm = {
    AppLanguage.ko: '최종 확인',
    AppLanguage.en: 'Final check',
    AppLanguage.ja: '最終確認',
    AppLanguage.zh: '最终确认',
  };

  // Step 1: 가이드라인
  static const Map<AppLanguage, String> ccStep1Title = {
    AppLanguage.ko: '가이드라인에 따라\n새로운 콘텐츠를 만들어요',
    AppLanguage.en: 'Create new content\nfollowing the guideline',
    AppLanguage.ja: 'ガイドラインに沿って\n新しいコンテンツを作りましょう',
    AppLanguage.zh: '按照指南\n创建新的内容',
  };

  static const Map<AppLanguage, String> ccDaysLabel = {
    AppLanguage.ko: '가능한 요일',
    AppLanguage.en: 'Available days',
    AppLanguage.ja: '参加可能な曜日',
    AppLanguage.zh: '可参加的星期',
  };

  static const Map<AppLanguage, String> ccThemeLabel = {
    AppLanguage.ko: '테마',
    AppLanguage.en: 'Theme',
    AppLanguage.ja: 'テーマ',
    AppLanguage.zh: '主题',
  };

  static const Map<AppLanguage, String> ccTimeLabel = {
    AppLanguage.ko: '언제?',
    AppLanguage.en: 'When?',
    AppLanguage.ja: 'いつ？',
    AppLanguage.zh: '什么时候？',
  };

  // Step 2: 장소
  static const Map<AppLanguage, String> ccStep2Title = {
    AppLanguage.ko: '콘텐츠에 어울리는\n장소를 선택하세요',
    AppLanguage.en: 'Pick a place that\nsuits your content',
    AppLanguage.ja: 'コンテンツに合う\n場所を選んでください',
    AppLanguage.zh: '请选择适合内容的\n地点',
  };

  // Step 3: 활동 ({place} 자리에 선택한 장소명이 들어감)
  static const Map<AppLanguage, String> ccStep3Title = {
    AppLanguage.ko: '{place}에서\n무엇을 하고 싶나요?',
    AppLanguage.en: 'What do you want\nto do at {place}?',
    AppLanguage.ja: '{place}で\n何をしたいですか？',
    AppLanguage.zh: '想在{place}\n做些什么？',
  };

  // Step 4: 최종 확인
  static const Map<AppLanguage, String> ccStep4Title = {
    AppLanguage.ko: '나만의 콘텐츠가 완성됐어요!\n다시 한번 확인해 주세요',
    AppLanguage.en: 'Your content is ready!\nPlease check it once more',
    AppLanguage.ja: 'あなたのコンテンツが完成！\nもう一度確認してください',
    AppLanguage.zh: '你的内容已完成！\n请再确认一次',
  };

  static const Map<AppLanguage, String> ccSummaryPlace = {
    AppLanguage.ko: '장소',
    AppLanguage.en: 'Place',
    AppLanguage.ja: '場所',
    AppLanguage.zh: '地点',
  };

  static const Map<AppLanguage, String> ccSummaryActivity = {
    AppLanguage.ko: '활동',
    AppLanguage.en: 'Activity',
    AppLanguage.ja: 'アクティビティ',
    AppLanguage.zh: '活动',
  };

  static const Map<AppLanguage, String> ccSummaryDays = {
    AppLanguage.ko: '요일',
    AppLanguage.en: 'Days',
    AppLanguage.ja: '曜日',
    AppLanguage.zh: '星期',
  };

  static const Map<AppLanguage, String> ccSummaryTime = {
    AppLanguage.ko: '시간',
    AppLanguage.en: 'Time',
    AppLanguage.ja: '時間',
    AppLanguage.zh: '时间',
  };

  static const Map<AppLanguage, String> ccDescLabel = {
    AppLanguage.ko: '콘텐츠를 간단히 소개해 주세요!',
    AppLanguage.en: 'Briefly introduce your content!',
    AppLanguage.ja: 'コンテンツを簡単に紹介してください！',
    AppLanguage.zh: '请简单介绍一下你的内容！',
  };

  static const Map<AppLanguage, String> ccDescHint = {
    AppLanguage.ko: '간단한 소개를 작성해 주세요...',
    AppLanguage.en: 'Write a short introduction...',
    AppLanguage.ja: '簡単な紹介を書いてください...',
    AppLanguage.zh: '写一段简短的介绍...',
  };

  // 버튼
  static const Map<AppLanguage, String> ccNext = {
    AppLanguage.ko: '다음',
    AppLanguage.en: 'Next',
    AppLanguage.ja: '次へ',
    AppLanguage.zh: '下一步',
  };

  static const Map<AppLanguage, String> ccSubmit = {
    AppLanguage.ko: '콘텐츠 등록하기',
    AppLanguage.en: 'Register content',
    AppLanguage.ja: 'コンテンツを登録',
    AppLanguage.zh: '注册内容',
  };

  static const Map<AppLanguage, String> ccGoHome = {
    AppLanguage.ko: '홈으로 돌아가기',
    AppLanguage.en: 'Back to home',
    AppLanguage.ja: 'ホームに戻る',
    AppLanguage.zh: '返回首页',
  };

  // Step 5: 완료
  static const Map<AppLanguage, String> ccDoneTitle = {
    AppLanguage.ko: '콘텐츠 등록 완료!',
    AppLanguage.en: 'Content registered!',
    AppLanguage.ja: 'コンテンツ登録完了！',
    AppLanguage.zh: '内容注册完成！',
  };

  static const Map<AppLanguage, String> ccDoneSubtitle = {
    AppLanguage.ko: '콘텐츠가 성공적으로 등록되었습니다.',
    AppLanguage.en: 'Your content was registered successfully.',
    AppLanguage.ja: 'コンテンツが正常に登録されました。',
    AppLanguage.zh: '内容已成功注册。',
  };
}
