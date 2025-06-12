import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:finpay/controller/reserva_controller.dart';
import 'package:finpay/controller/tab_controller.dart';
import 'package:finpay/controller/home_controller.dart';
import 'package:finpay/model/sitema_reservas.dart';
import 'package:finpay/utils/utiles.dart';
import 'package:finpay/view/tab_screen.dart';

class ReservaScreen extends StatelessWidget {
  final controller = Get.put(ReservaController());

  ReservaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reservar lugar")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Obx(() {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Seleccionar auto",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Obx(() {
                  return DropdownButton<Auto>(
                    isExpanded: true,
                    value: controller.autoSeleccionado.value,
                    hint: const Text("Seleccionar auto"),
                    onChanged: (auto) {
                      controller.autoSeleccionado.value = auto;
                    },
                    items: controller.autosCliente.map((a) {
                      final nombre = "${a.chapa} - ${a.marca} ${a.modelo}";
                      return DropdownMenuItem(value: a, child: Text(nombre));
                    }).toList(),
                  );
                }),
                const Text("Seleccionar piso",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                DropdownButton<Piso>(
                  isExpanded: true,
                  value: controller.pisoSeleccionado.value,
                  hint: const Text("Seleccionar piso"),
                  onChanged: (p) => controller.seleccionarPiso(p!),
                  items: controller.pisos
                      .map((p) => DropdownMenuItem(
                          value: p, child: Text(p.descripcion)))
                      .toList(),
                ),
                const SizedBox(height: 16),
                const Text("Seleccionar lugar",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 200,
                  child: GridView.count(
                    crossAxisCount: 5,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    children: controller.lugaresDisponibles
                        .where((l) =>
                            l.codigoPiso ==
                            controller.pisoSeleccionado.value?.codigo)
                        .map((lugar) {
                      final seleccionado =
                          lugar == controller.lugarSeleccionado.value;
                      final color = lugar.estado == "RESERVADO"
                          ? Colors.red
                          : seleccionado
                              ? Colors.green
                              : Colors.grey.shade300;

                      return GestureDetector(
                        onTap: lugar.estado == "DISPONIBLE"
                            ? () => controller.lugarSeleccionado.value = lugar
                            : null,
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: color,
                            border: Border.all(
                                color: seleccionado
                                    ? Colors.green.shade700
                                    : Colors.black12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            lugar.codigoLugar,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: lugar.estado == "reservado"
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                const Text("Seleccionar horarios",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate:
                                DateTime.now().add(const Duration(days: 30)),
                          );
                          if (date == null) return;
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (time == null) return;
                          controller.horarioInicio.value = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            time.hour,
                            time.minute,
                          );
                        },
                        icon: const Icon(Icons.access_time),
                        label: Obx(() => Text(
                              controller.horarioInicio.value == null
                                  ? "Inicio"
                                  : "${UtilesApp.formatearFechaDdMMAaaa(controller.horarioInicio.value!)} ${TimeOfDay.fromDateTime(controller.horarioInicio.value!).format(context)}",
                            )),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: controller.horarioInicio.value ??
                                DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate:
                                DateTime.now().add(const Duration(days: 30)),
                          );
                          if (date == null) return;
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (time == null) return;
                          controller.horarioSalida.value = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            time.hour,
                            time.minute,
                          );
                        },
                        icon: const Icon(Icons.timer_off),
                        label: Obx(() => Text(
                              controller.horarioSalida.value == null
                                  ? "Salida"
                                  : "${UtilesApp.formatearFechaDdMMAaaa(controller.horarioSalida.value!)} ${TimeOfDay.fromDateTime(controller.horarioSalida.value!).format(context)}",
                            )),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text("Duración rápida",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [1, 2, 4, 6, 8].map((horas) {
                    final seleccionada =
                        controller.duracionSeleccionada.value == horas;
                    return ChoiceChip(
                      label: Text("$horas h"),
                      selected: seleccionada,
                      selectedColor: Theme.of(context).colorScheme.primary,
                      onSelected: (_) {
                        controller.duracionSeleccionada.value = horas;
                        final inicio =
                            controller.horarioInicio.value ?? DateTime.now();
                        controller.horarioInicio.value = inicio;
                        controller.horarioSalida.value =
                            inicio.add(Duration(hours: horas));
                      },
                    );
                  }).toList(),
                ),
                Obx(() {
                  final inicio = controller.horarioInicio.value;
                  final salida = controller.horarioSalida.value;

                  if (inicio == null || salida == null) return const SizedBox();

                  final minutos = salida.difference(inicio).inMinutes;
                  final horas = minutos / 60;
                  final monto = (horas * 10000).round();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                        child: Text(
                          "Monto a pagar: ₲${UtilesApp.formatearGuaranies(monto)}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Nota: El pago quedará pendiente y deberá ser realizado en el módulo de pagos",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Obx(() => controller.reservaConfirmada.value
                        ? ElevatedButton(
                            onPressed: () {
                              Get.offAll(
                                () => const TabScreen(),
                                binding: BindingsBuilder(() {
                                  Get.delete<TabScreenController>();
                                  Get.delete<HomeController>();
                                  Get.put(TabScreenController());
                                  Get.put(HomeController());
                                }),
                                transition: Transition.fadeIn,
                                duration: const Duration(milliseconds: 300),
                              );
                            },
                        style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Ir a pagar'),
                          )
                        : ElevatedButton(
                            onPressed: () async {
                            await controller.cancelarReserva();
                              Get.offAll(
                                () => const TabScreen(),
                                binding: BindingsBuilder(() {
                                  Get.delete<TabScreenController>();
                                  Get.delete<HomeController>();
                                  Get.put(TabScreenController());
                                  Get.put(HomeController());
                                }),
                                transition: Transition.fadeIn,
                                duration: const Duration(milliseconds: 300),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Cancelar'),
                          )),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final confirmado = await controller.confirmarReserva();
                          Get.offAll(
                            () => const TabScreen(),
                            binding: BindingsBuilder(() {
                              Get.delete<TabScreenController>();
                              Get.delete<HomeController>();
                              Get.put(TabScreenController());
                              Get.put(HomeController());
                            }),
                            transition: Transition.fadeIn,
                            duration: const Duration(milliseconds: 300),
                            );
                        },
                        child: const Text('Confirmar'),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required bool isSelected,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey[300]!,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey[600],
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey[800],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
