import 'package:nyxx/src/core/guild/guild.dart';
import 'package:nyxx/src/core/guild/role.dart';
import 'package:nyxx/src/core/snowflake.dart';
import 'package:nyxx/src/core/snowflake_entity.dart';
import 'package:nyxx/src/core/user/user.dart';
import 'package:nyxx/src/nyxx.dart';
import 'package:nyxx/src/typedefs.dart';

abstract class IIntegration implements SnowflakeEntity {
  /// The integration name.
  String get name;

  /// The guild this integration belongs to.
  IGuild get guild;

  /// The integration type.
  IntegrationType get type;

  /// Whether this integration is enabled.
  bool? get enabled;

  /// Whether this integration is currently syncing.
  bool? get syncing;

  /// The [IRole] that this integration uses for subscribers.
  IRole? get role;

  /// The roles managed by this integration.
  Map<Snowflake, IRole> get manangedRoles;

  /// Whether emoticons should be synced for this integration ([IntegrationType.twitch] only currently).
  bool? get enableEmoticons;

  /// The behavior of expiring subscribers.
  IntegrationExpireBehavior? get expireBehavior;

  /// The grace period before expiring subscribers.
  Duration? get expireGracePeriod;

  /// The user for this integration.
  IUser? get user;

  /// The integration account information.
  IIntegrationAccount get account;

  /// When this integration was last synced.
  DateTime? get syncedAt;

  /// How many subscribers this integration has.
  int? get subscribersCount;

  /// Whether this integration has been revoked.
  bool? get isRevoked;

  /// The bot/OAuth2 application for Discord integration.
  IIntegrationApplication get application;
}

abstract class IIntegrationAccount {
  /// The id of the account.
  String get id;

  /// The name of the account.
  String get name;
}

abstract class IIntegrationApplication implements SnowflakeEntity {
  /// The name of the application.
  String get name;

  /// The icon hash of the application.
  String? get iconHash;

  /// The description of the application.
  String get description;

  /// The bot associated with this application.
  IUser? get bot;
}

class Integration extends SnowflakeEntity implements IIntegration {
  @override
  late final String name;

  @override
  late final IGuild guild;

  @override
  late final IntegrationType type;

  @override
  late final bool? enabled;

  @override
  late final bool? syncing;

  @override
  late final IRole? role;

  @override
  // TODO
  Map<Snowflake, IRole> get manangedRoles => {};

  @override
  late final bool? enableEmoticons;

  @override
  late final IntegrationExpireBehavior expireBehavior;

  @override
  late final Duration? expireGracePeriod;

  @override
  late final IUser? user;

  @override
  late final IIntegrationAccount account;

  @override
  late final DateTime? syncedAt;

  @override
  late final int? subscribersCount;

  @override
  late final bool? isRevoked;

  @override
  late final IIntegrationApplication application;

  Integration(RawApiMap data, this.guild) : super(Snowflake(data['id'])) {
    name = data['name'] as String;
    type = IntegrationType.values.byName(data['type'] as String);
    enabled = data['enabled'] != null ? data['enabled'] as bool : null;
    syncing = data['syncing'] != null ? data['syncing'] as bool : null;
    role = data['role_id'] != null ? guild.roles[Snowflake(data['role_id'])] : null;
    enableEmoticons = data['enable_emoticons'] != null ? data['enable_emoticons'] as bool : null;
    expireBehavior = IntegrationExpireBehavior.values.firstWhere((e) => e.index == data['expire_behavior']);
    expireGracePeriod = data['expire_grace_period'] != null ? Duration(days: data['expire_grace_period'] as int) : null;
    user = data['user'] != null
        ? guild.client.users.putIfAbsent(
            Snowflake(data['user']['id']),
            () => User(guild.client, data['user'] as RawApiMap),
          )
        : null;

    account = IntegrationAccount(data['account'] as RawApiMap);
    syncedAt = DateTime.fromMillisecondsSinceEpoch(data['synced_at'] as int);
    subscribersCount = data['subscribers_count'] != null ? data['subscribers_count'] as int : null;
    isRevoked = data['revoked'] != null ? data['revoked'] as bool : null;
  }
}

class IntegrationAccount implements IIntegrationAccount {
  @override
  late final String id;

  @override
  late final String name;

  IntegrationAccount(RawApiMap data) {
    id = data['id'] as String;
    name = data['name'] as String;
  }
}

class IntegrationApplication extends SnowflakeEntity implements IIntegrationApplication {
  @override
  late final IUser? bot;

  @override
  late final DateTime createdAt;

  @override
  late final String description;

  @override
  late final String? iconHash;

  @override
  late final String name;

  IntegrationApplication(RawApiMap data, INyxx client) : super(Snowflake(data['id'])) {
    name = data['name'] as String;
    iconHash = data['icon'] as String?;
    description = data['description'] as String;
    bot = data['bot'] != null
        ? client.users.putIfAbsent(
            Snowflake(data['bot']['id']),
            () => User(client, data['bot'] as RawApiMap),
          )
        : null;
  }
}

enum IntegrationType {
  /// The integration type is "twitch".
  twitch,

  /// The integration type is "youtube".
  youtube,

  /// The integration type is "discord".
  discord,
}

enum IntegrationExpireBehavior {
  removeRole,
  kick,
}
