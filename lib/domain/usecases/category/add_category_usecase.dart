import 'package:uuid/uuid.dart';
import '../../entities/category_entity.dart';
import '../../repositories/category_repository.dart';

/// 카테고리 추가 UseCase
class AddCategoryUseCase {
  final CategoryRepository _repository;
  final Uuid _uuid = const Uuid();

  AddCategoryUseCase(this._repository);

  /// 카테고리 추가
  /// [name]: 카테고리 이름
  /// [colorHex]: 카테고리 색상 (Hex)
  /// [endTimeHour]: 완료 시간 (시)
  /// [endTimeMinute]: 완료 시간 (분)
  ///
  /// Throws [ArgumentError] if name is empty or duplicate
  Future<CategoryEntity> call({
    required String name,
    required String colorHex,
    int endTimeHour = 9,
    int endTimeMinute = 0,
  }) async {
    // 유효성 검사: 빈 이름
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError('카테고리 이름을 입력해주세요.');
    }

    // 유효성 검사: 중복 이름
    final exists = await _repository.existsByName(trimmedName);
    if (exists) {
      throw ArgumentError('이미 같은 이름의 카테고리가 있어요.');
    }

    // sortOrder 할당
    final sortOrder = await _repository.getNextSortOrder();

    // 엔티티 생성
    final category = CategoryEntity(
      id: _uuid.v4(),
      name: trimmedName,
      colorHex: colorHex,
      sortOrder: sortOrder,
      endTimeHour: endTimeHour,
      endTimeMinute: endTimeMinute,
      createdAt: DateTime.now(),
    );

    // 저장
    await _repository.addCategory(category);

    return category;
  }
}
