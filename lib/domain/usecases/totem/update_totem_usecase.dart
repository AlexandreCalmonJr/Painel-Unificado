import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:painel_windowns/core/error/failures.dart';
import 'package:painel_windowns/domain/entities/totem_entity.dart';
import 'package:painel_windowns/domain/repositories/i_totem_repository.dart';
import 'package:painel_windowns/domain/usecases/usecase.dart';

/// Parameters for updating a totem.
class UpdateTotemParams extends Equatable {

  const UpdateTotemParams({required this.totem});
  final TotemEntity totem;

  @override
  List<Object?> get props => [totem];
}

/// Use case for updating a totem.
@lazySingleton
class UpdateTotemUseCase implements UseCase<Unit, UpdateTotemParams> {

  UpdateTotemUseCase(this.repository);
  final ITotemRepository repository;

  @override
  Future<Either<Failure, Unit>> call(UpdateTotemParams params) async {
    // TODO: Get token from auth service
    return repository.updateTotem('', params.totem);
  }
}
