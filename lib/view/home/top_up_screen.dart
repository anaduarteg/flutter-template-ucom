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
      // Verificar que la reserva existe y está pendiente
      final reservas = await controller.db.getAll("reservas.json");
      final reservaIndex = reservas.indexWhere((r) => r['codigoReserva'] == reserva.codigoReserva);
      
      if (reservaIndex == -1) {
        throw Exception('No se encontró la reserva');
      }
      
      if (reservas[reservaIndex]['estadoReserva'] != 'PENDIENTE') {
        throw Exception('La reserva ya ha sido pagada');
      }

      // Registrar el pago
      final pagos = await controller.db.getAll("pagos.json");
      final nuevoPago = {
        'codigoPago': 'PAG-${DateTime.now().millisecondsSinceEpoch}',
        'codigoReservaAsociada': reserva.codigoReserva,
        'montoPagado': reserva.monto,
        'fechaPago': DateTime.now().toIso8601String(),
        'estado': 'PAGADO',
        'metodoPago': 'TARJETA',
        'clienteId': controller.codigoClienteActual,
      };
      
      pagos.add(nuevoPago);
      await controller.db.saveAll("pagos.json", pagos);

      // Actualizar el estado de la reserva
      reservas[reservaIndex]['estadoReserva'] = 'PAGADO';
        await controller.db.saveAll("reservas.json", reservas);

      // Liberar el lugar de estacionamiento
      final lugares = await controller.db.getAll("lugares.json");
      final lugarIndex = lugares.indexWhere(
        (l) => l['codigoLugar'] == reserva.codigoLugar
      );
      
      if (lugarIndex != -1) {
        lugares[lugarIndex]['estado'] = "DISPONIBLE";
        await controller.db.saveAll("lugares.json", lugares);
      }

      // Actualizar el HomeController
      final homeController = Get.find<HomeController>();
      await homeController.cargarReservasPrevias();

      // Recargar las reservas en el controlador actual
      await controller.cargarReservas();

      // Mostrar mensaje de éxito
      Get.snackbar(
        'Éxito',
        'Pago procesado correctamente y lugar liberado',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      print('Error al procesar el pago: $e');
      throw Exception('Error al procesar el pago: $e');
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
    return Scaffold(
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
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                // Obtener todas las reservas pendientes sin duplicados
                final reservasPendientes = controller.reservasPrevias
                    .where((reserva) => reserva.estadoReserva == 'PENDIENTE')
                    .toList();

                if (reservasPendientes.isEmpty) {
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
                                        onPressed: () async {
                                          // Mostrar diálogo de confirmación
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
                                            // Mostrar indicador de carga
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
                                              // Eliminar la reserva
                                              final reservas = await controller.db.getAll("reservas.json");
                                              final index = reservas.indexWhere((r) => r['codigoReserva'] == reserva.codigoReserva);
                                              
                                              if (index != -1) {
                                                reservas.removeAt(index);
                                                await controller.db.saveAll("reservas.json", reservas);

                                                // Liberar el lugar
                                                final lugares = await controller.db.getAll("lugares.json");
                                                final lugarIndex = lugares.indexWhere(
                                                  (l) => l['codigoLugar'] == reserva.codigoLugar
                                                );
                                                
                                                if (lugarIndex != -1) {
                                                  lugares[lugarIndex]['estado'] = "DISPONIBLE";
                                                  await controller.db.saveAll("lugares.json", lugares);
                                                }

                                                // Actualizar el HomeController
                                                final homeController = Get.find<HomeController>();
                                                await homeController.cargarReservasPrevias();

                                                // Recargar las reservas en el controlador actual
                                                await controller.cargarReservas();

                                                if (Get.isDialogOpen ?? false) {
                                                  Get.back(); // Cerrar el indicador de carga
                                                }
                                                Get.back(); // Cerrar la pantalla de pagos

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
                                                Get.back(); // Cerrar el indicador de carga
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
                                      },
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
                                        onPressed: () async {
                                          try {
                                            final result = await Get.bottomSheet(
                                              topupDialog(context, reserva: reserva),
                                              isScrollControlled: true,
                                              backgroundColor: Colors.transparent,
                                            );
                                            
                                            if (result == true) {
                                              // Mostrar indicador de carga
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
                                                  Get.back(); // Cerrar el indicador de carga
                                                }
                                                Get.back(); // Cerrar la pantalla de pagos
                                              } catch (e) {
                                                if (Get.isDialogOpen ?? false) {
                                                  Get.back(); // Cerrar el indicador de carga
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
                                        },
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
                  },
                );
              }),
            ),
          ),
        ],
        ),
      ),
    );
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
