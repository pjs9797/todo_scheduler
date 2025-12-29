/// 시작 시간 계산 결과
class StartTimeResult {
  final int hour;
  final int minute;
  final bool isPreviousDay;

  const StartTimeResult({
    required this.hour,
    required this.minute,
    required this.isPreviousDay,
  });

  /// HH:mm 형식 문자열
  String get timeString {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

/// 시작 시간 계산 UseCase
class CalculateStartTimeUseCase {
  /// 시작 시간 계산
  /// [endHour]: 완료 시간 (시)
  /// [endMinute]: 완료 시간 (분)
  /// [totalMinutes]: 총 소요 시간 (분)
  ///
  /// Returns: 시작해야 할 시간 + 전날 여부
  StartTimeResult call({
    required int endHour,
    required int endMinute,
    required int totalMinutes,
  }) {
    // 완료 시간을 분 단위로 변환 (00:00 기준)
    final endTotalMinutes = endHour * 60 + endMinute;

    // 시작 시간 계산
    final startTotalMinutes = endTotalMinutes - totalMinutes;

    // 전날 여부 확인
    final isPreviousDay = startTotalMinutes < 0;

    // 정규화 (음수 처리)
    final normalized = ((startTotalMinutes % 1440) + 1440) % 1440;

    return StartTimeResult(
      hour: normalized ~/ 60,
      minute: normalized % 60,
      isPreviousDay: isPreviousDay,
    );
  }
}
