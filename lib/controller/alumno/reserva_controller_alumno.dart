import 'package:finpay/model/sitema_reservas.dart';
import 'package:get/get.dart';
import 'package:finpay/api/local.db.service.dart';
import 'package:flutter/material.dart';

class ReservaAlumnoController extends GetxController {
  final autoSeleccionado = Rxn<Auto>();
  final pisoSeleccionado = Rxn<Piso>();
  final lugarSeleccionado = Rxn<Lugar>();
  final horarioInicio = Rxn<DateTime>();
  final horarioSalida = Rxn<DateTime>();
  final duracionSeleccionada = 0.obs;
  final marcaSeleccionada = RxnString();
  final matriculaController = TextEditingController();
  final autosCliente = <Auto>[].obs;
  final pisos = <Piso>[].obs;
  final lugaresDisponibles = <Lugar>[].obs;
  final reservasPorDia = <DateTime, List<Reserva>>{}.obs;
  final db = LocalDBService();
  String codigoClienteActual =
      'cliente_1'; // ← este puede venir de login o contexto

  @override
  void onInit() {
    super.onInit();
    resetearCampos();
    cargarAutosDelCliente();
    cargarPisosYLugares();
    cargarReservas();
  }

  Future<void> cargarPisosYLugares() async {
    final rawPisos = await db.getAll("pisos.json");
    final rawLugares = await db.getAll("lugares.json");
    final rawReservas = await db.getAll("reservas.json");

    final reservas = rawReservas.map((e) => Reserva.fromJson(e)).toList();
    final lugaresReservados = reservas.map((r) => r.codigoReserva).toSet();

    final todosLugares = rawLugares.map((e) => Lugar.fromJson(e)).toList();

    // Unir pisos con sus lugares correspondientes
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

    // Inicializar lugares disponibles (solo los no reservados)
    lugaresDisponibles.value = todosLugares.where((l) {
      return !lugaresReservados.contains(l.codigoLugar);
    }).toList();
  }

  Future<void> cargarReservas() async {
    final rawReservas = await db.getAll("reservas.json");
    final reservas = rawReservas.map((e) => Reserva.fromJson(e)).toList();
    
    // Agrupar reservas por día
    for (var reserva in reservas) {
      final fecha = DateTime(
        reserva.horarioInicio.year,
        reserva.horarioInicio.month,
        reserva.horarioInicio.day,
      );
      
      if (!reservasPorDia.containsKey(fecha)) {
        reservasPorDia[fecha] = [];
      }
      reservasPorDia[fecha]!.add(reserva);
    }
  }

  List<Reserva> obtenerReservasDelDia(DateTime fecha) {
    final fechaNormalizada = DateTime(fecha.year, fecha.month, fecha.day);
    return reservasPorDia[fechaNormalizada] ?? [];
  }

  void seleccionarPiso(Piso piso) {
    pisoSeleccionado.value = piso;
    lugarSeleccionado.value = null;

    // filtrar lugares de este piso
    lugaresDisponibles.refresh();
  }

  Future<bool> confirmarReserva() async {
    if (autoSeleccionado.value == null ||
        pisoSeleccionado.value == null ||
        lugarSeleccionado.value == null ||
        horarioInicio.value == null ||
        horarioSalida.value == null) {
      return false;
    }

    final duracionEnHoras =
        horarioSalida.value!.difference(horarioInicio.value!).inMinutes / 60;

    if (duracionEnHoras <= 0) return false;

    final montoCalculado = (duracionEnHoras * 10000).roundToDouble();

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

      return true;
    } catch (e) {
      print("Error al guardar reserva: $e");
      return false;
    }
  }

  void actualizarVehiculoSeleccionado(String? marca) {
    marcaSeleccionada.value = marca;
    if (marca != null && matriculaController.text.isNotEmpty) {
      // Buscar si ya existe un auto con esta marca y matrícula
      final autoExistente = autosCliente.firstWhereOrNull(
        (auto) => auto.marca == marca && auto.chapa == matriculaController.text,
      );

      if (autoExistente != null) {
        autoSeleccionado.value = autoExistente;
      } else {
        // Crear un nuevo auto
        final nuevoAuto = Auto(
          chapa: matriculaController.text,
          marca: marca,
          modelo: "No especificado",
          clienteId: codigoClienteActual,
          chasis: "No especificado",
        );
        autoSeleccionado.value = nuevoAuto;
        autosCliente.add(nuevoAuto);
        // Guardar el nuevo auto en la base de datos
        guardarNuevoAuto(nuevoAuto);
      }
    }
  }

  void actualizarMatricula(String matricula) {
    if (marcaSeleccionada.value != null) {
      // Buscar si ya existe un auto con esta marca y matrícula
      final autoExistente = autosCliente.firstWhereOrNull(
        (auto) => auto.marca == marcaSeleccionada.value && auto.chapa == matricula,
      );

      if (autoExistente != null) {
        autoSeleccionado.value = autoExistente;
      } else {
        // Crear un nuevo auto
        final nuevoAuto = Auto(
          chapa: matricula,
          marca: marcaSeleccionada.value!,
          modelo: "No especificado",
          clienteId: codigoClienteActual,
          chasis: "No especificado",
        );
        autoSeleccionado.value = nuevoAuto;
        autosCliente.add(nuevoAuto);
        // Guardar el nuevo auto en la base de datos
        guardarNuevoAuto(nuevoAuto);
      }
    }
  }

  Future<void> guardarNuevoAuto(Auto auto) async {
    try {
      final autos = await db.getAll("autos.json");
      autos.add(auto.toJson());
      await db.saveAll("autos.json", autos);
    } catch (e) {
      print("Error al guardar nuevo auto: $e");
    }
  }

  Future<void> cargarAutosDelCliente() async {
    final rawAutos = await db.getAll("autos.json");
    final autos = rawAutos.map((e) => Auto.fromJson(e)).toList();

    autosCliente.value =
        autos.where((a) => a.clienteId == codigoClienteActual).toList();
  }

  @override
  void onClose() {
    resetearCampos();
    matriculaController.dispose();
    super.onClose();
  }

  void resetearCampos() {
    pisoSeleccionado.value = null;
    lugarSeleccionado.value = null;
    horarioInicio.value = null;
    horarioSalida.value = null;
    duracionSeleccionada.value = 0;
    marcaSeleccionada.value = null;
    matriculaController.clear();
    autoSeleccionado.value = null;
  }
}
