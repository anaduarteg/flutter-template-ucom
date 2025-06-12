// ignore_for_file: deprecated_member_use

import 'package:finpay/api/local.db.service.dart';
import 'package:finpay/config/images.dart';
import 'package:finpay/config/textstyle.dart';
import 'package:finpay/model/sitema_reservas.dart';
import 'package:finpay/model/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  List<TransactionModel> transactionList = List<TransactionModel>.empty().obs;
  RxBool isWeek = true.obs;
  RxBool isMonth = false.obs;
  RxBool isYear = false.obs;
  RxBool isAdd = false.obs;
  RxList<Pago> pagosPrevios = <Pago>[].obs;
  RxList<Reserva> reservasPrevias = <Reserva>[].obs;

  @override
  void onInit() {
    super.onInit();
    customInit();
  }

  customInit() async {
    await cargarPagosPrevios();
    await cargarReservasPrevias();
    isWeek.value = true;
    isMonth.value = false;
    isYear.value = false;
    transactionList = [
      TransactionModel(
        Theme.of(Get.context!).textTheme.titleLarge!.color,
        DefaultImages.transaction4,
        "Apple Store",
        "iPhone 12 Case",
        "- \$120,90",
        "09:39 AM",
      ),
      TransactionModel(
        HexColor(AppTheme.primaryColorString!).withOpacity(0.10),
        DefaultImages.transaction3,
        "Ilya Vasil",
        "Wise • 5318",
        "- \$50,90",
        "05:39 AM",
      ),
      TransactionModel(
        Theme.of(Get.context!).textTheme.titleLarge!.color,
        "",
        "Burger King",
        "Cheeseburger XL",
        "- \$5,90",
        "09:39 AM",
      ),
      TransactionModel(
        HexColor(AppTheme.primaryColorString!).withOpacity(0.10),
        DefaultImages.transaction1,
        "Claudia Sarah",
        "Finpay Card • 5318",
        "- \$50,90",
        "04:39 AM",
      ),
    ];
  }

  Future<void> cargarPagosPrevios() async {
    final db = LocalDBService();
    final data = await db.getAll("pagos.json");
    pagosPrevios.value = data.map((json) => Pago.fromJson(json)).toList();
  }

  Future<void> cargarReservasPrevias() async {
    try {
      final db = LocalDBService();
      final data = await db.getAll("reservas.json");
      final reservas = data.map((json) => Reserva.fromJson(json)).toList();
      
      // Ordenar por fecha de inicio en orden descendente
      reservas.sort((a, b) => b.horarioInicio.compareTo(a.horarioInicio));
      
      reservasPrevias.value = reservas;
    } catch (e) {
      print("Error al cargar reservas previas: $e");
      reservasPrevias.value = [];
    }
  }

  String obtenerEstadoReserva(Reserva reserva) {
    return reserva.estadoReserva;
  }

  Color obtenerColorEstado(String estado) {
    switch (estado.toUpperCase()) {
      case 'PAGADO':
        return Colors.green;
      case 'PENDIENTE':
        return Colors.orange;
      case 'CANCELADA':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Método para actualizar las reservas desde otros controladores
  Future<void> actualizarReservas() async {
    await cargarReservasPrevias();
  }
}
