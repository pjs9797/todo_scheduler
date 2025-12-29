# Claude Instructions (Flutter App) — GetX + Clean Architecture + Drag Reorder

## 0) 프로젝트 개요
이 앱은 "해야 할 일(소요 시간: 분)"을 **카테고리로 분류**해 저장하고,
사용자가 "끝나는 시간"을 선택하면
`끝나는 시간 - (선택된 항목들의 총 소요 시간)` 으로 **시작해야 하는 시간**을 계산해준다.

필수 요구:
- 상태관리: **GetX**
- 아키텍처: **Clean Architecture 적용**
- 데이터 영속성: **로컬 DB**
- UI: **Material 3 기반으로 예쁘고 깔끔하게**
- **카테고리/항목 드래그로 순서 변경 가능**(순서 DB에 저장)
- 텍스트/네이밍: 사용자에게 자연스럽고 적절한 문구 사용

---

## 1) 용어/네이밍 가이드 (중요)
### 1.1 화면/기능 네이밍 원칙
- "항목" 대신 UI에서는 **"할 일"** 또는 **"작업"** 사용
- "카테고리"는 **"카테고리"** 그대로 사용
- "끝나는 시간"은 **"완료 시간"** 또는 **"끝낼 시간"** 중 하나로 통일 (권장: **완료 시간**)
- "시작 시간"은 **"시작해야 할 시간"** 으로 표기
- 버튼/라벨은 짧고 명확하게:
  - 추가: "할 일 추가", "카테고리 추가"
  - 저장: "저장"
  - 수정: "수정"
  - 삭제: "삭제"
  - 계산: "시작 시간 계산"
  - 시간 선택: "완료 시간 선택"
  - 필터: "전체", "미분류"

### 1.2 Empty State 문구 (예시)
- 할 일 없음: "아직 할 일이 없어요. '할 일 추가'로 시작해보세요."
- 카테고리 없음: "카테고리를 추가하면 정리가 쉬워져요."
- 완료 시간 미선택: "완료 시간을 선택하면 시작해야 할 시간을 계산해드려요."

※ 위 문구는 앱 전반 텍스트 톤을 결정하므로, 전체 UI에서 일관되게 유지.

---

## 2) 기능 요구사항 (필수)

### 2.1 카테고리 관리 (CRUD + Drag Reorder)
- 카테고리 생성
  - 입력: 이름(String), (선택) 컬러/아이콘
  - 유효성: 빈값/공백 불가, 중복 이름 불가(기본)
- 카테고리 목록
  - 표시: 카테고리명, 포함된 할 일 개수
  - **드래그로 순서 변경 가능**
  - 순서 변경 시 즉시 로컬 DB에 `sortOrder` 저장
- 카테고리 수정
  - 이름/컬러/아이콘 수정 가능
- 카테고리 삭제
  - 삭제 확인
  - 삭제 정책(필수): **삭제된 카테고리에 속한 할 일은 유지** + `categoryId = null(미분류)` 로 이동

### 2.2 할 일 관리 (CRUD + Drag Reorder)
- 할 일 생성
  - 입력: 할 일 이름(String), 소요 시간(Int minutes), 카테고리 선택(선택)
  - 유효성: minutes >= 1
- 할 일 목록
  - 카드/리스트 형태
  - 표시: 제목, "n분", 카테고리 배지(미분류 포함)
  - 상단에 "총 소요 시간" 표시 (필터 기준)
- 할 일 수정
  - 제목/소요 시간/카테고리 변경 가능
- 할 일 삭제
  - 삭제 확인 + Undo(스낵바) 또는 다이얼로그 중 택1
- **드래그로 할 일 순서 변경**
  - 정렬 기준:
    - 기본: 현재 선택된 필터(전체/카테고리/미분류) 범위에서 드래그 가능
  - DB 저장:
    - `sortOrder`를 유지하도록 재계산 후 저장
  - (권장 정책) "전체" 필터에서의 순서는 전역 순서, "카테고리 필터"에서는 해당 카테고리 내부 순서로 동작하도록 설계

### 2.3 필터링
- 카테고리 필터 칩/탭 제공:
  - "전체 / 미분류 / 카테고리들…"
- 필터 적용 시:
  - 목록이 바뀌고
  - "총 소요 시간"도 필터 기준으로 합산

### 2.4 시작 시간 계산
- 사용자는 "완료 시간"을 선택한다 (TimePicker).
- 계산 버튼: "시작 시간 계산"
- 계산식:
  - `startTime = endTime - totalMinutes`
  - totalMinutes = 현재 필터에 해당하는 할 일들의 minutes 합
- 결과 표시:
  - "시작해야 할 시간: HH:mm"
- 날짜 규칙:
  - 같은 날 기준
  - 전날로 넘어가면 "전날" 배지 표시 (예: "전날 23:40")
  - 이번 버전은 날짜 선택 기능 제외(시간만)

---

## 3) 비기능 요구사항 (품질/UX)
- Material 3 사용, 여백 충분히, 카드/칩/타이포 정돈
- 주요 화면 권장 구성:
  1) 헤더 + 총 소요 시간(필터 기준)
  2) 카테고리 필터 칩 + "카테고리 관리"
  3) 완료 시간 카드 + 결과(시작해야 할 시간) 카드
  4) 할 일 리스트 (드래그 핸들 아이콘 포함)
  5) FAB: "할 일 추가"
