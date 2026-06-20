import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationPreferenceService {
  static const String _regionKey = 'selected_region_name';
  static const String _generalWasteDaysKey = 'general_waste_days';
  static const String _recyclingDaysKey = 'recycling_days';
  static const String _foodWasteDaysKey = 'food_waste_days';

  Future<WasteSchedulePreference> loadWasteSchedule() async {
    final prefs = await SharedPreferences.getInstance();
    return WasteSchedulePreference(
      generalWasteDays:
          prefs.getString(_generalWasteDaysKey) ??
          WasteSchedulePreference.defaultSchedule.generalWasteDays,
      recyclingDays:
          prefs.getString(_recyclingDaysKey) ??
          WasteSchedulePreference.defaultSchedule.recyclingDays,
      foodWasteDays:
          prefs.getString(_foodWasteDaysKey) ??
          WasteSchedulePreference.defaultSchedule.foodWasteDays,
    );
  }

  Future<String?> loadRegionName() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_regionKey)?.trim();
    if (value == null || value.isEmpty) {
      return null;
    }
    return value;
  }

  Future<void> saveRegionName(String regionName) async {
    final trimmed = regionName.trim();
    if (trimmed.isEmpty) {
      throw Exception('지역명을 입력해 주세요.');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_regionKey, trimmed);
  }

  Future<void> saveWasteSchedule(WasteSchedulePreference schedule) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_generalWasteDaysKey, schedule.generalWasteDays);
    await prefs.setString(_recyclingDaysKey, schedule.recyclingDays);
    await prefs.setString(_foodWasteDaysKey, schedule.foodWasteDays);
  }

  Future<String> detectAndSaveCurrentRegion() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('휴대폰 위치 서비스가 꺼져 있어요.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception('위치 권한이 필요해요.');
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('설정에서 위치 권한을 허용해 주세요.');
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.low,
        timeLimit: Duration(seconds: 10),
      ),
    );

    final placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    final regionName = _formatRegionName(placemarks);
    await saveRegionName(regionName);
    return regionName;
  }

  String _formatRegionName(List<Placemark> placemarks) {
    if (placemarks.isEmpty) {
      throw Exception('현재 위치의 주소를 찾지 못했어요.');
    }

    final place = placemarks.first;
    final parts = [place.administrativeArea, place.locality, place.subLocality]
        .whereType<String>()
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toSet()
        .toList();

    if (parts.isEmpty) {
      throw Exception('현재 위치의 지역명을 찾지 못했어요.');
    }

    return parts.join(' ');
  }
}

class WasteSchedulePreference {
  final String generalWasteDays;
  final String recyclingDays;
  final String foodWasteDays;

  const WasteSchedulePreference({
    required this.generalWasteDays,
    required this.recyclingDays,
    required this.foodWasteDays,
  });

  static const WasteSchedulePreference defaultSchedule =
      WasteSchedulePreference(
        generalWasteDays: '월 / 수 / 금',
        recyclingDays: '화 / 목',
        foodWasteDays: '매일',
      );

  String toPromptText() {
    return '설정된 배출일: 일반쓰레기 $generalWasteDays, 재활용 $recyclingDays, 음식물 $foodWasteDays.';
  }
}
