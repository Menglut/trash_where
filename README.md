# 이거 어디 버려?

AI 사진 인식과 직접 검색을 통해 생활 속 물건의 분리배출 방법을 안내하는 Flutter 기반 모바일 앱입니다.

## 프로젝트 소개

`이거 어디 버려?`는 사용자가 버리기 어려운 물건을 사진으로 촬영하거나 직접 검색하면, AI가 물건의 종류와 재질을 분석해 분리배출 방법을 알려주는 앱입니다.

분리배출 기준은 물건의 재질, 오염 여부, 지역별 배출 기준에 따라 달라질 수 있기 때문에 사용자가 직접 지역과 배출 요일을 설정할 수 있도록 구성했습니다. 또한 최근 검색 기록과 분리배출 가이드 기능을 제공하여 자주 찾는 정보를 빠르게 다시 확인할 수 있습니다.

## 주요 기능

### AI 사진 인식

- 카메라 촬영 또는 앨범 이미지 선택
- OpenAI API를 이용한 이미지 분석
- 물건 이름, 분류, 배출 방법, 주의사항 안내
- 인식이 애매한 경우 추가 확인 질문 제공

### 직접 검색

- 물건 이름을 직접 입력해 분리배출 방법 검색
- 재질이나 상태를 함께 입력하면 더 구체적인 결과 제공
- 최근 검색 기록 저장 및 재검색 지원

### 지역 설정

- 사용자가 직접 거주 지역 설정
- 일반쓰레기, 재활용, 음식물쓰레기 배출 요일 선택
- 설정한 지역과 배출일 정보를 AI 인식 및 검색 결과에 함께 반영

### 분리배출 가이드

- 종이, 플라스틱, 캔, 유리, 비닐 등 주요 품목별 배출 기준 제공
- 자주 헷갈리는 분리배출 상황을 빠르게 확인 가능

### 앱 설정

- 다크 모드 지원
- 앱 정보 확인
- 커스텀 앱 아이콘 및 스플래시 화면 적용

## 사용 기술

- Flutter
- Dart
- OpenAI API
- `flutter_dotenv`
- `http`
- `image_picker`
- `geolocator`
- `geocoding`
- `shared_preferences`

## 실행 방법

### 1. 저장소 클론

```bash
git clone https://github.com/username/repository-name.git
cd repository-name
```

### 2. 패키지 설치

```bash
flutter pub get
```

### 3. 환경 변수 파일 생성

프로젝트 루트에 `.env` 파일을 생성하고 OpenAI API 키를 입력합니다.

```env
OPENAI_API_KEY=your_openai_api_key
OPENAI_MODEL=gpt-5.4-mini
```

보안을 위해 실제 API 키가 들어간 `.env` 파일은 GitHub에 업로드하지 않습니다.  
필요한 환경 변수 형식은 `.env.example` 파일을 참고하면 됩니다.

### 4. 앱 실행

```bash
flutter run
```

## 실행 화면

과제 제출 시 아래 표에 실행 화면 캡처 이미지를 추가합니다.

| 스플래시 화면 | 메인 화면 |
| --- | --- |
| 이미지 추가 | 이미지 추가 |

| AI 사진 인식 | 직접 검색 |
| --- | --- |
| 이미지 추가 | 이미지 추가 |

## 프로젝트 구조

```text
lib/
├── main.dart
├── models/
│   └── waste_recognition_result.dart
├── screens/
│   ├── splash_screen.dart
│   ├── home_screen.dart
│   ├── ai_recognition_screen.dart
│   ├── search_screen.dart
│   ├── location_settings_screen.dart
│   ├── recycling_guide_screen.dart
│   └── settings_screen.dart
├── services/
│   ├── waste_ai_service.dart
│   ├── location_preference_service.dart
│   ├── recent_search_service.dart
│   └── app_settings_service.dart
└── widgets/
    └── app_side_menu.dart
```

## 핵심 구현 내용

- OpenAI API를 활용해 사진 속 물건을 분석하고 JSON 형태의 결과를 앱 화면에 표시했습니다.
- AI 분석 결과가 완전하지 않을 수 있는 경우를 고려하여 추가 질문 화면을 구성했습니다.
- `shared_preferences`를 사용해 지역 설정, 배출 요일, 최근 검색 기록, 다크 모드 설정을 로컬에 저장했습니다.
- 카메라, 앨범, 직접 검색, 지역 설정, 가이드, 설정 화면을 메뉴를 통해 이동할 수 있도록 구성했습니다.
- Android 앱 아이콘과 네이티브 스플래시 화면을 커스텀 디자인에 맞게 수정했습니다.

## 개발 목적

일상생활에서 헷갈리기 쉬운 분리배출 방법을 더 쉽고 빠르게 확인할 수 있도록 돕기 위해 제작했습니다. 사진 인식과 직접 검색을 함께 제공하여 사용자가 상황에 맞는 방법으로 정보를 찾을 수 있도록 했으며, 지역 설정 기능을 통해 실제 생활에 더 가까운 분리배출 안내를 제공하고자 했습니다.

## 향후 개선 방향

- 공공데이터 API 연동을 통한 실제 지역별 배출일 자동 제공
- 품목별 분리배출 데이터베이스 확장
- AI 인식 정확도 개선
- 배출일 알림 기능 추가
- 사용자 검색 기록 기반 추천 기능 추가
