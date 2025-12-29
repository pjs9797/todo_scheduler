/// 시간 관련 유틸리티 함수
class TimeUtils {
  TimeUtils._();

  /// TimeOfDay를 분 단위로 변환 (00:00 기준)
  static int timeOfDayToMinutes(int hour, int minute) {
    return hour * 60 + minute;
  }

  /// 분을 시:분 형식 문자열로 변환
  static String minutesToTimeString(int totalMinutes) {
    // 음수 처리 (전날로 넘어가는 경우)
    final normalized = ((totalMinutes % 1440) + 1440) % 1440;
    final hours = (normalized ~/ 60).toString().padLeft(2, '0');
    final minutes = (normalized % 60).toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  /// 분을 읽기 좋은 형식으로 변환 (예: 90분 -> "1시간 30분")
  static String minutesToReadable(int minutes) {
    if (minutes < 60) {
      return '$minutes분';
    }
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (mins == 0) {
      return '$hours시간';
    }
    return '$hours시간 $mins분';
  }

  /// 시작 시간이 전날인지 확인
  static bool isPreviousDay(int startMinutes) {
    return startMinutes < 0;
  }
}
