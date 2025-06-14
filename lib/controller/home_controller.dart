// ignore_for_file: deprecated_member_use

import 'package:finpay/api/local.db.service.dart';
import 'package:finpay/config/images.dart';
import 'package:finpay/config/textstyle.dart';
import 'package:finpay/model/sitema_reservas.dart';
import 'package:finpay/model/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:finpay/controller/alumno/reserva_controller_alumno.dart';
import 'package:finpay/utils/utiles.dart';

class HomeController extends GetxController {
  List<TransactionModel> transactionList = List<TransactionModel>.empty().obs;
  RxBool isWeek = true.obs;
  RxBool isMonth = false.obs;
  RxBool isYear = false.obs;
  RxBool isAdd = false.obs;
  RxList<Pago> pagosPrevios = <Pago>[].obs;
  final reservasPrevias = <Reserva>[].obs;
  final db = LocalDBService();
  final transaccionesPendientes = 0.obs;
  final transaccionesCanceladas = 0.obs;
  final transaccionesPagadas = 0.obs;
  final mesActual = ''.obs;
  final autosCliente = <Auto>[].obs;
  final RxString codigoClienteActual = ''.obs;

  @override
  void onInit() {
    super.onInit();
    print('HomeController onInit: Inicializando...');

    if (Get.isRegistered<ReservaAlumnoController>()) {
      final reservaAlumnoController = Get.find<ReservaAlumnoController>();
      codigoClienteActual.value = reservaAlumnoController.codigoClienteActual.value;
    } else {
      print('ReservaAlumnoController no registrado. Usando cliente_1 por defecto.');
      codigoClienteActual.value = 'cliente_1';
    }
    print('HomeController onInit: codigoClienteActual: ${codigoClienteActual.value}');

    customInit();
    cargarReservasPrevias();
    actualizarReservas();
    ever(transaccionesPendientes, (_) => print("Pendientes cambiaron: ${transaccionesPendientes.value}"));
    ever(transaccionesCanceladas, (_) => print("Canceladas cambiaron: ${transaccionesCanceladas.value}"));
    ever(transaccionesPagadas, (_) => print("Pagadas cambiaron: ${transaccionesPagadas.value}"));
  }

  customInit() async {
    await cargarPagosPrevios();
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
    final data = await db.getAll("pagos.json");
    pagosPrevios.value = data.map((json) => Pago.fromJson(json)).toList();
  }

