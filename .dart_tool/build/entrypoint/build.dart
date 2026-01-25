// @dart=3.6
// ignore_for_file: directives_ordering
// build_runner >=2.4.16
// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:build_runner_core/build_runner_core.dart' as _i1;
import 'package:freezed/builder.dart' as _i2;
import 'package:json_serializable/builder.dart' as _i3;
import 'package:source_gen/builder.dart' as _i4;
import 'package:mockito/src/builder.dart' as _i5;
import 'package:build_config/build_config.dart' as _i6;
import 'package:injectable_generator/builder.dart' as _i7;
import 'dart:isolate' as _i8;
import 'package:build_runner/src/build_script_generate/build_process_state.dart'
    as _i9;
import 'package:build_runner/build_runner.dart' as _i10;
import 'dart:io' as _i11;

final _builders = <_i1.BuilderApplication>[
  _i1.apply(
    r'freezed:freezed',
    [_i2.freezed],
    _i1.toDependentsOf(r'freezed'),
    hideOutput: false,
  ),
  _i1.apply(
    r'json_serializable:json_serializable',
    [_i3.jsonSerializable],
    _i1.toDependentsOf(r'json_serializable'),
    hideOutput: true,
    appliesBuilders: const [r'source_gen:combining_builder'],
  ),
  _i1.apply(
    r'source_gen:combining_builder',
    [_i4.combiningBuilder],
    _i1.toNoneByDefault(),
    hideOutput: false,
    appliesBuilders: const [r'source_gen:part_cleanup'],
  ),
  _i1.apply(
    r'mockito:mockBuilder',
    [_i5.buildMocks],
    _i1.toDependentsOf(r'mockito'),
    hideOutput: false,
    defaultGenerateFor: const _i6.InputSet(include: [r'test/**']),
  ),
  _i1.apply(
    r'injectable_generator:injectable_builder',
    [_i7.injectableBuilder],
    _i1.toDependentsOf(r'injectable_generator'),
    hideOutput: true,
  ),
  _i1.apply(
    r'injectable_generator:injectable_config_builder',
    [_i7.injectableConfigBuilder],
    _i1.toDependentsOf(r'injectable_generator'),
    hideOutput: false,
  ),
  _i1.applyPostProcess(
    r'source_gen:part_cleanup',
    _i4.partCleanup,
  ),
];
void main(
  List<String> args, [
  _i8.SendPort? sendPort,
]) async {
  await _i9.buildProcessState.receive(sendPort);
  _i9.buildProcessState.isolateExitCode = await _i10.run(
    args,
    _builders,
  );
  _i11.exitCode = _i9.buildProcessState.isolateExitCode!;
  await _i9.buildProcessState.send(sendPort);
}
