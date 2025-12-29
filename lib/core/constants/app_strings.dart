/// 앱 전역 문자열 상수
class AppStrings {
  AppStrings._();

  // 앱 정보
  static const String appTitle = '오늘의 작업';
  static const String appSubtitle = '완료 시간을 기준으로 시작 시간을 계산해요';

  // 필터
  static const String filterAll = '전체';
  static const String filterUnassigned = '미분류';

  // 카테고리
  static const String categoryManage = '카테고리 관리';
  static const String categoryAdd = '카테고리 추가';
  static const String categoryEdit = '카테고리 수정';
  static const String categoryName = '카테고리 이름';
  static const String categoryColor = '색상';
  static const String categoryEmpty = '카테고리를 추가하면 정리가 쉬워져요.';
  static const String categoryDeleteConfirm = '카테고리를 삭제할까요?\n(카테고리에 있던 할 일은 "미분류"로 이동해요.)';

  // 할 일
  static const String taskAdd = '할 일 추가';
  static const String taskEdit = '할 일 수정';
  static const String taskName = '할 일 이름';
  static const String taskNameHint = '예: 영어 단어 외우기';
  static const String taskDuration = '소요 시간(분)';
  static const String taskDurationHint = '예: 20';
  static const String taskDurationHelper = '1분 이상 입력해주세요.';
  static const String taskCategory = '카테고리';
  static const String taskEmpty = '아직 할 일이 없어요. \'할 일 추가\'로 시작해보세요.';
  static const String taskDeleteConfirm = '을(를) 삭제할까요?';

  // 시간
  static const String endTime = '완료 시간';
  static const String endTimeHint = '끝낼 시간을 선택하세요';
  static const String startTime = '시작해야 할 시간';
  static const String startTimeFormula = '완료 시간 - 총 소요 시간';
  static const String calculateStartTime = '시작 시간 계산';
  static const String totalDuration = '총 소요 시간';
  static const String previousDay = '전날';
  static const String selectEndTimeFirst = '완료 시간을 선택하면 시작해야 할 시간을 계산해드려요.';

  // 버튼
  static const String save = '저장';
  static const String cancel = '취소';
  static const String delete = '삭제';
  static const String edit = '수정';
  static const String add = '추가';
  static const String reset = '초기화';

  // 토스트 메시지
  static const String categorySaved = '카테고리를 저장했어요.';
  static const String categoryDeleted = '카테고리를 삭제했어요.';
  static const String taskSaved = '할 일을 저장했어요.';
  static const String taskDeleted = '할 일을 삭제했어요.';
  static const String startTimeCalculated = '시작 시간을 계산했어요.';

  // 에러 메시지
  static const String errorCategoryNameEmpty = '카테고리 이름을 입력해주세요.';
  static const String errorCategoryNameDuplicate = '이미 같은 이름의 카테고리가 있어요.';
  static const String errorTaskNameEmpty = '할 일 이름을 입력해주세요.';
  static const String errorTaskDurationInvalid = '소요 시간은 1분 이상 숫자로 입력해주세요.';
  static const String errorEndTimeNotSelected = '완료 시간을 먼저 선택해주세요.';
}
