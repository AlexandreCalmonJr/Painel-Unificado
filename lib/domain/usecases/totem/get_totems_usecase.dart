import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:painel_windowns/core/error/failures.dart';
import 'package:painel_windowns/domain/entities/totem_entity.dart';
import 'package:painel_windowns/domain/repositories/i_totem_repository.dart';
import 'package:painel_windowns/domain/usecases/usecase.dart';

/// Use case for retrieving all totems.
///
/// This use case fetches all totems from the repository
/// and returns them as a list of [TotemEntity].
@lazySingleton
class GetTotemsUseCase implements UseCase<List<TotemEntity>, NoParams> {
  final ITotemRepository repository;

  GetTotemsUseCase(this.repository);

  @override
  Future<Either<Failure, List<TotemEntity>>> call(NoParams params) async {
    // TODO: Get token from auth service
    return await repository.getTotems('');
  }
}