- 드래그 UX:
  - 항목 우측에 드래그 핸들(≡) 아이콘을 보여 "드래그 가능"을 명확히
  - Reorder 시 햅틱(가능하면) + 부드러운 애니메이션

---

## 4) Clean Architecture 적용 지침 (필수)
### 4.1 레이어 구조
- **Presentation**
  - UI(Widget) + GetX Controller(또는 ViewModel 역할)
  - 화면 상태(Rx) 관리, UseCase 호출
- **Domain**
  - Entities (CategoryEntity, TaskEntity 등)
  - UseCases (AddTask, UpdateTask, DeleteTask, ReorderTasks, CalculateStartTime 등)
  - Repository Interfaces (TaskRepository, CategoryRepository)
  - 순수 Dart 로직(Flutter/GetX/DB 의존 X)
- **Data**
  - Local DataSource (Isar/Hive/Drift 중 택1)
  - Repository Impl (TaskRepositoryImpl, CategoryRepositoryImpl)
  - Models/Adapters/Mapper (DTO ↔ Entity 변환)

### 4.2 의존성 규칙
- Presentation → Domain만 의존
- Data → Domain(인터페이스) 구현
- Domain은 어떤 프레임워크에도 의존하지 않음

### 4.3 GetX 사용 원칙
- Controller는 "UseCase 조립 + 상태 갱신"만 담당
- 계산/검증 로직은 Domain UseCase로 이동
- 라우팅/DI는 GetX로 하되, Domain 계층에는 GetX 타입이 들어가지 않게 유지

---

## 5) 데이터 모델 (초안)

### CategoryEntity
- id: String(uuid) 또는 int
- name: String
- colorHex: String?
- iconCodePoint: int?
- sortOrder: int
- createdAt: DateTime

### TaskEntity (할 일)
- id: String(uuid) 또는 int
- title: String
- minutes: int
- categoryId: (nullable) CategoryEntity.id
- sortOrder: int
- createdAt: DateTime

정책:
- categoryId == null → "미분류"
- sortOrder는 화면 표시/드래그 정렬 기준이며 DB에 영구 저장

---

## 6) 드래그 정렬 구현 요구사항 (중요)
### 6.1 카테고리 Reorder
- UI: `ReorderableListView` 또는 reorderable 패키지 사용 가능
- reorder 결과:
  - 로컬 리스트 갱신
  - `sortOrder` 재할당 (0..n-1)
  - DB에 일괄 업데이트
- UseCase: `ReorderCategoriesUseCase(List<CategoryEntity> reordered)`

### 6.2 할 일 Reorder
- 기본 동작:
  - 현재 필터 범위에서 reorder 가능
  - reorder 후 해당 범위의 `sortOrder` 재할당 + DB 반영
- UseCase:
  - `ReorderTasksUseCase({required Filter filter, required List<TaskEntity> reordered})`
- Filter 타입:
  - All / Unassigned / Category(categoryId)

---

## 7) 화면 구성 (MVP)

### 7.1 HomeScreen
- 카테고리 필터 칩
- "카테고리 관리" 버튼
- 완료 시간 선택 카드 ("완료 시간 선택")
- "시작 시간 계산" 버튼
- 결과 카드 ("시작해야 할 시간")
- 할 일 목록(드래그 핸들, 편집/삭제)
- FAB: "할 일 추가"

### 7.2 Task Add/Edit (BottomSheet 권장)
- 제목 입력
- 소요 시간 입력(숫자 키보드)
- 카테고리 선택(드롭다운/칩)
- 저장

### 7.3 Category Management Screen
- 카테고리 리스트(드래그 정렬)
- 추가/수정/삭제

---

## 8) 구현 단계 (클로드 작업 순서)
1) 프로젝트 셋업: Material 3 + GetMaterialApp + 라우팅 + 기본 테마/타이포
2) Clean Architecture 폴더 구조 생성 + DI(GetX bindings)
3) Data: 로컬 DB 연동 + 모델/어댑터/CRUD
4) Domain: Entities/Repo Interface/UseCases(할 일/카테고리 CRUD + Reorder + 계산)
5) Presentation: Home 화면 + 상태 연결 + CRUD UI
6) 카테고리 관리 화면 + 드래그 정렬
7) 할 일 드래그 정렬 + 필터 기준 sortOrder 정책 적용
8) UX polish(텍스트/empty state/spacing/애니메이션)
9) 최소 테스트:
   - CalculateStartTimeUseCase
   - ReorderUseCase(정렬 결과/ sortOrder 재계산)

---

## 9) 범위 제외 (이번 버전)
- 서버 동기화/로그인
- 알림(로컬/푸시)
- 날짜 선택(시간만)
- 다중 플랜 세트 관리

---

## 10) 완료 기준 (Definition of Done)
- 카테고리/할 일 CRUD 정상 동작 + 로컬 DB 영구 저장
- 카테고리/할 일 **드래그로 순서 변경** 가능 + sortOrder DB 반영
- 필터(전체/미분류/카테고리) 정상 동작 + 합계/계산도 필터 기준
- 완료 시간 → 시작해야 할 시간 계산 정확 + 전날 표시 명확
- Clean Architecture 의존성 규칙 준수
- 사용자에게 자연스러운 텍스트 네이밍/톤으로 UI 완성
