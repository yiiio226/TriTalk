// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'swagger.swagger.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$Swagger extends Swagger {
  _$Swagger([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = Swagger;

  @override
  Future<Response<HealthGet$Response>> _healthGet({
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: '',
      operationId: '',
      consumes: [],
      produces: [],
      security: [],
      tags: [],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/health');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<HealthGet$Response, HealthGet$Response>($request);
  }

  @override
  Future<Response<ChatSendPost$Response>> _chatSendPost({
    required ChatSendPost$RequestBody? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: '',
      operationId: '',
      consumes: [],
      produces: [],
      security: [],
      tags: [],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/chat/send');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<ChatSendPost$Response, ChatSendPost$Response>($request);
  }

  @override
  Future<Response<ChatTranscribePost$Response>> _chatTranscribePost({
    required List<int> audio,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: '',
      operationId: '',
      consumes: [],
      produces: [],
      security: [],
      tags: [],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/chat/transcribe');
    final List<PartValue> $parts = <PartValue>[
      PartValueFile<List<int>>('audio', audio),
    ];
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      parts: $parts,
      multipart: true,
      tag: swaggerMetaData,
    );
    return client
        .send<ChatTranscribePost$Response, ChatTranscribePost$Response>(
          $request,
        );
  }

  @override
  Future<Response<ChatHintPost$Response>> _chatHintPost({
    required ChatHintPost$RequestBody? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: '',
      operationId: '',
      consumes: [],
      produces: [],
      security: [],
      tags: [],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/chat/hint');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<ChatHintPost$Response, ChatHintPost$Response>($request);
  }

  @override
  Future<Response<SceneGeneratePost$Response>> _sceneGeneratePost({
    required SceneGeneratePost$RequestBody? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: '',
      operationId: '',
      consumes: [],
      produces: [],
      security: [],
      tags: [],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/scene/generate');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<SceneGeneratePost$Response, SceneGeneratePost$Response>(
      $request,
    );
  }

  @override
  Future<Response<ScenePolishPost$Response>> _scenePolishPost({
    required ScenePolishPost$RequestBody? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: '',
      operationId: '',
      consumes: [],
      produces: [],
      security: [],
      tags: [],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/scene/polish');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<ScenePolishPost$Response, ScenePolishPost$Response>(
      $request,
    );
  }

  @override
  Future<Response<CommonTranslatePost$Response>> _commonTranslatePost({
    required CommonTranslatePost$RequestBody? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: '',
      operationId: '',
      consumes: [],
      produces: [],
      security: [],
      tags: [],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/common/translate');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client
        .send<CommonTranslatePost$Response, CommonTranslatePost$Response>(
          $request,
        );
  }

  @override
  Future<Response<ChatShadowPost$Response>> _chatShadowPost({
    required ChatShadowPost$RequestBody? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: '',
      operationId: '',
      consumes: [],
      produces: [],
      security: [],
      tags: [],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/chat/shadow');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<ChatShadowPost$Response, ChatShadowPost$Response>(
      $request,
    );
  }

  @override
  Future<Response<ChatOptimizePost$Response>> _chatOptimizePost({
    required ChatOptimizePost$RequestBody? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: '',
      operationId: '',
      consumes: [],
      produces: [],
      security: [],
      tags: [],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/chat/optimize');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<ChatOptimizePost$Response, ChatOptimizePost$Response>(
      $request,
    );
  }

  @override
  Future<Response<ChatMessagesDelete$Response>> _chatMessagesDelete({
    required ChatMessagesDelete$RequestBody? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: '',
      operationId: '',
      consumes: [],
      produces: [],
      security: [],
      tags: [],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/chat/messages');
    final $body = body;
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client
        .send<ChatMessagesDelete$Response, ChatMessagesDelete$Response>(
          $request,
        );
  }

  @override
  Future<Response<UserSyncPost$Response>> _userSyncPost({
    required UserSyncPost$RequestBody? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: '',
      operationId: '',
      consumes: [],
      produces: [],
      security: [],
      tags: [],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/user/sync');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<UserSyncPost$Response, UserSyncPost$Response>($request);
  }

  @override
  Future<Response<ShadowingSavePost$Response>> _shadowingSavePost({
    required ShadowingSavePost$RequestBody? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: '',
      operationId: '',
      consumes: [],
      produces: [],
      security: [],
      tags: [],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/shadowing/save');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<ShadowingSavePost$Response, ShadowingSavePost$Response>(
      $request,
    );
  }

  @override
  Future<Response<ShadowingHistoryGet$Response>> _shadowingHistoryGet({
    String? sourceId,
    String? targetText,
    String? sceneKey,
    String? limit,
    String? offset,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: '',
      operationId: '',
      consumes: [],
      produces: [],
      security: [],
      tags: [],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/shadowing/history');
    final Map<String, dynamic> $params = <String, dynamic>{
      'source_id': sourceId,
      'target_text': targetText,
      'scene_key': sceneKey,
      'limit': limit,
      'offset': offset,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client
        .send<ShadowingHistoryGet$Response, ShadowingHistoryGet$Response>(
          $request,
        );
  }
}
