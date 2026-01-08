import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:painel_windowns/core/error/failures.dart';
import 'package:painel_windowns/domain/entities/module_entity.dart';
import 'package:painel_windowns/domain/repositories/i_totem_repository.dart';
import 'package:painel_windowns/domain/usecases/usecase.dart';

/// Use case for retrieving all totems.
///
/// This use case fetches all totems from the repository
/// and returns them as a list of [ModuleEntity].
@lazySingleton
class GetTotemsUseCase implements UseCase<List<ModuleEntity>, NoParams> {
  final ITotemRepository repository;

  GetTotemsUseCase(this.repository);

  @override
  Future<Either<Failure, List<ModuleEntity>>> call(NoParams params) async {
    return await repository.getTotems();
  }
}
