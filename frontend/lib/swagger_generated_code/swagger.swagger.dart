// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element_parameter


import 'swagger.models.swagger.dart';
import 'package:chopper/chopper.dart';

import 'client_mapping.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:chopper/chopper.dart' as chopper;
import 'swagger.enums.swagger.dart' as enums;
import 'swagger.metadata.swagger.dart';
export 'swagger.enums.swagger.dart';
export 'swagger.models.swagger.dart';

part 'swagger.swagger.chopper.dart';

// **************************************************************************
// SwaggerChopperGenerator
// **************************************************************************

@ChopperApi()
abstract class Swagger extends ChopperService {
  static Swagger create({
    ChopperClient? client,
    http.Client? httpClient,
    Authenticator? authenticator,
    ErrorConverter? errorConverter,
    Converter? converter,
    Uri? baseUrl,
    List<Interceptor>? interceptors,
  }) {
    if (client != null) {
      return _$Swagger(client);
    }

    final newClient = ChopperClient(
      services: [_$Swagger()],
      converter: converter ?? $JsonSerializableConverter(),
      interceptors: interceptors ?? [],
      client: httpClient,
      authenticator: authenticator,
      errorConverter: errorConverter,
      baseUrl: baseUrl ?? Uri.parse('http://'),
    );
    return _$Swagger(newClient);
  }

  ///
  Future<chopper.Response<HealthGet$Response>> healthGet() {
    generatedMapping.putIfAbsent(
      HealthGet$Response,
      () => HealthGet$Response.fromJsonFactory,
    );

    return _healthGet();
  }

  ///
  @GET(path: '/health')
  Future<chopper.Response<HealthGet$Response>> _healthGet({
    @chopper.Tag()
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
  });

  ///
  Future<chopper.Response<ChatSendPost$Response>> chatSendPost({
    required ChatSendPost$RequestBody? body,
  }) {
    generatedMapping.putIfAbsent(
      ChatSendPost$Response,
      () => ChatSendPost$Response.fromJsonFactory,
    );

    return _chatSendPost(body: body);
  }

  ///
  @POST(path: '/chat/send', optionalBody: true)
  Future<chopper.Response<ChatSendPost$Response>> _chatSendPost({
    @Body() required ChatSendPost$RequestBody? body,
    @chopper.Tag()
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
  });

  ///
  Future<chopper.Response<ChatTranscribePost$Response>> chatTranscribePost({
    required List<int> audio,
  }) {
    generatedMapping.putIfAbsent(
      ChatTranscribePost$Response,
      () => ChatTranscribePost$Response.fromJsonFactory,
    );

    return _chatTranscribePost(audio: audio);
  }

  ///
  @POST(path: '/chat/transcribe', optionalBody: true)
  @Multipart()
  Future<chopper.Response<ChatTranscribePost$Response>> _chatTranscribePost({
    @PartFile() required List<int> audio,
    @chopper.Tag()
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
  });

  ///
  Future<chopper.Response<ChatHintPost$Response>> chatHintPost({
    required ChatHintPost$RequestBody? body,
  }) {
    generatedMapping.putIfAbsent(
      ChatHintPost$Response,
      () => ChatHintPost$Response.fromJsonFactory,
    );

    return _chatHintPost(body: body);
  }

  ///
  @POST(path: '/chat/hint', optionalBody: true)
  Future<chopper.Response<ChatHintPost$Response>> _chatHintPost({
    @Body() required ChatHintPost$RequestBody? body,
    @chopper.Tag()
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
  });

  ///
  Future<chopper.Response<SceneGeneratePost$Response>> sceneGeneratePost({
    required SceneGeneratePost$RequestBody? body,
  }) {
    generatedMapping.putIfAbsent(
      SceneGeneratePost$Response,
      () => SceneGeneratePost$Response.fromJsonFactory,
    );

    return _sceneGeneratePost(body: body);
  }

  ///
  @POST(path: '/scene/generate', optionalBody: true)
  Future<chopper.Response<SceneGeneratePost$Response>> _sceneGeneratePost({
    @Body() required SceneGeneratePost$RequestBody? body,
    @chopper.Tag()
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
  });

  ///
  Future<chopper.Response<ScenePolishPost$Response>> scenePolishPost({
    required ScenePolishPost$RequestBody? body,
  }) {
    generatedMapping.putIfAbsent(
      ScenePolishPost$Response,
      () => ScenePolishPost$Response.fromJsonFactory,
    );

    return _scenePolishPost(body: body);
  }

  ///
  @POST(path: '/scene/polish', optionalBody: true)
  Future<chopper.Response<ScenePolishPost$Response>> _scenePolishPost({
    @Body() required ScenePolishPost$RequestBody? body,
    @chopper.Tag()
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
  });

  ///
  Future<chopper.Response<CommonTranslatePost$Response>> commonTranslatePost({
    required CommonTranslatePost$RequestBody? body,
  }) {
    generatedMapping.putIfAbsent(
      CommonTranslatePost$Response,
      () => CommonTranslatePost$Response.fromJsonFactory,
    );

    return _commonTranslatePost(body: body);
  }

