import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:painel_windowns/core/error/failures.dart';
import 'package:painel_windowns/domain/entities/totem_entity.dart';
import 'package:painel_windowns/domain/repositories/i_totem_repository.dart';
import 'package:painel_windowns/domain/usecases/usecase.dart';
import 'package:painel_windowns/services/token_service.dart';

/// Use case for retrieving all totems.
///
/// This use case fetches all totems from the repository
/// and returns them as a list of [TotemEntity].
@lazySingleton
class GetTotemsUseCase implements UseCase<List<TotemEntity>, NoParams> {
  final ITotemRepository repository;
  final TokenService tokenService;

  GetTotemsUseCase(this.repository, this.tokenService);

  @override
  Future<Either<Failure, List<TotemEntity>>> call(NoParams params) async {
    final token = tokenService.getToken();

    if (token == null) {
      return Left(UnauthorizedFailure());
    }

    return await repository.getTotems(token);
  }
}
