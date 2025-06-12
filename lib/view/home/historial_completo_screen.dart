import 'package:finpay/config/textstyle.dart';
import 'package:finpay/controller/home_controller.dart';
import 'package:finpay/utils/utiles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HistorialCompletoScreen extends StatelessWidget {
  final HomeController homeController;

  const HistorialCompletoScreen({Key? key, required this.homeController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.isLightTheme == false
          ? const Color(0xff15141F)
          : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Historial Completo",
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Obx(() {
          // Ordenar las reservas por fecha, las más recientes primero
          final reservasOrdenadas = homeController.reservasPrevias.toList()
            ..sort((a, b) => b.horarioInicio.compareTo(a.horarioInicio));

          return ListView.builder(
            itemCount: reservasOrdenadas.length,
            itemBuilder: (context, index) {
              final reserva = reservasOrdenadas[index];
              final estado = homeController.obtenerEstadoReserva(reserva);
              final colorEstado = homeController.obtenerColorEstado(estado);
              
              return FutureBuilder<String>(
                future: homeController.obtenerNombreAuto(reserva.chapaAuto),
                builder: (context, snapshot) {
                  final nombreAuto = snapshot.data ?? 'Cargando...';
                  
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    child: ListTile(
                      leading: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: HexColor(AppTheme.primaryColorString!).withOpacity(0.10),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.local_parking,
                          color: Colors.blue,
                        ),
                      ),
                      title: Text(
                        "$nombreAuto ${reserva.chapaAuto}",
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            "Fecha: ${UtilesApp.formatearFechaDdMMAaaa(reserva.horarioInicio)}",
                            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: colorEstado.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              estado,
                              style: TextStyle(
                                color: colorEstado,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      trailing: Text(
                        "₲${reserva.monto.toStringAsFixed(0)}",
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        }),
      ),
    );
  }
} 