  ///
  @POST(path: '/common/translate', optionalBody: true)
  Future<chopper.Response<CommonTranslatePost$Response>> _commonTranslatePost({
    @Body() required CommonTranslatePost$RequestBody? body,
    @chopper.Tag()
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
  });

  ///
  Future<chopper.Response<ChatShadowPost$Response>> chatShadowPost({
    required ChatShadowPost$RequestBody? body,
  }) {
    generatedMapping.putIfAbsent(
      ChatShadowPost$Response,
      () => ChatShadowPost$Response.fromJsonFactory,
    );

    return _chatShadowPost(body: body);
  }

  ///
  @POST(path: '/chat/shadow', optionalBody: true)
  Future<chopper.Response<ChatShadowPost$Response>> _chatShadowPost({
    @Body() required ChatShadowPost$RequestBody? body,
    @chopper.Tag()
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
  });

  ///
  Future<chopper.Response<ChatOptimizePost$Response>> chatOptimizePost({
    required ChatOptimizePost$RequestBody? body,
  }) {
    generatedMapping.putIfAbsent(
      ChatOptimizePost$Response,
      () => ChatOptimizePost$Response.fromJsonFactory,
    );

    return _chatOptimizePost(body: body);
  }

  ///
  @POST(path: '/chat/optimize', optionalBody: true)
  Future<chopper.Response<ChatOptimizePost$Response>> _chatOptimizePost({
    @Body() required ChatOptimizePost$RequestBody? body,
    @chopper.Tag()
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
  });

  ///
  Future<chopper.Response<ChatMessagesDelete$Response>> chatMessagesDelete({
    required ChatMessagesDelete$RequestBody? body,
  }) {
    generatedMapping.putIfAbsent(
      ChatMessagesDelete$Response,
      () => ChatMessagesDelete$Response.fromJsonFactory,
    );

    return _chatMessagesDelete(body: body);
  }

  ///
  @DELETE(path: '/chat/messages')
  Future<chopper.Response<ChatMessagesDelete$Response>> _chatMessagesDelete({
    @Body() required ChatMessagesDelete$RequestBody? body,
    @chopper.Tag()
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
  });

  ///
  Future<chopper.Response<UserSyncPost$Response>> userSyncPost({
    required UserSyncPost$RequestBody? body,
  }) {
    generatedMapping.putIfAbsent(
      UserSyncPost$Response,
      () => UserSyncPost$Response.fromJsonFactory,
    );

    return _userSyncPost(body: body);
  }

  ///
  @POST(path: '/user/sync', optionalBody: true)
  Future<chopper.Response<UserSyncPost$Response>> _userSyncPost({
    @Body() required UserSyncPost$RequestBody? body,
    @chopper.Tag()
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
  });

  ///
  Future<chopper.Response<ShadowingUpsertPut$Response>> shadowingUpsertPut({
    required ShadowingUpsertPut$RequestBody? body,
  }) {
    generatedMapping.putIfAbsent(
      ShadowingUpsertPut$Response,
      () => ShadowingUpsertPut$Response.fromJsonFactory,
    );

    return _shadowingUpsertPut(body: body);
  }

  ///
  @PUT(path: '/shadowing/upsert', optionalBody: true)
  Future<chopper.Response<ShadowingUpsertPut$Response>> _shadowingUpsertPut({
    @Body() required ShadowingUpsertPut$RequestBody? body,
    @chopper.Tag()
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
  });

  ///
  ///@param source_type
  ///@param source_id
  Future<chopper.Response<ShadowingGetGet$Response>> shadowingGetGet({
    required enums.ShadowingGetGetSourceType? sourceType,
    required String? sourceId,
  }) {
    generatedMapping.putIfAbsent(
      ShadowingGetGet$Response,
      () => ShadowingGetGet$Response.fromJsonFactory,
    );

    return _shadowingGetGet(
      sourceType: sourceType?.value?.toString(),
      sourceId: sourceId,
    );
  }

  ///
  ///@param source_type
  ///@param source_id
  @GET(path: '/shadowing/get')
  Future<chopper.Response<ShadowingGetGet$Response>> _shadowingGetGet({
    @Query('source_type') required String? sourceType,
    @Query('source_id') required String? sourceId,
    @chopper.Tag()
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
  });

  ///
  Future<chopper.Response<UserAccountDelete$Response>> userAccountDelete() {
    generatedMapping.putIfAbsent(
      UserAccountDelete$Response,
      () => UserAccountDelete$Response.fromJsonFactory,
    );

    return _userAccountDelete();
  }

  ///
  @DELETE(path: '/user/account')
  Future<chopper.Response<UserAccountDelete$Response>> _userAccountDelete({
    @chopper.Tag()
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
  });

  ///
  Future<chopper.Response<AdminStandardScenesGet$Response>>
  adminStandardScenesGet() {
    generatedMapping.putIfAbsent(
      AdminStandardScenesGet$Response,
      () => AdminStandardScenesGet$Response.fromJsonFactory,
    );

    return _adminStandardScenesGet();
  }

