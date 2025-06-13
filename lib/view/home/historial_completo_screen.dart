import 'package:finpay/config/textstyle.dart';
import 'package:finpay/controller/home_controller.dart';
import 'package:finpay/model/sitema_reservas.dart';
import 'package:finpay/utils/utiles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HistorialCompletoScreen extends StatefulWidget {
  final HomeController homeController;

  const HistorialCompletoScreen({
    Key? key,
    required this.homeController,
  }) : super(key: key);

  @override
  State<HistorialCompletoScreen> createState() => _HistorialCompletoScreenState();
}

class _HistorialCompletoScreenState extends State<HistorialCompletoScreen> {
  String? mesSeleccionado;
  bool mostrarOtros = false;
  List<String> ultimosMeses = [];
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    _obtenerUltimosMeses();
  }

  void _obtenerUltimosMeses() {
    final ahora = DateTime.now();
    final meses = <String>[];
    
    for (int i = 0; i < 10; i++) {
      final mes = DateTime(ahora.year, ahora.month - i, 1);
      final nombreMes = UtilesApp.formatearFechaMMMMYYYY(mes);
      meses.add(nombreMes);
    }
    
    setState(() {
      ultimosMeses = meses;
      mesSeleccionado = meses.first;
    });
  }

  Map<String, List<Reserva>> agruparReservasPorMes() {
    final Map<String, List<Reserva>> resultado = {};
    
    // Inicializar todos los meses con listas vacías
    for (final mes in ultimosMeses) {
      resultado[mes] = [];
    }
    
    // Agrupar las reservas existentes
    for (final reserva in widget.homeController.reservasPrevias) {
      final mes = UtilesApp.formatearFechaMMMMYYYY(reserva.horarioInicio);
      if (resultado.containsKey(mes)) {
        resultado[mes]!.add(reserva);
      }
    }
    
    return resultado;
  }

  @override
  Widget build(BuildContext context) {
    final reservasPorMes = agruparReservasPorMes();
    
    return Scaffold(
      backgroundColor: AppTheme.isLightTheme ? Colors.grey[50] : const Color(0xff15141F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).textTheme.bodyLarge?.color,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Historial de Pagos",
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                children: [
                  Container(
                    height: 65,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      children: [
                        ...ultimosMeses.take(3).map((mes) {
                          final reservas = reservasPorMes[mes]!;
                          final isSelected = mesSeleccionado == mes;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                mesSeleccionado = mes;
                                mostrarOtros = false;
                                isExpanded = false;
                              });
                            },
                            child: Container(
                              width: 95,
                              margin: const EdgeInsets.only(right: 4),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Theme.of(context).primaryColor
                                    : AppTheme.isLightTheme
                                        ? Colors.white
                                        : const Color(0xff211F32),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: isSelected
                                        ? Theme.of(context).primaryColor.withOpacity(0.2)
                                        : Colors.black.withOpacity(0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      mes.split(' ')[0],
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 1),
                                    Text(
                                      reservas.isEmpty ? "Sin pagos" : "₲${reservas.fold<double>(0, (sum, reserva) => sum + reserva.monto).toStringAsFixed(0)}",
                                      style: TextStyle(
                                        color: isSelected ? Colors.white.withOpacity(0.9) : Theme.of(context).primaryColor,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              mostrarOtros = true;
                              mesSeleccionado = null;
                              isExpanded = !isExpanded;
                            });
                          },
                          child: Container(
                            width: 95,
                            margin: const EdgeInsets.only(right: 4),
                            decoration: BoxDecoration(
                              color: mostrarOtros
                                  ? Theme.of(context).primaryColor
                                  : AppTheme.isLightTheme
                                      ? Colors.white
                                      : const Color(0xff211F32),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: mostrarOtros
                                      ? Theme.of(context).primaryColor.withOpacity(0.2)
                                      : Colors.black.withOpacity(0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        color: mostrarOtros ? Colors.white : Theme.of(context).primaryColor,
                                        size: 13,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        "Otros",
                                        style: TextStyle(
                                          color: mostrarOtros ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    "${reservasPorMes.values.fold<int>(0, (sum, reservas) => sum + reservas.length)} pagos",
                                    style: TextStyle(
                                      color: mostrarOtros ? Colors.white.withOpacity(0.9) : Theme.of(context).primaryColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isExpanded)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.isLightTheme ? Colors.white : const Color(0xff211F32),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: ultimosMeses.skip(3).map((mes) {
                          final reservas = reservasPorMes[mes]!;
                          final isSelected = mesSeleccionado == mes;

                          return InkWell(
                            onTap: () {
                              setState(() {
                                mesSeleccionado = mes;
                                mostrarOtros = false;
                                isExpanded = false;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.grey.withOpacity(0.1),
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    mes,
                                    style: TextStyle(
                                      color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyLarge?.color,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        "${reservas.length} pagos",
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 11,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        reservas.isEmpty ? "Sin pagos" : "₲${reservas.fold<double>(0, (sum, reserva) => sum + reserva.monto).toStringAsFixed(0)}",
                                        style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: mesSeleccionado != null
                  ? ListView.builder(
                      padding: const EdgeInsets.only(
                        left: 4,
                        right: 4,
                        top: 2,
                        bottom: 4,
                      ),
                      itemCount: reservasPorMes[mesSeleccionado]!.length,
                      itemBuilder: (context, index) {
                        final reserva = reservasPorMes[mesSeleccionado]![index];
                        final estado = widget.homeController.obtenerEstadoReserva(reserva);
                        final colorEstado = widget.homeController.obtenerColorEstado(estado);

                        return FutureBuilder<String>(
                          future: widget.homeController.obtenerNombreAuto(reserva.chapaAuto),
                          builder: (context, snapshot) {
                            final nombreAuto = snapshot.data ?? 'Cargando...';
                            
                            return Container(
                              margin: const EdgeInsets.fromLTRB(6, 0, 6, 3),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.isLightTheme ? Colors.grey[50] : const Color(0xff323045),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Icon(
                                      Icons.local_parking,
                                      color: Theme.of(context).primaryColor,
                                      size: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "$nombreAuto ${reserva.chapaAuto}",
                                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 11,
                                              ),
                                        ),
                                        Text(
                                          UtilesApp.formatearFechaDdMMAaaa(reserva.horarioInicio),
                                          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                                color: Colors.grey[600],
                                                fontSize: 9,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        "₲${reserva.monto.toStringAsFixed(0)}",
                                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 11,
                                            ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 2,
                                          vertical: 0,
                                        ),
                                        decoration: BoxDecoration(
                                          color: colorEstado.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                        child: Text(
                                          estado,
                                          style: TextStyle(
                                            color: colorEstado,
                                            fontSize: 7,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    )
                  : Center(
                      child: Text(
                        "Selecciona un mes para ver los pagos",
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
} 