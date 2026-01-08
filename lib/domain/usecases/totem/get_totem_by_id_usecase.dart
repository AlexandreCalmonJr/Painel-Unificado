import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:painel_windowns/core/error/failures.dart';
import 'package:painel_windowns/domain/entities/totem_entity.dart';
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
class GetTotemByIdUseCase implements UseCase<TotemEntity, GetTotemByIdParams> {
  final ITotemRepository repository;

  GetTotemByIdUseCase(this.repository);

  @override
  Future<Either<Failure, TotemEntity>> call(GetTotemByIdParams params) async {
    // TODO: Get token from auth service
    return await repository.getTotemById('', params.totemId);
  }
}
