import 'dart:async';
import 'package:chopper/chopper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthInterceptor implements Interceptor {
  @override
  FutureOr<Response<BodyType>> intercept<BodyType>(
    Chain<BodyType> chain,
  ) async {
    final request = chain.request;

    // 1. Get current session
    final session = Supabase.instance.client.auth.currentSession;
    final token = session?.accessToken;

    // 2. Inject Authorization header if token exists
    if (token != null && token.isNotEmpty) {
      final modifiedRequest = request.copyWith(
        headers: {...request.headers, 'Authorization': 'Bearer $token'},
      );
      return chain.proceed(modifiedRequest);
    }

    // 3. Proceed with the request
    return chain.proceed(request);
  }
}
