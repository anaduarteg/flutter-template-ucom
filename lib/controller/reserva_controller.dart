import 'package:finpay/model/sitema_reservas.dart';
import 'package:get/get.dart';
import 'package:finpay/api/local.db.service.dart';
import 'package:finpay/controller/home_controller.dart';

class ReservaController extends GetxController {
  RxList<Piso> pisos = <Piso>[].obs;
  Rx<Piso?> pisoSeleccionado = Rx<Piso?>(null);
  RxList<Lugar> lugaresDisponibles = <Lugar>[].obs;
  Rx<Lugar?> lugarSeleccionado = Rx<Lugar?>(null);
  Rx<DateTime?> horarioInicio = Rx<DateTime?>(null);
  Rx<DateTime?> horarioSalida = Rx<DateTime?>(null);
  RxInt duracionSeleccionada = 0.obs;
  RxBool reservaConfirmada = false.obs;
  final db = LocalDBService();
  RxList<Auto> autosCliente = <Auto>[].obs;
  Rx<Auto?> autoSeleccionado = Rx<Auto?>(null);
  String codigoClienteActual =
      'cliente_1'; // ← este puede venir de login o contexto
  @override
  void onInit() {
    super.onInit();
    resetearCampos();
    cargarAutosDelCliente();
    cargarPisosYLugares();
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

  Future<void> seleccionarPiso(Piso piso) {
    pisoSeleccionado.value = piso;
    lugarSeleccionado.value = null;

    // filtrar lugares de este piso
    lugaresDisponibles.refresh();
    return Future.value();
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
      codigoLugar: lugarSeleccionado.value!.codigoLugar,
    );

    try {
      // Verificar si hay una reserva previa para este lugar
      final reservas = await db.getAll("reservas.json");
      final reservaPrevia = reservas.firstWhereOrNull(
        (r) => r['codigoLugar'] == lugarSeleccionado.value!.codigoLugar
      );

      if (reservaPrevia != null) {
        // Si la reserva previa está pagada, liberar el lugar
        if (reservaPrevia['estadoReserva'] == 'PAGADO') {
          final lugares = await db.getAll("lugares.json");
          final lugarIndex = lugares.indexWhere(
            (l) => l['codigoLugar'] == lugarSeleccionado.value!.codigoLugar
          );
          
          if (lugarIndex != -1) {
            lugares[lugarIndex]['estado'] = "DISPONIBLE";
            await db.saveAll("lugares.json", lugares);
          }
        }
      }

      // Guardar la nueva reserva
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
      final homeController = Get.find<HomeController>();
      await homeController.actualizarReservas();

      return true;
    } catch (e) {
      print("Error al guardar reserva: $e");
      return false;
    }
  }

  Future<void> registrarPagoPendiente(Reserva reserva) async {
    try {
      final pagos = await db.getAll("pagos.json");
      final nuevoPago = {
        'codigoPago': 'PAG-${DateTime.now().millisecondsSinceEpoch}',
        'codigoReservaAsociada': reserva.codigoReserva,
        'montoPagado': reserva.monto,
        'fechaPago': DateTime.now().toIso8601String(),
        'estado': 'PENDIENTE',
        'metodoPago': 'PENDIENTE',
        'clienteId': codigoClienteActual,
      };
      
      pagos.add(nuevoPago);
      await db.saveAll("pagos.json", pagos);
    } catch (e) {
      print("Error al registrar pago pendiente: $e");
      throw e;
    }
  }

  Future<bool> cancelarReservaExistente(String codigoReserva) async {
    try {
      // Obtener todas las reservas
      final reservas = await db.getAll("reservas.json");
      
      // Encontrar la reserva a cancelar
      final reservaIndex = reservas.indexWhere(
        (r) => r['codigoReserva'] == codigoReserva
      );
      
      if (reservaIndex == -1) return false;
      
      // Obtener el código del lugar de la reserva
      final codigoLugar = reservas[reservaIndex]['codigoLugar'];
      final estadoReserva = reservas[reservaIndex]['estadoReserva'];
      
      // Actualizar el estado de la reserva
      reservas[reservaIndex]['estadoReserva'] = 'CANCELADA';
      await db.saveAll("reservas.json", reservas);
      
      // Liberar el lugar de estacionamiento si la reserva estaba pagada
      if (estadoReserva == 'PAGADO') {
        final lugares = await db.getAll("lugares.json");
        final lugarIndex = lugares.indexWhere(
          (l) => l['codigoLugar'] == codigoLugar
        );
        
        if (lugarIndex != -1) {
          lugares[lugarIndex]['estado'] = "DISPONIBLE";
          await db.saveAll("lugares.json", lugares);
        }
      }

      // Eliminar el pago pendiente
      await eliminarPagoPendiente(codigoReserva);
      
      return true;
    } catch (e) {
      print("Error al cancelar reserva: $e");
      return false;
    }
  }

  Future<void> eliminarPagoPendiente(String codigoReserva) async {
    try {
      final pagos = await db.getAll("pagos.json");
      final pagosFiltrados = pagos.where((p) => 
        p['codigoReservaAsociada'] == codigoReserva && 
        p['estado'] == 'PENDIENTE'
      ).toList();

      for (var pago in pagosFiltrados) {
        pagos.remove(pago);
      }

      await db.saveAll("pagos.json", pagos);
    } catch (e) {
      print("Error al eliminar pago pendiente: $e");
      throw e;
    }
  }

  Future<void> cancelarReserva() async {
    try {
      // Si hay un lugar seleccionado, liberarlo
      if (lugarSeleccionado.value != null) {
        final lugares = await db.getAll("lugares.json");
        final lugarIndex = lugares.indexWhere(
          (l) => l['codigoLugar'] == lugarSeleccionado.value!.codigoLugar
        );
        
        if (lugarIndex != -1) {
          lugares[lugarIndex]['estado'] = "DISPONIBLE";
          await db.saveAll("lugares.json", lugares);
        }
      }

      // Resetear todos los campos
      resetearCampos();
      
      // Recargar los lugares disponibles
      await cargarPisosYLugares();
    } catch (e) {
      print("Error al cancelar reserva: $e");
    }
  }

  void resetearCampos() {
    pisoSeleccionado.value = null;
    lugarSeleccionado.value = null;
    horarioInicio.value = null;
    horarioSalida.value = null;
    duracionSeleccionada.value = 0;
    autoSeleccionado.value = null;
    reservaConfirmada.value = false;
  }

  Future<void> cargarAutosDelCliente() async {
    final rawAutos = await db.getAll("autos.json");
    final autos = rawAutos.map((e) => Auto.fromJson(e)).toList();

    autosCliente.value =
        autos.where((a) => a.clienteId == codigoClienteActual).toList();
  }

  void limpiarReservaActual() {
    // Limpiar todas las selecciones usando .value para asegurar la reactividad
    pisoSeleccionado.value = null;
    lugarSeleccionado.value = null;
    horarioInicio.value = null;
    horarioSalida.value = null;
    duracionSeleccionada.value = 0;
    autoSeleccionado.value = null;
    
    // Forzar la actualización de la lista de lugares disponibles
    lugaresDisponibles.refresh();
  }

  void limpiarDatos() {
    pisoSeleccionado.value = null;
    lugarSeleccionado.value = null;
    horarioInicio.value = null;
    horarioSalida.value = null;
    duracionSeleccionada.value = 0;
    autoSeleccionado.value = null;
  }

  @override
  void onClose() {
    resetearCampos();
    super.onClose();
  }
}
