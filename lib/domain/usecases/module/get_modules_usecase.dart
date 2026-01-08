import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:painel_windowns/core/error/failures.dart';
import 'package:painel_windowns/domain/repositories/i_module_repository.dart';
import 'package:painel_windowns/domain/usecases/usecase.dart';
import 'package:painel_windowns/data/models/asset_module_base_model.dart';

/// Use case for retrieving all modules.
@lazySingleton
class GetModulesUseCase implements UseCase<List<AssetModuleConfig>, NoParams> {
  final IModuleRepository repository;

  GetModulesUseCase(this.repository);

  @override
  Future<Either<Failure, List<AssetModuleConfig>>> call(NoParams params) async {
    return await repository.getModules();
  }
}
