import 'package:finpay/model/sitema_reservas.dart';
import 'package:get/get.dart';
import 'package:finpay/api/local.db.service.dart';
import 'package:flutter/material.dart';
import 'package:finpay/controller/home_controller.dart';

class ReservaAlumnoController extends GetxController {
  final autoSeleccionado = Rxn<Auto>();
  final pisoSeleccionado = Rxn<Piso>();
  final lugarSeleccionado = Rxn<Lugar>();
  final horarioInicio = Rxn<DateTime>();
  final horarioSalida = Rxn<DateTime>();
  final duracionSeleccionada = 0.obs;
  final autosCliente = <Auto>[].obs;
  final pisos = <Piso>[].obs;
  final lugaresDisponibles = <Lugar>[].obs;
  final reservasPorDia = <DateTime, List<Reserva>>{}.obs;
  final db = LocalDBService();
  String codigoClienteActual = 'cliente_1';
  late final HomeController homeController;
  final reservaConfirmada = false.obs;
  final reservasPrevias = <Reserva>[].obs;

  @override
  void onInit() {
    super.onInit();
    homeController = Get.find<HomeController>();
    resetearCampos();
    cargarAutosDelCliente();
    cargarPisosYLugares();
    cargarReservas();
  }

  Future<void> cargarAutosDelCliente() async {
    try {
      final rawAutos = await db.getAll("autos.json");
      autosCliente.value = rawAutos.map((json) => Auto.fromJson(json)).toList();
    } catch (e) {
      print("Error al cargar autos: $e");
      autosCliente.value = [];
    }
  }

  Future<void> cargarPisosYLugares() async {
    try {
      final rawPisos = await db.getAll("pisos.json");
      final rawLugares = await db.getAll("lugares.json");
      final rawReservas = await db.getAll("reservas.json");

      final reservas = rawReservas.map((e) => Reserva.fromJson(e)).toList();
      final lugaresReservados = reservas.map((r) => r.codigoReserva).toSet();

      final todosLugares = rawLugares.map((e) => Lugar.fromJson(e)).toList();

      // Cargar pisos
      pisos.value = rawPisos.map((pJson) {
        final codigoPiso = pJson['codigo'];
        final lugaresDelPiso =
            todosLugares.where((l) => l.codigoPiso == codigoPiso).toList();

        return Piso(
          codigo: codigoPiso,
          descripcion: pJson['descripcion'],
          lugares: lugaresDelPiso,
        );
      }).toList();

      // Cargar lugares disponibles
      lugaresDisponibles.value = todosLugares.where((l) {
        return !lugaresReservados.contains(l.codigoLugar);
      }).toList();
    } catch (e) {
      print("Error al cargar pisos y lugares: $e");
      pisos.value = [];
      lugaresDisponibles.value = [];
    }
  }

  Future<void> cargarReservas() async {
    try {
      final reservasJson = await db.getAll("reservas.json");
      final reservas = reservasJson
          .map((r) => Reserva.fromJson(r))
          .where((r) => r.chapaAuto == autosCliente.firstOrNull?.chapa)
          .toList();

      // Actualizar reservasPrevias
      reservasPrevias.value = reservas;

      // Agrupar por día
      final reservasPorDiaMap = <DateTime, List<Reserva>>{};
      for (var reserva in reservas) {
        final fecha = DateTime(
          reserva.horarioInicio.year,
          reserva.horarioInicio.month,
          reserva.horarioInicio.day,
        );
        if (!reservasPorDiaMap.containsKey(fecha)) {
          reservasPorDiaMap[fecha] = [];
        }
        reservasPorDiaMap[fecha]!.add(reserva);
      }
      reservasPorDia.value = reservasPorDiaMap;
    } catch (e) {
      print('Error al cargar reservas: $e');
    }
  }

  List<Reserva> obtenerReservasDelDia(DateTime fecha) {
    final fechaNormalizada = DateTime(fecha.year, fecha.month, fecha.day);
    return reservasPorDia[fechaNormalizada] ?? [];
  }

  void seleccionarPiso(Piso piso) {
    pisoSeleccionado.value = piso;
    lugarSeleccionado.value = null;
    lugaresDisponibles.refresh();
  }

  void seleccionarLugar(Lugar lugar) {
    if (lugar.estado == "DISPONIBLE") {
      lugarSeleccionado.value = lugar;
    }
  }

  Future<bool> confirmarReserva() async {
    if (pisoSeleccionado.value == null ||
        lugarSeleccionado.value == null ||
        horarioInicio.value == null ||
        horarioSalida.value == null) {
      return false;
    }

    final duracionEnHoras =
        horarioSalida.value!.difference(horarioInicio.value!).inMinutes / 60;

    if (duracionEnHoras <= 0) return false;

    final montoCalculado = (duracionEnHoras * 10000).roundToDouble();

    if (autoSeleccionado.value == null) return false;

    final nuevaReserva = Reserva(
      codigoReserva: "RES-${DateTime.now().millisecondsSinceEpoch}",
      horarioInicio: horarioInicio.value!,
      horarioSalida: horarioSalida.value!,
      monto: montoCalculado,
      estadoReserva: "PENDIENTE",
      chapaAuto: autoSeleccionado.value!.chapa,
    );

    try {
      // Guardar la reserva
      final reservas = await db.getAll("reservas.json");
      reservas.add(nuevaReserva.toJson());
      await db.saveAll("reservas.json", reservas);

      // Marcar el lugar como reservado
      final lugares = await db.getAll("lugares.json");
      final index = lugares.indexWhere(
        (l) => l['codigoLugar'] == lugarSeleccionado.value!.codigoLugar,
      );
      if (index != -1) {
        lugares[index]['estado'] = "RESERVADO";
        await db.saveAll("lugares.json", lugares);
      }
      
      // Marcar la reserva como confirmada
      reservaConfirmada.value = true;

      // Actualizar el HomeController
      await homeController.actualizarReservas();

      return true;
    } catch (e) {
      print("Error al guardar reserva: $e");
      return false;
    }
  }

  void resetearCampos() {
    pisoSeleccionado.value = null;
    lugarSeleccionado.value = null;
    horarioInicio.value = null;
    horarioSalida.value = null;
    duracionSeleccionada.value = 0;
    autoSeleccionado.value = null;
  }
}
