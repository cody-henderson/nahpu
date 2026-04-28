// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$databaseHash() => r'ed9c95103fdf22252e8cb2792060c8b12714ce12';

/// See also [database].
@ProviderFor(database)
final databaseProvider = Provider<Database>.internal(
  database,
  name: r'databaseProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$databaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DatabaseRef = ProviderRef<Database>;
String _$databaseFromPathHash() => r'2ce0936c50a07399d0b3fd0404b04024f03f872c';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [databaseFromPath].
@ProviderFor(databaseFromPath)
const databaseFromPathProvider = DatabaseFromPathFamily();

/// See also [databaseFromPath].
class DatabaseFromPathFamily extends Family<Database> {
  /// See also [databaseFromPath].
  const DatabaseFromPathFamily();

  /// See also [databaseFromPath].
  DatabaseFromPathProvider call({
    required File dbFile,
  }) {
    return DatabaseFromPathProvider(
      dbFile: dbFile,
    );
  }

  @override
  DatabaseFromPathProvider getProviderOverride(
    covariant DatabaseFromPathProvider provider,
  ) {
    return call(
      dbFile: provider.dbFile,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'databaseFromPathProvider';
}

/// See also [databaseFromPath].
class DatabaseFromPathProvider extends Provider<Database> {
  /// See also [databaseFromPath].
  DatabaseFromPathProvider({
    required File dbFile,
  }) : this._internal(
          (ref) => databaseFromPath(
            ref as DatabaseFromPathRef,
            dbFile: dbFile,
          ),
          from: databaseFromPathProvider,
          name: r'databaseFromPathProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$databaseFromPathHash,
          dependencies: DatabaseFromPathFamily._dependencies,
          allTransitiveDependencies:
              DatabaseFromPathFamily._allTransitiveDependencies,
          dbFile: dbFile,
        );

  DatabaseFromPathProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.dbFile,
  }) : super.internal();

  final File dbFile;

  @override
  Override overrideWith(
    Database Function(DatabaseFromPathRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DatabaseFromPathProvider._internal(
        (ref) => create(ref as DatabaseFromPathRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        dbFile: dbFile,
      ),
    );
  }

  @override
  ProviderElement<Database> createElement() {
    return _DatabaseFromPathProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DatabaseFromPathProvider && other.dbFile == dbFile;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, dbFile.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DatabaseFromPathRef on ProviderRef<Database> {
  /// The parameter `dbFile` of this provider.
  File get dbFile;
}

class _DatabaseFromPathProviderElement extends ProviderElement<Database>
    with DatabaseFromPathRef {
  _DatabaseFromPathProviderElement(super.provider);

  @override
  File get dbFile => (origin as DatabaseFromPathProvider).dbFile;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
