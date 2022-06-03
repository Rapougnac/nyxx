import 'package:mockito/mockito.dart';
import 'package:nyxx/nyxx.dart';
import 'package:nyxx/src/core/embed/embed.dart';
import 'package:nyxx/src/core/message/referenced_message.dart';
import 'package:nyxx/src/internal/cache/cacheable.dart';

import 'nyxx_rest.mock.dart';

class MockMessage extends SnowflakeEntity with Fake implements IMessage {
  @override
  late String content;

  @override
  late bool tts;

  @override
  // TODO: Change type to `IEmbed` instead of `Embed`
  List<Embed> get embeds => [];

  @override
  ReferencedMessage? get referencedMessage => null;

  @override

  @override
  Cacheable<Snowflake, IGuild>? get guild => GuildCacheable(NyxxRestEmptyMock(), Snowflake.zero());

  @override
  IMember? get member => null;

  MockMessage(RawApiMap rawData, Snowflake id) : super(id) {
    content = rawData["content"] as String;
    tts = (rawData["tts"] as bool?) ?? false;
  }
}
