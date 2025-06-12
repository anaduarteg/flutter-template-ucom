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
              
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppTheme.isLightTheme == false
                      ? const Color(0xff211F32)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xff000000).withOpacity(0.10),
                      blurRadius: 2,
                    ),
                  ],
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
                    "Reserva #${reserva.codigoReserva}",
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
                        UtilesApp.formatearFechaDdMMAaaa(reserva.horarioInicio),
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
                    "₲${UtilesApp.formatearGuaranies(reserva.monto)}",
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
} 