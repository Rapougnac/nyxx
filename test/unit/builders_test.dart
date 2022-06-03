import 'dart:io';

import 'package:http/http.dart';
import 'package:nyxx/nyxx.dart';
import 'package:nyxx/src/core/channel/text_channel.dart';
import 'package:nyxx/src/core/discord_color.dart';
import 'package:nyxx/src/core/guild/scheduled_event.dart';
import 'package:nyxx/src/core/guild/status.dart';
import 'package:nyxx/src/core/message/message.dart';
import 'package:nyxx/src/core/permissions/permissions.dart';
import 'package:nyxx/src/core/snowflake.dart';
import 'package:nyxx/src/core/user/presence.dart';
import 'package:nyxx/src/internal/cache/cacheable.dart';
import 'package:nyxx/src/utils/builders/attachment_builder.dart';
import 'package:nyxx/src/utils/builders/channel_builder.dart';
import 'package:nyxx/src/utils/builders/embed_builder.dart';
import 'package:nyxx/src/utils/builders/forum_thread_builder.dart';
import 'package:nyxx/src/utils/builders/guild_builder.dart';
import 'package:nyxx/src/utils/builders/guild_event_builder.dart';
import 'package:nyxx/src/utils/builders/member_builder.dart';
import 'package:nyxx/src/utils/builders/message_builder.dart';
import 'package:nyxx/src/utils/builders/permissions_builder.dart';
import 'package:nyxx/src/utils/builders/presence_builder.dart';
import 'package:nyxx/src/utils/builders/reply_builder.dart';
import 'package:nyxx/src/utils/builders/sticker_builder.dart';
import 'package:nyxx/src/utils/builders/thread_builder.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

import '../mocks/channel.mock.dart';
import '../mocks/member.mock.dart';
import '../mocks/message.mock.dart';
import '../mocks/nyxx_rest.mock.dart';

