import 'package:bloc/bloc.dart';

class TempCubit extends Cubit<String> {
  TempCubit() : super("0");

  void receive(String msg) => emit(msg);
}

class HumidCubit extends Cubit<String> {
  HumidCubit() : super("0");

  void receive(String msg) => emit(msg);
}

class MoistureCubit extends Cubit<String> {
  MoistureCubit() : super("0");

  void receive(String msg) => emit(msg);
}

class LightCubit extends Cubit<String> {
  LightCubit() : super("Off");

  void receive(String msg) => emit(msg);
}

class WaterCubit extends Cubit<String> {
  WaterCubit() : super("Off");

  void receive(String msg) => emit(msg);
}

class RoofCubit extends Cubit<String> {
  RoofCubit() : super("Closed");

  void receive(String msg) => emit(msg);
}

final TempCubit tempCubit = TempCubit();
final HumidCubit humidCubit = HumidCubit();
final MoistureCubit moistureCubit = MoistureCubit();
final LightCubit lightCubit = LightCubit();
final WaterCubit waterCubit = WaterCubit();
final RoofCubit roofCubit = RoofCubit();
