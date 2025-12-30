# Task-Category 관계 재설계

## 현재 구조의 문제점

```
Task (1) ──── (N) Category
     └── categoryId: String?
```

- Task는 하나의 Category에만 속할 수 있음
- 같은 할일을 여러 카테고리에서 사용하려면 복제해야 함
- 할일 라이브러리 개념이 없음

---

## 새로운 구조

### 핵심 개념 변경

```
┌─────────────────────────────────────────────────────────────┐
│  TaskTemplate (할일 템플릿/라이브러리)                        │
│  - 사용자가 만든 모든 할일의 원본                              │
│  - 즐겨찾기, 태그 등 메타데이터 포함                           │
└─────────────────────────────────────────────────────────────┘
                              │
                              │ (1:N)
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  CategoryTask (카테고리-할일 연결)                            │
│  - 어떤 카테고리에 어떤 할일이 포함되어 있는지                   │
│  - 카테고리별 정렬 순서 관리                                   │
│  - 같은 TaskTemplate이 여러 Category에 존재 가능               │
└─────────────────────────────────────────────────────────────┘
                              │
                              │ (N:1)
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  Category (카테고리)                                         │
│  - 기존과 동일                                               │
└─────────────────────────────────────────────────────────────┘
```

---

## 엔티티 설계

### 1. TaskTemplate (새로 추가)

```dart
class TaskTemplateEntity {
  final String id;
  final String title;
  final int minutes;
  final bool isFavorite;      // 즐겨찾기
  final List<String> tags;    // 태그 (필터용)
  final DateTime createdAt;
  final DateTime? lastUsedAt; // 최근 사용일 (정렬용)
}
```

### 2. CategoryTask (새로 추가 - 연결 테이블)

```dart
class CategoryTaskEntity {
  final String id;
  final String categoryId;
  final String taskTemplateId;
  final int sortOrder;        // 카테고리 내 정렬 순서
  final DateTime addedAt;     // 카테고리에 추가된 시간
}
```

### 3. TaskTag (선택적 - 태그 관리)

```dart
class TaskTagEntity {
  final String id;
  final String name;
  final String colorHex;
  final int sortOrder;
}
```

---

## UI/UX 흐름

### 1. 할일 추가 바텀시트 (카테고리 화면에서)

```
┌─────────────────────────────────────────┐
│  [X]                    할일 추가        │
├─────────────────────────────────────────┤
│  🔍 검색...                              │
├─────────────────────────────────────────┤
│  ⭐ 즐겨찾기                             │
│  ┌─────────────────────────────────┐    │
│  │ ☆ 영어 단어 외우기      20분    │    │
│  │ ☆ 운동하기             30분    │    │
│  └─────────────────────────────────┘    │
├─────────────────────────────────────────┤
│  📋 전체 할일                            │
│  ┌─────────────────────────────────┐    │
│  │ ☐ 필기 정리            25분    │    │
│  │ ☐ 샤워                 10분    │    │
│  │ ☐ 독서                 40분    │    │
│  └─────────────────────────────────┘    │
├─────────────────────────────────────────┤
│  + 새 할일 만들기                        │
├─────────────────────────────────────────┤
│  [취소]              [추가 (2개 선택)]   │
└─────────────────────────────────────────┘
```

### 2. 할일 라이브러리 화면 (새로 추가)

- 설정 또는 별도 탭에서 접근
- 모든 TaskTemplate 관리
- 즐겨찾기/태그 편집
- 사용되지 않는 할일 정리

```
┌─────────────────────────────────────────┐
│  [←]                   할일 라이브러리   │
├─────────────────────────────────────────┤
│  [전체] [⭐즐겨찾기] [#공부] [#운동]     │
├─────────────────────────────────────────┤
│  ┌─────────────────────────────────┐    │
│  │ ⭐ 영어 단어 외우기     20분    │    │
│  │    #공부  사용: 3개 카테고리     │    │
│  ├─────────────────────────────────┤    │
│  │ ☆ 운동하기             30분    │    │
│  │    #운동  사용: 1개 카테고리     │    │
│  └─────────────────────────────────┘    │
├─────────────────────────────────────────┤
│              [+ 새 할일]                 │
└─────────────────────────────────────────┘
```

---

## 마이그레이션 전략

### Phase 1: 데이터 모델 추가
1. `TaskTemplateModel` 추가 (Hive typeId: 2)
2. `CategoryTaskModel` 추가 (Hive typeId: 3)
3. 기존 `TaskModel` 유지 (호환성)

### Phase 2: 마이그레이션 로직
```dart
// 앱 시작 시 마이그레이션 체크
if (needsMigration) {
  // 1. 기존 Task들을 TaskTemplate으로 변환
  for (task in existingTasks) {
    createTaskTemplate(task.title, task.minutes);
    createCategoryTask(task.categoryId, templateId, task.sortOrder);
  }
  // 2. 기존 Task 박스 정리
}
```

### Phase 3: UI 변경
1. TaskFormBottomSheet → TaskSelectorBottomSheet로 변경
2. 할일 라이브러리 화면 추가
3. 홈 화면 로직 수정

---

## 구현 순서

### Step 1: 엔티티 & 모델 (1일)
- [ ] TaskTemplateEntity, TaskTemplateModel
- [ ] CategoryTaskEntity, CategoryTaskModel
- [ ] TaskTagEntity, TaskTagModel (선택)

### Step 2: Repository & UseCase (1일)
- [ ] TaskTemplateRepository
- [ ] CategoryTaskRepository
- [ ] 관련 UseCase 추가

### Step 3: 마이그레이션 (0.5일)
- [ ] 마이그레이션 서비스 구현
- [ ] 앱 시작 시 마이그레이션 체크

### Step 4: UI 변경 (2일)
- [ ] TaskSelectorBottomSheet (기존 할일 선택 UI)
- [ ] TaskTemplateFormBottomSheet (새 할일 생성 UI)
- [ ] TaskLibraryPage (할일 라이브러리)
- [ ] HomeController 로직 수정

### Step 5: 테스트 & 버그 수정 (0.5일)

---

## 고려사항

### 1. 동일 할일의 시간이 다른 경우
- 옵션 A: TaskTemplate에 기본 시간, CategoryTask에서 오버라이드 가능
- 옵션 B: 시간이 다르면 별도 TaskTemplate으로 관리
- **추천: 옵션 B** (단순하고 명확함)

### 2. 할일 삭제 시
- TaskTemplate 삭제 → 모든 CategoryTask도 삭제 (cascade)
- CategoryTask만 삭제 → 해당 카테고리에서만 제거

### 3. 태그 vs 폴더
- 태그: 하나의 할일에 여러 태그 (유연함)
- 폴더: 계층 구조 (복잡함)
- **추천: 태그** (MVP에서는 태그만 구현)

---

## 결정 필요 사항

1. **태그 기능 MVP에 포함?**
   - Yes: 더 많은 작업량
   - No: 즐겨찾기만으로 시작

2. **할일 라이브러리 화면 위치?**
   - 옵션 A: 카테고리 관리 화면 내
   - 옵션 B: 별도 탭/화면
   - 옵션 C: 설정에서 접근

3. **CategoryTask에서 시간 오버라이드?**
   - Yes: 같은 할일이지만 카테고리마다 다른 시간
   - No: 시간이 다르면 별도 할일로 생성