  ///
  @GET(path: '/admin/standard-scenes')
  Future<chopper.Response<AdminStandardScenesGet$Response>>
  _adminStandardScenesGet({
    @chopper.Tag()
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
  });

  ///
  Future<chopper.Response<AdminStandardScenesPost$Response>>
  adminStandardScenesPost({
    required AdminStandardScenesPost$RequestBody? body,
  }) {
    generatedMapping.putIfAbsent(
      AdminStandardScenesPost$Response,
      () => AdminStandardScenesPost$Response.fromJsonFactory,
    );

    return _adminStandardScenesPost(body: body);
  }

  ///
  @POST(path: '/admin/standard-scenes', optionalBody: true)
  Future<chopper.Response<AdminStandardScenesPost$Response>>
  _adminStandardScenesPost({
    @Body() required AdminStandardScenesPost$RequestBody? body,
    @chopper.Tag()
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
  });

  ///
  ///@param id
  Future<chopper.Response<AdminStandardScenesIdDelete$Response>>
  adminStandardScenesIdDelete({required String? id}) {
    generatedMapping.putIfAbsent(
      AdminStandardScenesIdDelete$Response,
      () => AdminStandardScenesIdDelete$Response.fromJsonFactory,
    );

    return _adminStandardScenesIdDelete(id: id);
  }

  ///
  ///@param id
  @DELETE(path: '/admin/standard-scenes/:id')
  Future<chopper.Response<AdminStandardScenesIdDelete$Response>>
  _adminStandardScenesIdDelete({
    @Path('id') required String? id,
    @chopper.Tag()
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
  });

  ///
  Future<chopper.Response<AdminPushTestPost$Response>> adminPushTestPost({
    required AdminPushTestPost$RequestBody? body,
  }) {
    generatedMapping.putIfAbsent(
      AdminPushTestPost$Response,
      () => AdminPushTestPost$Response.fromJsonFactory,
    );

    return _adminPushTestPost(body: body);
  }

  ///
  @POST(path: '/admin/push/test', optionalBody: true)
  Future<chopper.Response<AdminPushTestPost$Response>> _adminPushTestPost({
    @Body() required AdminPushTestPost$RequestBody? body,
    @chopper.Tag()
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
  });

  ///
  Future<chopper.Response<AdminPushStatusGet$Response>> adminPushStatusGet() {
    generatedMapping.putIfAbsent(
      AdminPushStatusGet$Response,
      () => AdminPushStatusGet$Response.fromJsonFactory,
    );

    return _adminPushStatusGet();
  }

  ///
  @GET(path: '/admin/push/status')
  Future<chopper.Response<AdminPushStatusGet$Response>> _adminPushStatusGet({
    @chopper.Tag()
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
  });
}

typedef $JsonFactory<T> = T Function(Map<String, dynamic> json);

class $CustomJsonDecoder {
  $CustomJsonDecoder(this.factories);

  final Map<Type, $JsonFactory> factories;

  dynamic decode<T>(dynamic entity) {
    if (entity is Iterable) {
      return _decodeList<T>(entity);
    }

    if (entity is T) {
      return entity;
    }

    if (isTypeOf<T, Map>()) {
      return entity;
    }

    if (isTypeOf<T, Iterable>()) {
      return entity;
    }

    if (entity is Map<String, dynamic>) {
      return _decodeMap<T>(entity);
    }

    return entity;
  }

  T _decodeMap<T>(Map<String, dynamic> values) {
    final jsonFactory = factories[T];
    if (jsonFactory == null || jsonFactory is! $JsonFactory<T>) {
      return throw "Could not find factory for type $T. Is '$T: $T.fromJsonFactory' included in the CustomJsonDecoder instance creation in bootstrapper.dart?";
    }

    return jsonFactory(values);
  }

  List<T> _decodeList<T>(Iterable values) =>
      values.where((v) => v != null).map<T>((v) => decode<T>(v) as T).toList();
}

class $JsonSerializableConverter extends chopper.JsonConverter {
  @override
  FutureOr<chopper.Response<ResultType>> convertResponse<ResultType, Item>(
    chopper.Response response,
  ) async {
    if (response.bodyString.isEmpty) {
      // In rare cases, when let's say 204 (no content) is returned -
      // we cannot decode the missing json with the result type specified
      return chopper.Response(response.base, null, error: response.error);
    }

    if (ResultType == String) {
      return response.copyWith();
    }

    if (ResultType == DateTime) {
      return response.copyWith(
        body:
            DateTime.parse((response.body as String).replaceAll('"', ''))
                as ResultType,
      );
    }

    final jsonRes = await super.convertResponse(response);
    return jsonRes.copyWith<ResultType>(
      body: $jsonDecoder.decode<Item>(jsonRes.body) as ResultType,
    );
  }
}

final $jsonDecoder = $CustomJsonDecoder(generatedMapping);
