import 'package:api_tutorial/models/CoffeeResponse.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'retrofit_client.g.dart';

@RestApi(baseUrl: 'https://fake-coffee-api.vercel.app/')
abstract class RetrofitClient {
  factory RetrofitClient(Dio dio, {String? baseUrl}) = _RetrofitClient;

  @GET('/api')
  Future<List<CoffeeResponse>> getCoffees();
}

final Dio dio = Dio();
final retrofitClient = RetrofitClient(dio);
