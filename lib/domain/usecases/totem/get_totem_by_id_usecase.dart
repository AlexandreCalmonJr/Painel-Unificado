import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:painel_windowns/core/error/failures.dart';
import 'package:painel_windowns/domain/entities/module_entity.dart';
import 'package:painel_windowns/domain/repositories/i_totem_repository.dart';
import 'package:painel_windowns/domain/usecases/usecase.dart';

/// Parameters for getting a totem by ID.
class GetTotemByIdParams extends Equatable {
  final String totemId;

  const GetTotemByIdParams({required this.totemId});

  @override
  List<Object?> get props => [totemId];
}

/// Use case for retrieving a specific totem by ID.
@lazySingleton
class GetTotemByIdUseCase implements UseCase<ModuleEntity, GetTotemByIdParams> {
  final ITotemRepository repository;

  GetTotemByIdUseCase(this.repository);

  @override
  Future<Either<Failure, ModuleEntity>> call(GetTotemByIdParams params) async {
    return await repository.getTotemById(params.totemId);
  }
}
