import 'package:app_tcc/app/data/http/exceptions.dart';
import 'package:app_tcc/app/data/models/local.dart';
import 'package:app_tcc/app/data/repositories/local_repository.dart';
import 'package:flutter/material.dart';

class LocalStore {
  final ILocalRepository repository;

  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<List<Local>> state =
  ValueNotifier<List<Local>>([]);
  final ValueNotifier<String> erro = ValueNotifier<String>('');

  LocalStore({required this.repository});

  Future getLocals() async {
    isLoading.value = true;

    try {
      final result = await repository.getLocals();
      state.value = result;
    } on NotFoundException catch (e) {
      erro.value = e.message;
    } catch (e) {
      erro.value = e.toString();
    }

    isLoading.value = false;
  }

  
  Future getLocalsByArea(String nome) async {
    isLoading.value = true;

    try {
      final result = await repository.getLocalsByArea(nome);
      state.value = result;
    } on NotFoundException catch (e) {
      erro.value = e.message;
    } catch (e) {
      erro.value = e.toString();
    }

    isLoading.value = false;
  } 
}