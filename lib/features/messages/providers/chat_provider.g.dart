// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$typingUsersHash() => r'bf7c12cc3bde675a3f746e364e07f01d992e2bf1';

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

/// See also [typingUsers].
@ProviderFor(typingUsers)
const typingUsersProvider = TypingUsersFamily();

/// See also [typingUsers].
class TypingUsersFamily extends Family<AsyncValue<dynamic>> {
  /// See also [typingUsers].
  const TypingUsersFamily();

  /// See also [typingUsers].
  TypingUsersProvider call(
    String conversationId,
  ) {
    return TypingUsersProvider(
      conversationId,
    );
  }

  @override
  TypingUsersProvider getProviderOverride(
    covariant TypingUsersProvider provider,
  ) {
    return call(
      provider.conversationId,
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
  String? get name => r'typingUsersProvider';
}

/// See also [typingUsers].
class TypingUsersProvider extends AutoDisposeStreamProvider<dynamic> {
  /// See also [typingUsers].
  TypingUsersProvider(
    String conversationId,
  ) : this._internal(
          (ref) => typingUsers(
            ref as TypingUsersRef,
            conversationId,
          ),
          from: typingUsersProvider,
          name: r'typingUsersProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$typingUsersHash,
          dependencies: TypingUsersFamily._dependencies,
          allTransitiveDependencies:
              TypingUsersFamily._allTransitiveDependencies,
          conversationId: conversationId,
        );

  TypingUsersProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.conversationId,
  }) : super.internal();

  final String conversationId;

  @override
  Override overrideWith(
    Stream<dynamic> Function(TypingUsersRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TypingUsersProvider._internal(
        (ref) => create(ref as TypingUsersRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        conversationId: conversationId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<dynamic> createElement() {
    return _TypingUsersProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TypingUsersProvider &&
        other.conversationId == conversationId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, conversationId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TypingUsersRef on AutoDisposeStreamProviderRef<dynamic> {
  /// The parameter `conversationId` of this provider.
  String get conversationId;
}

class _TypingUsersProviderElement
    extends AutoDisposeStreamProviderElement<dynamic> with TypingUsersRef {
  _TypingUsersProviderElement(super.provider);

  @override
  String get conversationId => (origin as TypingUsersProvider).conversationId;
}

String _$unreadCountHash() => r'127d6230e769354da01fd796adf8f596a5894f29';

/// See also [unreadCount].
@ProviderFor(unreadCount)
final unreadCountProvider = AutoDisposeFutureProvider<dynamic>.internal(
  unreadCount,
  name: r'unreadCountProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$unreadCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UnreadCountRef = AutoDisposeFutureProviderRef<dynamic>;
String _$conversationsNotifierHash() =>
    r'c51f6e59908f03e3c28c8723536029251c2e5a9b';

/// See also [ConversationsNotifier].
@ProviderFor(ConversationsNotifier)
final conversationsNotifierProvider = AutoDisposeAsyncNotifierProvider<
    ConversationsNotifier, List<dynamic>>.internal(
  ConversationsNotifier.new,
  name: r'conversationsNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$conversationsNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ConversationsNotifier = AutoDisposeAsyncNotifier<List<dynamic>>;
String _$messagesNotifierHash() => r'ada65c963b8cba876ad07fff1fce3b3cb3338482';

abstract class _$MessagesNotifier
    extends BuildlessAutoDisposeStreamNotifier<dynamic> {
  late final String conversationId;

  Stream<dynamic> build(
    String conversationId,
  );
}

/// See also [MessagesNotifier].
@ProviderFor(MessagesNotifier)
const messagesNotifierProvider = MessagesNotifierFamily();

/// See also [MessagesNotifier].
class MessagesNotifierFamily extends Family<AsyncValue<dynamic>> {
  /// See also [MessagesNotifier].
  const MessagesNotifierFamily();

  /// See also [MessagesNotifier].
  MessagesNotifierProvider call(
    String conversationId,
  ) {
    return MessagesNotifierProvider(
      conversationId,
    );
  }

  @override
  MessagesNotifierProvider getProviderOverride(
    covariant MessagesNotifierProvider provider,
  ) {
    return call(
      provider.conversationId,
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
  String? get name => r'messagesNotifierProvider';
}

/// See also [MessagesNotifier].
class MessagesNotifierProvider
    extends AutoDisposeStreamNotifierProviderImpl<MessagesNotifier, dynamic> {
  /// See also [MessagesNotifier].
  MessagesNotifierProvider(
    String conversationId,
  ) : this._internal(
          () => MessagesNotifier()..conversationId = conversationId,
          from: messagesNotifierProvider,
          name: r'messagesNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$messagesNotifierHash,
          dependencies: MessagesNotifierFamily._dependencies,
          allTransitiveDependencies:
              MessagesNotifierFamily._allTransitiveDependencies,
          conversationId: conversationId,
        );

  MessagesNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.conversationId,
  }) : super.internal();

  final String conversationId;

  @override
  Stream<dynamic> runNotifierBuild(
    covariant MessagesNotifier notifier,
  ) {
    return notifier.build(
      conversationId,
    );
  }

  @override
  Override overrideWith(MessagesNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: MessagesNotifierProvider._internal(
        () => create()..conversationId = conversationId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        conversationId: conversationId,
      ),
    );
  }

  @override
  AutoDisposeStreamNotifierProviderElement<MessagesNotifier, dynamic>
      createElement() {
    return _MessagesNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MessagesNotifierProvider &&
        other.conversationId == conversationId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, conversationId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MessagesNotifierRef on AutoDisposeStreamNotifierProviderRef<dynamic> {
  /// The parameter `conversationId` of this provider.
  String get conversationId;
}

class _MessagesNotifierProviderElement
    extends AutoDisposeStreamNotifierProviderElement<MessagesNotifier, dynamic>
    with MessagesNotifierRef {
  _MessagesNotifierProviderElement(super.provider);

  @override
  String get conversationId =>
      (origin as MessagesNotifierProvider).conversationId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