  Future<void> cargarReservasPrevias() async {
    print('=== INICIO CARGA DE RESERVAS PREVIAS ===');
    print('cargarReservasPrevias: codigoClienteActual: ${codigoClienteActual.value}');
    if (codigoClienteActual.value.isEmpty) {
      print('ERROR: codigoClienteActual está vacío en cargarReservasPrevias.');
      reservasPrevias.value = [];
      return;
    }
    try {
      final allReservas = await db.getAll("reservas.json");
      print('Total reservas cargadas (raw): ${allReservas.length}');
      print('Reservas raw: $allReservas');

      final allAutos = await db.getAll("autos.json");
      print('Autos raw: $allAutos');
      
      final autosCliente = allAutos.where((auto) {
        final autoClienteId = auto['clienteId'];
        print('  Evaluando auto: ${auto['chapa']} - clienteId en JSON: $autoClienteId (Tipo: ${autoClienteId.runtimeType})');
        print('  codigoClienteActual: ${codigoClienteActual.value} (Tipo: ${codigoClienteActual.value.runtimeType})');
        final match = (autoClienteId is String) && (autoClienteId == codigoClienteActual.value);
        print('  Coincidencia: $match');
        return match;
      }).toList();
      print('Autos del cliente (en cargarReservasPrevias): ${autosCliente.length}');
      print('Contenido de autosCliente (en cargarReservasPrevias): $autosCliente');
      
      if (autosCliente.isEmpty) {
        print('No se encontraron autos para el cliente en cargarReservasPrevias.');
        reservasPrevias.value = [];
        return;
      }
      
      // Obtener todas las chapas de los autos del cliente
      final chapasDeCliente = autosCliente.map((auto) => auto['chapa']).toSet();
      print('Chapas de todos los autos del cliente (en cargarReservasPrevias): $chapasDeCliente');

      // Filtrar reservas que pertenezcan a cualquiera de los autos del cliente
      final filteredReservas = allReservas.where((reserva) =>
        chapasDeCliente.contains(reserva['chapaAuto'])
      ).toList();
      print('Reservas filtradas por chapas de cliente (en cargarReservasPrevias): ${filteredReservas.length}');

      List<Reserva> parsedReservas = [];
      for (var json in filteredReservas) {
        try {
          parsedReservas.add(Reserva.fromJson(json));
        } catch (e) {
          print('Error parseando reserva en cargarReservasPrevias: $json. Error: $e');
        }
      }
      reservasPrevias.value = parsedReservas.toSet().toList();
      print('Total reservas convertidas a objetos: ${reservasPrevias.length}');
      actualizarReservas();
    } catch (e, stackTrace) {
      print('Error al cargar reservas previas: $e');
      print('Stack trace cargarReservasPrevias: $stackTrace');
    }
    print('=== CARGA DE RESERVAS PREVIAS COMPLETADA ===');
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
      final autos = await db.getAll("autos.json");
      final auto = autos.firstWhere(
        (a) => a['chapa'] == chapa,
        orElse: () => {'marca': 'Desconocido', 'modelo': 'Desconocido'},
      );
      return "${auto['marca']} ${auto['modelo']}";
    } catch (e) {
      print("Error al obtener nombre del auto: $e");
      return "Auto no encontrado";
    }
  }

  Future<String> obtenerPisoLugar(String codigoLugar) async {
    try {
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

  Future<void> actualizarReservas() async {
    try {
      print('=== INICIO ACTUALIZACIÓN DE RESERVAS ===');
      print('actualizarReservas: codigoClienteActual: ${codigoClienteActual.value}');
      if (codigoClienteActual.value.isEmpty) {
        print('ERROR: codigoClienteActual está vacío en actualizarReservas. Reiniciando contadores.');
        transaccionesPendientes.value = 0;
        transaccionesCanceladas.value = 0;
        transaccionesPagadas.value = 0;
        mesActual.value = ''; 
        return;
      }
      final fechaActual = DateTime.now();
      print('Fecha actual: $fechaActual');
      
      // Las reservas ya están en reservasPrevias como objetos Reserva
      final List<Reserva> reservasObj = reservasPrevias.toList(); 
      print('Total reservas en sistema (desde actualizarReservas): ${reservasObj.length}');
      
      // Obtener el primer auto del cliente
      final autos = await db.getAll("autos.json");
      print('Autos raw (en actualizarReservas): $autos');
      final autosCliente = autos.where((auto) {
        final autoClienteId = auto['clienteId'];
        print('  Evaluando auto (en actualizarReservas): ${auto['chapa']} - clienteId en JSON: $autoClienteId (Tipo: ${autoClienteId.runtimeType})');
        print('  codigoClienteActual: ${codigoClienteActual.value} (Tipo: ${codigoClienteActual.value.runtimeType})');
        final match = (autoClienteId is String) && (autoClienteId == codigoClienteActual.value);
        print('  Coincidencia: $match');
        return match;
      }).toList();
      print('Autos del cliente (en actualizarReservas - después del filtro): ${autosCliente.length}');
      print('Contenido de autosCliente (en actualizarReservas): $autosCliente');
      
      if (autosCliente.isEmpty) {
        print('No se encontraron autos para el cliente en actualizarReservas. Reiniciando contadores.');
        transaccionesPendientes.value = 0;
        transaccionesCanceladas.value = 0;
        transaccionesPagadas.value = 0;
        mesActual.value = ''; 
        return;
      }
      
      // No es necesario filtrar por un solo auto aquí, iteraremos sobre todas las reservas del cliente
      // final primerAuto = autosCliente.first;
      // final chapaPrimerAuto = primerAuto['chapa'];
      // print('Filtrando reservas para auto: $chapaPrimerAuto');
      
      // Obtener mes y año actual
      final mesActualNum = fechaActual.month; // Re-declarar mesActualNum
      final anioActual = fechaActual.year; // Re-declarar anioActual
      print('Período actual: $mesActualNum/$anioActual');

      // Reiniciar contadores locales
      int pendientes = 0;
      int canceladas = 0;
      int pagadas = 0;
      
      print('=== CONTANDO RESERVAS POR ESTADO ===');
      // Contar reservas por estado para el mes actual, para todos los autos del cliente
      final chapasDeCliente = autosCliente.map((auto) => auto['chapa']).toSet();
      print('Chapas de los autos del cliente: $chapasDeCliente');

      for (var reserva in reservasObj) {
        if (!chapasDeCliente.contains(reserva.chapaAuto)) {
          // Esta reserva no pertenece a un auto del cliente actual
          continue;
        }

        final fechaReserva = reserva.horarioInicio; // Ya es DateTime
        final mesReserva = fechaReserva.month;
        final anioReserva = fechaReserva.year;

        // Debugging de la fecha de la reserva
        print('  Evaluando reserva ${reserva.codigoReserva}: Fecha ${UtilesApp.formatearFechaDdMMAaaa(fechaReserva)}, Estado ${reserva.estadoReserva}'); // Usar UtilesApp.formatearFechaDdMMAaaa
        print('  Mes/Año Reserva: $mesReserva/$anioReserva. Mes/Año Actual: $mesActualNum/$anioActual');

        if (mesReserva == mesActualNum && anioReserva == anioActual) {
          final estado = reserva.estadoReserva.toUpperCase();
          print('  --> Contando: Reserva ${reserva.codigoReserva} - Estado: $estado. Monto: ${reserva.monto}');
          
          switch (estado) {
            case 'PENDIENTE':
              pendientes++;
              break;
            case 'CANCELADO':
            case 'CANCELADA':
              canceladas++;
              break;
            case 'PAGADO':
              pagadas++;
              break;
          }
        }
      }
      
      // Actualizar contadores observables
      transaccionesPendientes.value = pendientes;
      transaccionesCanceladas.value = canceladas;
      transaccionesPagadas.value = pagadas;
      
      // Actualizar el mes actual
      final meses = [
        'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
        'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
      ];
      mesActual.value = meses[mesActualNum - 1];
      
      print('=== RESUMEN DE CONTADORES ===');
      print('Pendientes: ${transaccionesPendientes.value}');
      print('Canceladas: ${transaccionesCanceladas.value}');
      print('Pagadas: ${transaccionesPagadas.value}');
      print('Total: ${transaccionesPendientes.value + transaccionesCanceladas.value + transaccionesPagadas.value}');
      print('Mes actual actualizado: ${mesActual.value}');
      print('=== ACTUALIZACIÓN COMPLETADA ===');
      
    } catch (e, stackTrace) {
      print('Error al actualizar reservas: $e');
      print('Stack trace: $stackTrace');
    }
  }

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

  List<Reserva> obtenerReservasPendientes() {
    return reservasPrevias.where((reserva) => reserva.estadoReserva == 'PENDIENTE').toList();
  }

  List<Reserva> obtenerReservasPagadas() {
    return reservasPrevias.where((reserva) => reserva.estadoReserva == 'PAGADO').toList();
  }

  void actualizarContadores() {
    final ahora = DateTime.now();
    mesActual.value = _obtenerNombreMes(ahora.month);
    
    final reservasDelMes = reservasPrevias.where((reserva) {
      return reserva.horarioInicio.year == ahora.year && 
             reserva.horarioInicio.month == ahora.month;
    }).toList();

    transaccionesPendientes.value = reservasDelMes
        .where((r) => r.estadoReserva == 'PENDIENTE')
        .length;
    
    transaccionesCanceladas.value = reservasDelMes
        .where((r) => r.estadoReserva == 'CANCELADO')
        .length;
    
    transaccionesPagadas.value = reservasDelMes
        .where((r) => r.estadoReserva == 'PAGADO')
        .length;
  }

  String _obtenerNombreMes(int mes) {
    final meses = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return meses[mes - 1];
  }
}
