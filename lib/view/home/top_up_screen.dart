// ignore_for_file: deprecated_member_use

import 'package:finpay/config/textstyle.dart' hide HexColor;
import 'package:finpay/view/home/topup_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:finpay/controller/alumno/reserva_controller_alumno.dart';
import 'package:collection/collection.dart';
import 'package:finpay/controller/home_controller.dart';
import 'package:finpay/model/sitema_reservas.dart';
import 'package:hexcolor/hexcolor.dart';

class TopUpSCreen extends StatefulWidget {
  const TopUpSCreen({Key? key}) : super(key: key);

  @override
  State<TopUpSCreen> createState() => _TopUpSCreenState();
}

class _TopUpSCreenState extends State<TopUpSCreen> {
  late final ReservaAlumnoController controller;
  final isLoading = true.obs;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<ReservaAlumnoController>()) {
      Get.put(ReservaAlumnoController());
    }
    controller = Get.find<ReservaAlumnoController>();
    cargarReservas();
  }

  Future<void> cargarReservas() async {
    try {
      isLoading.value = true;
      await controller.cargarReservas();
      isLoading.value = false;
    } catch (e) {
      print('Error al cargar las reservas: $e');
      isLoading.value = false;
    }
  }

  Future<void> procesarPago(Reserva reserva) async {
    try {
      print('=== INICIO PROCESO DE PAGO ===');
      print('Reserva ID: ${reserva.codigoReserva}');
      print('Monto: ${reserva.monto}');
      print('Lugar: ${reserva.codigoLugar}');
      
      // Verificar que la reserva existe y está pendiente
      final reservas = await controller.db.getAll("reservas.json");
      print('Total reservas en sistema: ${reservas.length}');
      
      final reservaIndex = reservas.indexWhere((r) => r['codigoReserva'] == reserva.codigoReserva);
      print('Índice de la reserva encontrada: $reservaIndex');
      
      if (reservaIndex == -1) {
        print('ERROR: Reserva no encontrada en el sistema');
        throw Exception('No se encontró la reserva');
      }
      
      if (reservas[reservaIndex]['estadoReserva'] != 'PENDIENTE') {
        print('ERROR: Estado inválido - ${reservas[reservaIndex]['estadoReserva']}');
        throw Exception('La reserva ya ha sido pagada');
      }

      print('=== REGISTRANDO PAGO ===');
      final pagos = await controller.db.getAll("pagos.json");
      print('Total pagos existentes: ${pagos.length}');
      
      final nuevoPago = {
        'codigoPago': 'PAG-${DateTime.now().millisecondsSinceEpoch}',
        'codigoReservaAsociada': reserva.codigoReserva,
        'montoPagado': reserva.monto,
        'fechaPago': DateTime.now().toIso8601String(),
        'estado': 'PAGADO',
        'metodoPago': 'TARJETA',
        'clienteId': controller.codigoClienteActual.value,
      };
      
      print('Nuevo pago a registrar:');
      print('Código: ${nuevoPago['codigoPago']}');
      print('Monto: ${nuevoPago['montoPagado']}');
      print('Fecha: ${nuevoPago['fechaPago']}');
      
      pagos.add(nuevoPago);
      await controller.db.saveAll("pagos.json", pagos);
      print('Pago registrado exitosamente');

      print('=== ACTUALIZANDO RESERVA ===');
      reservas[reservaIndex]['estadoReserva'] = 'PAGADO';
      await controller.db.saveAll("reservas.json", reservas);
      print('Estado de reserva actualizado a PAGADO');

      print('=== LIBERANDO LUGAR ===');
      final lugares = await controller.db.getAll("lugares.json");
      final lugarIndex = lugares.indexWhere(
        (l) => l['codigoLugar'] == reserva.codigoLugar
      );
      
      if (lugarIndex != -1) {
        print('Estado anterior del lugar: ${lugares[lugarIndex]['estado']}');
        lugares[lugarIndex]['estado'] = "DISPONIBLE";
        await controller.db.saveAll("lugares.json", lugares);
        print('Lugar liberado exitosamente');
      } else {
        print('ADVERTENCIA: Lugar no encontrado en el sistema');
      }

      print('=== ACTUALIZANDO INTERFAZ ===');
      final homeController = Get.find<HomeController>();
      await homeController.cargarReservasPrevias();
      print('HomeController actualizado');

      print('Recargando reservas en el controlador actual...');
      await controller.cargarReservas();
      print('Reservas recargadas exitosamente');

      print('=== PROCESO DE PAGO COMPLETADO ===');
      
      // Manejo seguro de la navegación y mensajes
      await _manejarNavegacionExitoso();
      
    } catch (e, stackTrace) {
      print('=== ERROR EN PROCESO DE PAGO ===');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      
      // Manejo seguro de errores
      await _manejarError(e.toString());
    }
  }

  Future<void> _manejarNavegacionExitoso() async {
    try {
      // Cerrar diálogos de manera segura
      if (Get.isDialogOpen ?? false) {
        print('Cerrando diálogo de carga...');
        Get.back();
      }

      // Navegar de vuelta
      print('Navegando de vuelta a la pantalla anterior...');
      Get.back();

      // Esperar a que la navegación se complete
      await Future.delayed(const Duration(milliseconds: 300));

      // Mostrar mensaje de éxito
      print('Mostrando mensaje de éxito...');
      Get.snackbar(
        'Éxito',
        'Pago procesado correctamente y lugar liberado',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      print('=== PROCESO FINALIZADO ===');
    } catch (e) {
      print('Error en navegación exitosa: $e');
      // Intentar mostrar mensaje de error
      Get.snackbar(
        'Error',
        'Hubo un problema al finalizar el proceso',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  Future<void> _manejarError(String mensajeError) async {
    try {
      // Cerrar diálogos de manera segura
      if (Get.isDialogOpen ?? false) {
        print('Cerrando diálogo de carga...');
        Get.back();
      }

      // Esperar a que se cierre el diálogo
      await Future.delayed(const Duration(milliseconds: 300));

      // Mostrar mensaje de error
      print('Mostrando mensaje de error...');
      Get.snackbar(
        'Error',
        mensajeError.replaceAll('Exception: ', ''),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      print('Error al manejar el error: $e');
      // Último intento de mostrar mensaje
      try {
        Get.snackbar(
          'Error',
          'Ocurrió un error inesperado',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      } catch (_) {
        print('No se pudo mostrar ningún mensaje');
      }
    }
  }

  String formatearFecha(DateTime fecha) {
    return "${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}";
  }

  String formatearHora(DateTime fecha) {
    return "${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        print('Intentando volver atrás...');
        if (Get.isDialogOpen ?? false) {
          print('Cerrando diálogo abierto...');
          Get.back();
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: AppTheme.isLightTheme == false
            ? HexColor('#15141f')
            : HexColor(AppTheme.primaryColorString!),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
                child: Row(
                  children: [
                    InkWell(
                      focusColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                    ),
                    const Expanded(child: SizedBox()),
                    Text(
                      "Mis Reservas",
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const Expanded(child: SizedBox()),
                    const Icon(
                      Icons.arrow_back,
                      color: Colors.transparent,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 30),
                  decoration: BoxDecoration(
                    color: AppTheme.isLightTheme == false
                        ? const Color(0xff211F32)
                        : Theme.of(context).appBarTheme.backgroundColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Obx(() {
                    if (isLoading.value) {
                      print('Cargando reservas pendientes...');
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    final reservasPendientes = controller.reservasPrevias
                        .where((reserva) => reserva.estadoReserva == 'PENDIENTE')
                        .toList();
                    
                    print('Total reservas pendientes: ${reservasPendientes.length}');
                    print('Reservas pendientes:');
                    for (var reserva in reservasPendientes) {
                      print('- ${reserva.codigoReserva}: ${reserva.monto}');
                    }

                    if (reservasPendientes.isEmpty) {
                      print('No hay reservas pendientes de pago');
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long,
                              size: 64,
                              color: Colors.grey.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "No hay reservas pendientes de pago",
                              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                    color: Colors.grey.withOpacity(0.7),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: reservasPendientes.length,
                      itemBuilder: (context, index) {
                        final reserva = reservasPendientes[index];
                        return _buildReservaCard(context, reserva);
                      },
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReservaCard(BuildContext context, Reserva reserva) {
    // Buscar el lugar correspondiente
    final lugar = controller.lugaresDisponibles.firstWhereOrNull(
      (l) => l.codigoLugar == reserva.codigoLugar,
    );
    
    // Buscar el lugar en todos los pisos si no está en disponibles
    final lugarCompleto = lugar ?? controller.pisos.expand((p) => p.lugares).firstWhereOrNull(
      (l) => l.codigoLugar == reserva.codigoLugar,
    );

    // Buscar el auto correspondiente
    final auto = controller.autosCliente.firstWhereOrNull(
      (a) => a.chapa == reserva.chapaAuto,
    );
    
    final vehiculoStr = auto != null
      ? "${auto.marca} ${auto.modelo} (${auto.chapa})"
      : reserva.chapaAuto;
      
    final lugarStr = lugarCompleto != null
      ? "${lugarCompleto.codigoLugar} - ${lugarCompleto.descripcionLugar}"
      : "Lugar no encontrado";

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.isLightTheme == false
              ? const Color(0xff323045)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: HexColor(AppTheme.primaryColorString!).withOpacity(0.05),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.amber,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          reserva.estadoReserva,
                          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                color: Colors.amber,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        "₲${reserva.monto}",
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    context,
                    Icons.local_parking,
                    "Lugar",
                    lugarStr,
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    context,
                    Icons.calendar_today,
                    "Fecha",
                    formatearFecha(reserva.horarioInicio),
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    context,
                    Icons.access_time,
                    "Horario",
                    "${formatearHora(reserva.horarioInicio)} - ${formatearHora(reserva.horarioSalida)}",
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    context,
                    Icons.directions_car,
                    "Vehículo",
                    vehiculoStr,
                  ),
                ],
              ),
            ),
            Container(
              height: 1,
              color: HexColor(AppTheme.primaryColorString!).withOpacity(0.05),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _cancelarReserva(reserva),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                        minimumSize: const Size(120, 36),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        "Cancelar",
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _procesarPago(reserva),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: HexColor(AppTheme.primaryColorString!),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                        minimumSize: const Size(120, 36),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        "Pagar",
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _cancelarReserva(Reserva reserva) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Cancelar Reserva'),
        content: const Text('¿Está seguro que desea cancelar esta reserva?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Sí, Cancelar'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        Get.dialog(
          WillPopScope(
            onWillPop: () async => false,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          barrierDismissible: false,
        );

        final reservas = await controller.db.getAll("reservas.json");
        final index = reservas.indexWhere((r) => r['codigoReserva'] == reserva.codigoReserva);
        
        if (index != -1) {
          reservas.removeAt(index);
          await controller.db.saveAll("reservas.json", reservas);

          final lugares = await controller.db.getAll("lugares.json");
          final lugarIndex = lugares.indexWhere(
            (l) => l['codigoLugar'] == reserva.codigoLugar
          );
          
          if (lugarIndex != -1) {
            lugares[lugarIndex]['estado'] = "DISPONIBLE";
            await controller.db.saveAll("lugares.json", lugares);
          }

          final homeController = Get.find<HomeController>();
          await homeController.cargarReservasPrevias();
          await controller.cargarReservas();

          if (Get.isDialogOpen ?? false) {
            Get.back();
          }
          Get.back();

          Get.snackbar(
            'Éxito',
            'Reserva cancelada correctamente',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
        }
      } catch (e) {
        if (Get.isDialogOpen ?? false) {
          Get.back();
        }
        Get.snackbar(
          'Error',
          'No se pudo cancelar la reserva. Por favor, intente nuevamente.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    }
  }

  Future<void> _procesarPago(Reserva reserva) async {
    try {
      final result = await Get.bottomSheet(
        topupDialog(context, reserva: reserva),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
      );
      
      if (result == true) {
        Get.dialog(
          WillPopScope(
            onWillPop: () async => false,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          barrierDismissible: false,
        );
        
        try {
          await procesarPago(reserva);
          if (Get.isDialogOpen ?? false) {
            Get.back();
          }
          Get.back();
        } catch (e) {
          if (Get.isDialogOpen ?? false) {
            Get.back();
          }
          Get.snackbar(
            'Error',
            e.toString().replaceAll('Exception: ', ''),
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
        }
      }
    } catch (e) {
      print('Error al mostrar el diálogo de pago: $e');
      Get.snackbar(
        'Error',
        'No se pudo mostrar el diálogo de pago. Por favor, intente nuevamente.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: const Color(0xffA2A0A8),
          size: 16,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
            fontSize: 12,
                color: const Color(0xffA2A0A8),
              ),
        ),
        const Spacer(),
        Expanded(
          child: Text(
          value,
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
              fontSize: 12,
                fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
              ),
        ),
      ],
    );
  }
}
