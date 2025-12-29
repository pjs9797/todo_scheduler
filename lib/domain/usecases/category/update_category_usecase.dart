import '../../entities/category_entity.dart';
import '../../repositories/category_repository.dart';

/// 카테고리 수정 UseCase
class UpdateCategoryUseCase {
  final CategoryRepository _repository;

  UpdateCategoryUseCase(this._repository);

  /// 카테고리 수정
  /// [category]: 수정할 카테고리 (id로 식별)
  /// [name]: 새 이름 (optional)
  /// [colorHex]: 새 색상 (optional)
  /// [endTimeHour]: 새 완료 시간 - 시 (optional)
  /// [endTimeMinute]: 새 완료 시간 - 분 (optional)
  ///
  /// Throws [ArgumentError] if name is empty or duplicate
  Future<CategoryEntity> call({
    required CategoryEntity category,
    String? name,
    String? colorHex,
    int? endTimeHour,
    int? endTimeMinute,
  }) async {
    final newName = name?.trim() ?? category.name;
    final newColorHex = colorHex ?? category.colorHex;
    final newEndTimeHour = endTimeHour ?? category.endTimeHour;
    final newEndTimeMinute = endTimeMinute ?? category.endTimeMinute;

    // 유효성 검사: 빈 이름
    if (newName.isEmpty) {
      throw ArgumentError('카테고리 이름을 입력해주세요.');
    }

    // 유효성 검사: 중복 이름 (자기 자신 제외)
    if (newName != category.name) {
      final exists = await _repository.existsByName(newName, excludeId: category.id);
      if (exists) {
        throw ArgumentError('이미 같은 이름의 카테고리가 있어요.');
      }
    }

    // 수정된 엔티티 생성
    final updated = category.copyWith(
      name: newName,
      colorHex: newColorHex,
      endTimeHour: newEndTimeHour,
      endTimeMinute: newEndTimeMinute,
    );

    // 저장
    await _repository.updateCategory(updated);

    return updated;
  }
}
