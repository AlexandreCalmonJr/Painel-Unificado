import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:painel_windowns/core/error/failures.dart';
import 'package:painel_windowns/domain/entities/module_entity.dart';
import 'package:painel_windowns/domain/repositories/i_totem_repository.dart';
import 'package:painel_windowns/domain/usecases/usecase.dart';

/// Parameters for updating a totem.
class UpdateTotemParams extends Equatable {
  final String totemId;
  final Map<String, dynamic> updates;

  const UpdateTotemParams({required this.totemId, required this.updates});

  @override
  List<Object?> get props => [totemId, updates];
}

/// Use case for updating a totem.
@lazySingleton
class UpdateTotemUseCase implements UseCase<ModuleEntity, UpdateTotemParams> {
  final ITotemRepository repository;

  UpdateTotemUseCase(this.repository);

  @override
  Future<Either<Failure, ModuleEntity>> call(UpdateTotemParams params) async {
    return await repository.updateTotem(params.totemId, params.updates);
  }
}
