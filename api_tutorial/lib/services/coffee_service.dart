import 'package:chopper/chopper.dart';

import '../models/CoffeeResponse.dart';

part 'coffee_service.chopper.dart';

@ChopperApi(baseUrl: 'https://fake-coffee-api.vercel.app/api')
abstract class CoffeeListService extends ChopperService {
  static CoffeeListService create([ChopperClient? client]) =>
      _$CoffeeListService(client);

  @Get()
  Future<Response<List<CoffeeResponse>>> getCoffeesList();
}

final chopper = ChopperClient(
  services: [CoffeeListService.create()],
  converter: const JsonConverter(),
);
final coffeeService = chopper.getService<CoffeeListService>();
