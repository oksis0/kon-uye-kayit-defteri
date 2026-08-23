// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'worker_istemcisi.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(workerIstemcisi)
const workerIstemcisiProvider = WorkerIstemcisiProvider._();

final class WorkerIstemcisiProvider
    extends
        $FunctionalProvider<WorkerIstemcisi, WorkerIstemcisi, WorkerIstemcisi>
    with $Provider<WorkerIstemcisi> {
  const WorkerIstemcisiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'workerIstemcisiProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$workerIstemcisiHash();

  @$internal
  @override
  $ProviderElement<WorkerIstemcisi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  WorkerIstemcisi create(Ref ref) {
    return workerIstemcisi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WorkerIstemcisi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WorkerIstemcisi>(value),
    );
  }
}

String _$workerIstemcisiHash() => r'3b7c6b83a582ddf8361cfd0132b6f8ef2d762664';
