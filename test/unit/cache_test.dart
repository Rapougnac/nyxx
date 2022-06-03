import 'package:nyxx/nyxx.dart';
import 'package:nyxx/src/internal/cache/cacheable.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

import '../mocks/channel.mock.dart';
import '../mocks/member.mock.dart';
import '../mocks/message.mock.dart';
import '../mocks/nyxx_rest.mock.dart';

IMessage createMockMessage(Snowflake id) => MockMessage({"content": "i dont care"}, id);

main() {
  group("cache", () {
    test("Snowflake cache", () async {
      final firstMessage = createMockMessage(Snowflake(1));
      final secondMessage = createMockMessage(Snowflake(2));
      final thirdMessage = createMockMessage(Snowflake(3));

      final cache = SnowflakeCache<IMessage>(2);

      cache[firstMessage.id] = firstMessage;
      cache[secondMessage.id] = secondMessage;

      expect(cache, hasLength(2));
      expect(cache[firstMessage.id], isNotNull);
      expect(cache[secondMessage.id], isNotNull);

      cache[thirdMessage.id] = thirdMessage;

      expect(cache[firstMessage.id], isNull);
      expect(cache[thirdMessage.id], isNotNull);

      cache.clear();

      expect(cache, hasLength(0));

      final alwaysEmptyCache = SnowflakeCache<IMessage>(0);
      expect(alwaysEmptyCache, hasLength(0));
      cache[firstMessage.id] = firstMessage;
      expect(alwaysEmptyCache, hasLength(0));
      await cache.dispose();
    });

    test("Channel cache", () async {
      final cache = ChannelCacheable(NyxxRestEmptyMock(), Snowflake.zero());

      expect(cache.getFromCache(), isNull);
      expect(cache.hashCode, cache.id.hashCode);
    });
  });

  group("cache policy", () {
    // test('CachePolicy', () {
    //   final cachePolicy = CachePolicy();
    // });

    test("CachePolicyLocation", () {
      final cachePolicyLocation = CachePolicyLocation();

      expect(cachePolicyLocation.objectConstructor, isFalse);
      expect(cachePolicyLocation.event, isTrue);
      expect(cachePolicyLocation.http, isTrue);
      expect(cachePolicyLocation.other, isFalse);

      final cachePolicyLocationAll = CachePolicyLocation.all();

      expect(cachePolicyLocationAll.objectConstructor, isTrue);
      expect(cachePolicyLocationAll.event, isTrue);
      expect(cachePolicyLocationAll.other, isTrue);
      expect(cachePolicyLocationAll.http, isTrue);

      final cachePolicyLocationNone = CachePolicyLocation.none();

      expect(cachePolicyLocationNone.objectConstructor, isFalse);
      expect(cachePolicyLocationNone.event, isFalse);
      expect(cachePolicyLocationNone.other, isFalse);
      expect(cachePolicyLocationNone.http, isFalse);
    });

    test('MemberCachePolicy', () {
      final member = MockMember(Snowflake.zero());

      final memberCachePolicyNone = MemberCachePolicy.none;
      expect(memberCachePolicyNone.canCache(member), isFalse);

      final memberCachePolicyAll = MemberCachePolicy.all;
      expect(memberCachePolicyAll.canCache(member), isTrue);

      final memberCachePolicyOnline = MemberCachePolicy.online;
      expect(memberCachePolicyOnline.canCache(member), isFalse);

      final memberCachePolicyVoice = MemberCachePolicy.voice;
      expect(memberCachePolicyVoice.canCache(member), isFalse);

      final memberCachePolicyOwner = MemberCachePolicy.owner;
      expect(memberCachePolicyOwner.canCache(member), isFalse);

      final memberCachePolicyDef = MemberCachePolicy.def;
      expect(memberCachePolicyDef.canCache(member), isFalse);
    });

    test('ChannelCachePolicy', () {
      final voiceChannel = MockVoiceChannel(Snowflake.zero());
      final threadChannel = MockThreadChannel(Snowflake.zero());
      final textChannel = MockTextChannel(Snowflake.zero());

      final channelCachePolicy = ChannelCachePolicy.none;
      expect(channelCachePolicy.canCache(voiceChannel), isFalse);

      final channelCachePolicyAll = ChannelCachePolicy.all;
      expect(channelCachePolicyAll.canCache(voiceChannel), isTrue);
      expect(channelCachePolicyAll.canCache(threadChannel), isTrue);
      expect(channelCachePolicyAll.canCache(textChannel), isTrue);

      final channelCachePolicyVoice = ChannelCachePolicy.voice;
      expect(channelCachePolicyVoice.canCache(voiceChannel), isTrue);
      expect(channelCachePolicyVoice.canCache(textChannel), isFalse);

      final channelCachePolicyText = ChannelCachePolicy.text;
      expect(channelCachePolicyText.canCache(textChannel), isTrue);
      expect(channelCachePolicyText.canCache(threadChannel), isTrue);
      expect(channelCachePolicyText.canCache(voiceChannel), isFalse);

      final channelCachePolicyThread = ChannelCachePolicy.thread;
      expect(channelCachePolicyThread.canCache(textChannel), isFalse);
      expect(channelCachePolicyThread.canCache(threadChannel), isTrue);
      expect(channelCachePolicyThread.canCache(voiceChannel), isFalse);

      final channelCachePolicyDef = ChannelCachePolicy.def;
      expect(channelCachePolicyDef.canCache(voiceChannel), isTrue);
      expect(channelCachePolicyDef.canCache(textChannel), isTrue);
      expect(channelCachePolicyDef.canCache(threadChannel), isTrue);
    });

    test('MessageCachePolicy', () {
      final message = createMockMessage(Snowflake.zero());

      final messageCachePolicyAll = MessageCachePolicy.all;
      expect(messageCachePolicyAll.canCache(message), isTrue);

      final messageCachePolicyNone = MessageCachePolicy.none;
      expect(messageCachePolicyNone.canCache(message), isFalse);

      final messageCachePolicyDef = MessageCachePolicy.def;
      expect(messageCachePolicyDef.canCache(message), isTrue);

      final messageCachePolicyGuild = MessageCachePolicy.guildMessages;
      expect(messageCachePolicyGuild.canCache(message), isTrue);

      final messageCachePolicyDm = MessageCachePolicy.dmMessages;
      expect(messageCachePolicyDm.canCache(message), isFalse);
    });
  });
}
