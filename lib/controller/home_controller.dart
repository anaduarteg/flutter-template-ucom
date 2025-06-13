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
      
      // Obtener el auto del cliente actual
      final autos = await db.getAll("autos.json");
      final autoCliente = autos.firstWhere(
        (a) => a['clienteId'] == 'cliente_1', // ID del cliente actual
        orElse: () => {'chapa': ''},
      );
      final chapaAuto = autoCliente['chapa'] as String;
      
      // Filtrar reservas por la chapa del auto del cliente
      final reservas = data
          .map((json) => Reserva.fromJson(json))
          .where((r) => r.chapaAuto == chapaAuto)
          .toList();
      
      // Ordenar por fecha de inicio en orden descendente
      reservas.sort((a, b) => b.horarioInicio.compareTo(a.horarioInicio));
      
      reservasPrevias.value = reservas;
    } catch (e) {
      print("Error al cargar reservas previas: $e");
      reservasPrevias.value = [];
    }
  }

  String obtenerEstadoReserva(Reserva reserva) {
    if (reserva.estadoReserva == 'PAGADO') {
      return 'PAGADO';
    } else if (reserva.estadoReserva == 'CANCELADA') {
      return 'CANCELADA';
    } else {
      return 'PENDIENTE';
    }
  }

  Color obtenerColorEstado(String estado) {
    switch (estado) {
      case 'PAGADO':
        return Colors.green;
      case 'CANCELADA':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  Future<String> obtenerNombreAuto(String chapa) async {
    try {
      final db = LocalDBService();
      final autos = await db.getAll("autos.json");
      final auto = autos.firstWhere(
        (a) => a['chapa'] == chapa,
        orElse: () => {'marca': 'Auto no encontrado'},
      );
      return auto['marca'] ?? 'Auto no encontrado';
    } catch (e) {
      print('Error al obtener marca del auto: $e');
      return 'Auto no encontrado';
    }
  }

  Future<String> obtenerPisoLugar(String codigoLugar) async {
    try {
      final db = LocalDBService();
      final lugares = await db.getAll("lugares.json");
      final lugar = lugares.firstWhere(
        (l) => l['codigoLugar'] == codigoLugar,
        orElse: () => {'piso': 'Piso no encontrado'},
      );
      final numeroPiso = lugar['piso'] ?? '0';
      return "Piso $numeroPiso";
    } catch (e) {
      print('Error al obtener piso del lugar: $e');
      return 'Piso no encontrado';
    }
  }

  // Método para actualizar las reservas desde otros controladores
  Future<void> actualizarReservas() async {
    await cargarReservasPrevias();
  }

  // Método para obtener la cantidad de pagos del mes actual
  int obtenerPagosDelMesActual() {
    final ahora = DateTime.now();
    final inicioMes = DateTime(ahora.year, ahora.month, 1);
    final finMes = DateTime(ahora.year, ahora.month + 1, 0);

    return reservasPrevias.where((reserva) {
      return reserva.estadoReserva == 'PAGADO' &&
          reserva.horarioInicio.isAfter(inicioMes) &&
          reserva.horarioInicio.isBefore(finMes.add(const Duration(days: 1)));
    }).length;
  }
}