main() {
  test("ThreadBuilder", () {
    final publicBuilder = ThreadBuilder('test name')
      ..archiveAfter = ThreadArchiveTime.threeDays
      ..private = false;
    expect(publicBuilder.build(), equals({"auto_archive_duration": ThreadArchiveTime.threeDays.value, "name": 'test name', "type": 11}));

    final privateBuilder = ThreadBuilder.private("second name");
    expect(privateBuilder.build(), equals({"name": 'second name', "type": 12}));
  });

  test('StickerBuilder', () {
    final builder = StickerBuilder()
      ..name = "this is name"
      ..description = "this is description"
      ..tags = "tags";

    expect(builder.build(), equals({"name": "this is name", "description": "this is description", "tags": "tags"}));
  });

  test("ReplyBuilder", () {
    final basicBuilder = ReplyBuilder(Snowflake.zero());
    expect(basicBuilder.build(), equals({"message_id": '0', "fail_if_not_exists": false}));

    final messageBuilder = ReplyBuilder.fromMessage(MockMessage({"content": "content"}, Snowflake(123)));
    expect(messageBuilder.build(), equals({"message_id": '123', "fail_if_not_exists": false}));

    final messageCacheable = MessageCacheable(NyxxRestEmptyMock(), Snowflake(123), ChannelCacheable<ITextChannel>(NyxxRestEmptyMock(), Snowflake(456)));
    final cacheableBuilder = ReplyBuilder.fromCacheable(messageCacheable, true);
    expect(cacheableBuilder.build(), equals({"message_id": '123', "fail_if_not_exists": true}));
  });

  group("channel builder", () {
    test('ChannelBuilder', () {
      final builder = TextChannelBuilder.create("test");
      builder.permissionOverrides = [PermissionOverrideBuilder.from(0, Snowflake.zero(), Permissions.empty())];

      final expectedResult = {
        'permission_overwrites': [
          {'allow': "0", 'deny': "122406567679", 'id': '0', 'type': 0}
        ],
        'type': 0,
        'name': 'test'
      };
      expect(builder.build(), expectedResult);
    });
  });

  group('presence_builder.dart', () {
    test('PresenceBuilder', () {
      final activityBuilder = ActivityBuilder.game("test game name");
      final activityBuilderWatching = ActivityBuilder.watching("test watching name");
      
      expect(activityBuilderWatching.build(), equals({"name": "test watching name", "type": 3}));

      final ofBuilder = PresenceBuilder.of(status: UserStatus.dnd, activity: activityBuilder);
      expect(
          ofBuilder.build(),
          equals({
            'status': UserStatus.dnd.toString(),
            'activities': [
              {
                "name": "test game name",
                "type": ActivityType.game.value,
              }
            ],
            'afk': false,
            'since': null,
          }));

      final now = DateTime.now();
      final idleBuilder = PresenceBuilder.idle(since: now);

      expect(
          idleBuilder.build(),
          equals({
            'status': UserStatus.idle.toString(),
            'afk': true,
            'since': now.millisecondsSinceEpoch,
          }));
    });

    test('ActivityBuilder', () {
      final streamingBuilder = ActivityBuilder.streaming("test game name", 'https://twitch.tv');
      expect(streamingBuilder.build(), equals({"name": "test game name", "type": ActivityType.streaming.value, "url": 'https://twitch.tv'}));

      final listeningBuilder = ActivityBuilder.listening("test listening name");
      expect(
          listeningBuilder.build(),
          equals({
            "name": "test listening name",
            "type": ActivityType.listening.value,
          }));
    });
  });

  test('PermissionOverrideBuilder', () {
    final builder = PermissionOverrideBuilder(0, Snowflake.zero());
    expect(builder.build(), equals({"allow": "0", "deny": "0", 'id': '0', 'type': 0}));

    final fromBuilder = PermissionOverrideBuilder.from(0, Snowflake.zero(), Permissions.empty());
    expect(fromBuilder.build(), equals({"allow": "0", "deny": "122406567679", 'id': '0', 'type': 0}));
    expect(fromBuilder.calculatePermissionValue(), equals(0));

    final ofBuilder = PermissionOverrideBuilder.of(MockMember(Snowflake.zero()))
      ..sendMessages = true
      ..addReactions = false;

    expect(ofBuilder.build(), equals({"allow": (1 << 11).toString(), "deny": (1 << 6).toString(), 'id': '0', 'type': 1}));
    expect(ofBuilder.calculatePermissionValue(), equals(1 << 11));
  });

  group('MemberBuilder', () {
    test('channel empty', () {
      final builder = MemberBuilder()..channel = Snowflake.zero();

      expect({}, builder.build());
    });

    test('channel with value', () {
      final builder = MemberBuilder()..channel = Snowflake(123);

      expect({'channel_id': '123'}, builder.build());
    });

    test('timeout empty', () {
      final now = DateTime.now();

      final builder = MemberBuilder()..timeoutUntil = now;

      expect({'communication_disabled_until': now.toIso8601String()}, builder.build());
    });

    test('roles serialization', () {
      final builder = MemberBuilder()..roles = [Snowflake(1), Snowflake(2)];

      expect({
        'roles': ['1', '2']
      }, builder.build());
    });
  });

  group('MessageBuilder', () {
    test('clear character', () {
      final builder = MessageBuilder.empty();
      expect(builder.content, equals(MessageBuilder.clearCharacter));
    });

    test('embeds', () async {
      final builder = MessageBuilder.embed(
        EmbedBuilder()
          ..description = 'test1'
          ..addAuthor(
            (author) => author
              ..iconUrl = 'https://i.imgur.com/tPLHwT9.jpeg'
              ..name = 'some name'
              ..url = 'https://google.com',
          )
          ..addFooter(
            (footer) => footer
              ..iconUrl = 'https://i.imgur.com/tPLHwT9.jpeg'
              ..text = 'Hello',
          )
          ..addField(
            builder: (field) => field
              ..content = 'test3'
              ..inline = true
              ..name = 'test4',
          )
          ..replaceField(
            name: 'test4',
            inline: false,
            content: 'bb',
          )
          ..addField(
            name: 'h',
            content: 'aa',
            inline: true,
          ),
      );
      await builder.addEmbed((embed) => embed.description = 'test2');

      final result = builder.build();

      expect(
          result,
          equals({
            'content': '',
            'embeds': [
              {
                'description': 'test1',
                'footer': {
                  'text': 'Hello',
                  'icon_url': 'https://i.imgur.com/tPLHwT9.jpeg'
                },
                'author': {
                  'name': 'some name',
                  'icon_url': 'https://i.imgur.com/tPLHwT9.jpeg',
                  'url': 'https://google.com'
                },
                'fields': [
                  {
                    'name': 'test4',
                    'value': 'bb',
                    'inline': false,
                  },
                  {
                    'name': 'h',
                    'value': 'aa',
                    'inline': true,
                  },
                ],
              },
              {
                'description': 'test2',
              }
            ]
          },
        ),
      );

      expect(() => EmbedBuilder()..title = ('t' * 257)..build(), throwsA(isA<EmbedBuilderArgumentException>()));
      expect(() => EmbedBuilder()..description = ('t' * 2049)..build(), throwsA(isA<EmbedBuilderArgumentException>()));
      expect(() => EmbedBuilder()..fields = [for(int i = 0; i <= 25; i++) EmbedFieldBuilder()]..build(), throwsA(isA<EmbedBuilderArgumentException>()));

      final overloadedEmbedBuilder = EmbedBuilder()
        ..title = ('t' * 256)
        ..description = ('e' * 4096)
        ..fields = [
          for (int i = 0; i < 25; i++)
            EmbedFieldBuilder()
              ..content = ('c' * 1024)
              ..name = ('n' * 256)
        ]
        ..author = (EmbedAuthorBuilder()..name = ('f' * 256))
        ..footer = (EmbedFooterBuilder()..text = ('g' * 2048));

      expect(() => overloadedEmbedBuilder.build(), throwsA(isA<EmbedBuilderArgumentException>()));
    });

    test('text', () {
      final dateTime = DateTime(2000);

      final builder = MessageBuilder()
        ..appendSpoiler('spoiler')
        ..appendNewLine()
        ..appendItalics('italics')
        ..appendBold('bold')
        ..appendStrike('strike')
        ..appendCodeSimple('this is code simple')
        ..appendMention(MockMember(Snowflake.zero()))
        ..appendTimestamp(dateTime)
        ..appendCode('dart', 'final int = 124;');

      expect(
          builder.build(),
          equals({
            'content': '||spoiler||\n'
                '*italics***bold**~~strike~~`this is code simple`<@0><t:${dateTime.millisecondsSinceEpoch ~/ 1000}:f>\n'
                '```dart\n'
                'final int = 124;```'
          }));

      expect(builder.getMappedFiles(), isEmpty);
      expect(builder.canBeUsedAsNewMessage(), isTrue);

      expect(MessageDecoration.bold.format('test'), equals('**test**'));
    });

    test('files', () async {
      final builder = MessageBuilder.files([AttachmentBuilder.path('./test/files/1.png')]);
      final mockChannel = MockTextChannel(Snowflake.zero());
      
      expect(builder.getMappedFiles(), isNotEmpty);

      builder.addAttachment(AttachmentBuilder.path('./test/files/2.png'));

      expect(builder.files!.length, equals(2));

      builder.addBytesAttachment(File('./test/files/3.png').readAsBytesSync(), '3.png');

      builder.addFileAttachment(File('./test/files/1.png'));

      builder.addPathAttachment('./test/files/2.png');

      expect(builder.files!.length, equals(5));

      expect(await builder.send(mockChannel), isA<IMessage>());
    });

    test('fromMessage', () {
      final mockMessage = MockMessage({'content': 'testt', 'tts': true}, Snowflake.zero());

      final builder = MessageBuilder.fromMessage(mockMessage);

      expect(builder.tts, isTrue);
      expect(builder.content, equals('testt'));
      expect(builder.embeds, isEmpty);
      expect(builder.replyBuilder, isNull);
    });

    test("ForumThreadBuilder", () {
      final builder = ForumThreadBuilder("test", MessageBuilder.content("test"));

      expect(
          builder.build(),
          equals({
            'name': 'test',
            'message': {
              'content': 'test'
            }
          })
      );
    });
  });

  group('Attachments builders', () {
    test('AttachementMetadataBuilder', () {
      final builder = AttachmentMetadataBuilder(Snowflake(1234), 'test.png', 'A description');
      final builder2 = AttachmentMetadataBuilder(Snowflake(456), 'test.png');

      expect(builder.build(), equals({'id': '1234', 'filename': 'test.png', 'description': 'A description'}));
      expect(builder2.build(), equals({'id': '456', 'filename': 'test.png', 'description': 'test.png'}));
    });

    test('AttachmentBuilder', () {
      final builder = AttachmentBuilder.path('./test/files/1.png', name: 'one.png', spoiler: true);

      expect(builder.getBase64(), startsWith('data:image/png;base64,'));
      expect(builder.attachUrl, equals('attachment://one.png'));
      expect(builder.getMultipartFile(), isA<MultipartFile>());
    });
  });

  group('Guild', () {
    test('GuildEventBuilder', () {
      final builder = GuildEventBuilder()
        ..metadata = EntityMetadataBuilder('test')
        ..name = 'Super Event'
        ..privacyLevel = GuildEventPrivacyLevel.guildOnly
        ..startDate = DateTime(2022, 8, 3)
        ..endDate = DateTime(2022, 8, 4)
        ..description = 'Cool event'
        ..type = GuildEventType.external
        ..status = GuildEventStatus.active;

      expect(
        builder.build(),
        equals({
          'channel_id': '0',
          'name': 'Super Event',
          'description': 'Cool event',
          'scheduled_start_time': '2022-08-03T00:00:00.000',
          'scheduled_end_time': '2022-08-04T00:00:00.000',
          'entity_type': 3,
          'privacy_level': 2,
          'status': 2,
          'entity_metadata': {'location': 'test'}
        }),
      );
    });

    test('GuildBuilder', () {
      final builder = GuildBuilder('test guild')
        ..icon = AttachmentBuilder.path('./test/files/1.png')
        ..verificationLevel = 0
        ..defaultMessageNotifications = 0
        ..explicitContentFilter = 0
        ..roles = [
          RoleBuilder('test role')
            ..color = DiscordColor.aquamarine
            ..hoist = true
            ..position = 1
            ..permission = (PermissionsBuilder()..administrator = true)
            ..mentionable = true
            ..roleIcon = AttachmentBuilder.path('./test/files/2.png')
            ..roleIconEmoji = '😔'
            ..id = Snowflake.zero()
        ]
        ..channels = [
          VoiceChannelBuilder()
            ..name = 'test channel'
            ..bitrate = 123
            ..userLimit = 10
            // this should be in Text channel builder, no?
            ..rateLimitPerUser = 15
            ..rtcRegion = 'en-US',
          TextChannelBuilder.create('test channel 2')..id = Snowflake(188)
        ]
        ..afkChannelId = Snowflake(42)
        ..afkTimeout = 5000
        ..systemChannelId = Snowflake(188)
        ..systemChannelFlags =
            SystemChannelFlags.suppressGuildReminderNotifications;
          
        // print(builder.build());
        expect(builder.build(), equals({
            'name': 'test guild',
            'icon':
                'data:image/.png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAIAAACRXR/mAAAAnElEQVRYw+3ZQQ6AIAxEUdpw/yvXvSQaCi3V/C5dmJdBdIhiZq3eaCs5sH7A6rtuJCK3KyubSdZ34ghal/Ug0LFnK87kTCsU5EwrwTSXVg5oLq1Xk5lt/LzqLlP2Ij6bggqIFjT5X6fRLU0dUSU0R62Wk4eV1rC/XwMzDyO9iIMuDwsWLFiwTh9oWURYUf2MRYQFq8II/3xgwSowF+WZM2SFu9ItAAAAAElFTkSuQmCC',
            'verification_level': 0,
            'default_message_notifications': 0,
            'explicit_content_filter': 0,
            'roles': [
              {
                'name': 'test role',
                'color': 65471,
                'hoist': true,
                'position': 1,
                'permissions': '8',
                'mentionable': true,
                'icon':
                    'data:image/.png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAIAAACRXR/mAAAA6klEQVRYw+2ZyQ7DMAhEDeL/f5leo6hZPAyIVnB1bL+wZeyIu69+pqulDdZgZZnBM0Xkaihe3QIscQPEItvDegNEIdMkJuB5BCuyRxYWzARPtODSxwQiehTvW+5+SuqvOY6xKuaqbN2hmJ/yGimIVaPPlF5HFG5t6KoUBUFpE7+vtyoPI8blYDX69CBiPtZuyU7G4iofbRhBGhZdJGoeU5GWr1Q+2ip20ePreyVd561sJgSrgGkviI+ZRPyWGyu1ufrCKLVG1zx3VyPc+t9Ct1Vlx5d8RJxLyj/Asrz6ilSMzM+VwRqswbqyD65hY2n2oxxTAAAAAElFTkSuQmCC',
                'unicode_emoji': '😔',
                'id': 0
              }
            ],
            'channels': [
              {
                'name': 'test channel',
                'type': 2,
                'bitrate': 123,
                'user_limit': 10,
                'rate_limit_per_user': 15,
                'rtc_region': 'en-US'
              },
              {'name': 'test channel 2', 'id': '188', 'type': 0}
            ],
            // TODO: Fix this, this is serialized as Snowflake, not String or int.
            'afk_channel_id': 42,
            'afk_timeout': 5000,
            'system_channel_id': '188',
            'system_channel_flags': 4
          }));
    });
  });
}
