// ignore_for_file: deprecated_member_use

import 'package:finpay/config/images.dart';
import 'package:finpay/config/textstyle.dart';
import 'package:finpay/view/home/topup_dialog.dart';
import 'package:finpay/view/home/widget/amount_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:swipe/swipe.dart';
import 'package:finpay/controller/alumno/reserva_controller_alumno.dart';
import 'package:collection/collection.dart';

class TopUpSCreen extends StatefulWidget {
  const TopUpSCreen({Key? key}) : super(key: key);

  @override
  State<TopUpSCreen> createState() => _TopUpSCreenState();
}

class _TopUpSCreenState extends State<TopUpSCreen> {
  final controller = Get.find<ReservaAlumnoController>();
  final isLoading = true.obs;

  @override
  void initState() {
    super.initState();
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
      body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 50),
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

                final reservasPendientes = controller.reservasPorDia.values
                    .expand((reservas) => reservas)
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
                      (l) => l.codigoLugar == reserva.codigoReserva,
                    );
                    // Buscar el lugar en todos los pisos si no está en disponibles
                    final lugarCompleto = lugar ?? controller.pisos.expand((p) => p.lugares).firstWhereOrNull(
                      (l) => l.codigoLugar == reserva.codigoReserva,
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
                      : reserva.codigoReserva;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppTheme.isLightTheme == false
                                      ? const Color(0xff323045)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                            color: HexColor(AppTheme.primaryColorString!)
                                            .withOpacity(0.05),
                                    width: 2,
                                  ),
                                ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                      ),
                                        decoration: BoxDecoration(
                                          color: Colors.amber.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: Colors.amber,
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          reserva.estadoReserva,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .copyWith(
                                                color: Colors.amber,
                                                fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        "₲${reserva.monto}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge!
                                            .copyWith(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w800,
                                            ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  _buildInfoRow(
                                    context,
                                    Icons.local_parking,
                                    "Lugar",
                                    lugarStr,
                                  ),
                                  const SizedBox(height: 12),
                                  _buildInfoRow(
                                    context,
                                    Icons.calendar_today,
                                    "Fecha",
                                    formatearFecha(reserva.horarioInicio),
                                  ),
                                  const SizedBox(height: 12),
                                  _buildInfoRow(
                                    context,
                                    Icons.access_time,
                                    "Horario",
                                    "${formatearHora(reserva.horarioInicio)} - ${formatearHora(reserva.horarioSalida)}",
                      ),
                                  const SizedBox(height: 12),
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
                              color: HexColor(AppTheme.primaryColorString!)
                                  .withOpacity(0.05),
          ),
          Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                Get.bottomSheet(
                  topupDialog(context),
                );
              },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            HexColor(AppTheme.primaryColorString!),
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: Text(
                                        "Pagar Ahora",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .copyWith(
                                              fontSize: 14,
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
          size: 20,
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                fontSize: 14,
                color: const Color(0xffA2A0A8),
              ),
        ),
        const Spacer(),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
