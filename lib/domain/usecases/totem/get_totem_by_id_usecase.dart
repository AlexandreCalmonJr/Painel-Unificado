import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:painel_windowns/core/error/failures.dart';
import 'package:painel_windowns/domain/entities/totem_entity.dart';
import 'package:painel_windowns/domain/repositories/i_totem_repository.dart';
import 'package:painel_windowns/domain/usecases/usecase.dart';

/// Parameters for getting a totem by ID.
class GetTotemByIdParams extends Equatable {

  const GetTotemByIdParams({required this.totemId});
  final String totemId;

  @override
  List<Object?> get props => [totemId];
}

/// Use case for retrieving a specific totem by ID.
@lazySingleton
class GetTotemByIdUseCase implements UseCase<TotemEntity, GetTotemByIdParams> {

  GetTotemByIdUseCase(this.repository);
  final ITotemRepository repository;

  @override
  Future<Either<Failure, TotemEntity>> call(GetTotemByIdParams params) async {
    // TODO: Get token from auth service
    return repository.getTotemById('', params.totemId);
  }
}
