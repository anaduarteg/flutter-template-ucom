import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:finpay/controller/alumno/reserva_controller_alumno.dart';
import 'package:finpay/model/sitema_reservas.dart';
import 'package:finpay/utils/utiles.dart';
import 'package:google_fonts/google_fonts.dart';

class ReservaAlumnoScreen extends StatelessWidget {
  final controller = Get.put(ReservaAlumnoController());

  ReservaAlumnoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? const Color(0xFF1A1A1A) : const Color(0xFFE3F2FD);
    final cardColor = isDarkMode ? const Color(0xFF2D2D2D) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final secondaryTextColor = isDarkMode ? Colors.grey[400] : Colors.grey[600];
    final borderColor = isDarkMode ? Colors.grey[800]! : Colors.grey[300]!;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: textColor,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Reservar",
          style: GoogleFonts.montserrat(
            color: textColor,
            fontWeight: FontWeight.w700,
                fontSize: 20,
            letterSpacing: 0.5,
          ),
        ),
            Text(
              "Estacionamiento",
              style: GoogleFonts.montserrat(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.help_outline_rounded,
              color: textColor,
              size: 20,
            ),
            onPressed: () {
              // TODO: Implementar ayuda
            },
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: cardColor,
          boxShadow: [
            BoxShadow(
              color: (isDarkMode ? Colors.black : Colors.grey).withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.home_outlined,
                  label: "Inicio",
                  isSelected: false,
                  onTap: () => Get.back(),
                  isDarkMode: isDarkMode,
                ),
                _buildNavItem(
                  icon: Icons.local_parking_outlined,
                  label: "Reservar",
                  isSelected: true,
                  onTap: () {},
                  isDarkMode: isDarkMode,
                ),
                _buildNavItem(
                  icon: Icons.history_outlined,
                  label: "Historial",
                  isSelected: false,
                  onTap: () {},
                  isDarkMode: isDarkMode,
                ),
                _buildNavItem(
                  icon: Icons.person_outline,
                  label: "Perfil",
                  isSelected: false,
                  onTap: () {},
                  isDarkMode: isDarkMode,
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWeekCalendar(context, isDarkMode),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: _buildVehiculoSelector(context, isDarkMode),
                    ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: _buildPisoSelector(context, isDarkMode),
                              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: _buildLugaresGrid(context, isDarkMode),
            ),
            _buildSection(
              context,
              title: "Selecciona el horario",
              icon: Icons.access_time,
              child: _buildHorarioSelector(context, isDarkMode),
              isDarkMode: isDarkMode,
            ),
            Obx(() {
              final inicio = controller.horarioInicio.value;
              final salida = controller.horarioSalida.value;

              if (inicio == null || salida == null) return const SizedBox();

              final minutos = salida.difference(inicio).inMinutes;
              final horas = minutos / 60;
              final monto = (horas * 10000).round();

              return _buildSection(
                context,
                title: "Resumen de Reserva",
                icon: Icons.receipt_long,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryRow(
                      "Fecha:",
                      UtilesApp.formatearFechaDdMMAaaa(inicio),
                      isDarkMode: isDarkMode,
                    ),
                    const SizedBox(height: 8),
                    if (controller.autoSeleccionado.value != null) ...[
                      _buildSummaryRow(
                        "Vehículo:",
                        controller.autoSeleccionado.value!.marca,
                        isDarkMode: isDarkMode,
                      ),
                      const SizedBox(height: 8),
                      _buildSummaryRow(
                        "Matrícula:",
                        controller.autoSeleccionado.value!.chapa,
                        isDarkMode: isDarkMode,
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (controller.pisoSeleccionado.value != null)
                      _buildSummaryRow(
                        "Piso:",
                        controller.pisoSeleccionado.value!.descripcion,
                        isDarkMode: isDarkMode,
                      ),
                    const SizedBox(height: 8),
                    if (controller.lugarSeleccionado.value != null)
                      _buildSummaryRow(
                        "Lugar:",
                        controller.lugarSeleccionado.value!.codigoLugar,
                        isDarkMode: isDarkMode,
                      ),
                    const SizedBox(height: 8),
                    _buildSummaryRow(
                      "Horario:",
                      "${TimeOfDay.fromDateTime(inicio).format(context)} - ${TimeOfDay.fromDateTime(salida).format(context)}",
                      isDarkMode: isDarkMode,
                    ),
                    const SizedBox(height: 8),
                    _buildSummaryRow(
                      "Duración:",
                      "${horas.toStringAsFixed(1)} horas",
                      isDarkMode: isDarkMode,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total a pagar:",
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                          Text(
                            "₲${UtilesApp.formatearGuaranies(monto)}",
                            style: GoogleFonts.montserrat(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                isDarkMode: isDarkMode,
              );
            }),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.cancel_outlined,
                      label: "Salir",
                      onTap: () => Get.back(),
                      isDarkMode: isDarkMode,
                      isSecondary: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.check_circle_outline,
                      label: "Confirmar",
                      onTap: () async {
                        final confirmada = await controller.confirmarReserva();

                        if (confirmada) {
                          Get.snackbar(
                            "¡Éxito!",
                            "Reserva realizada correctamente",
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: isDarkMode
                                ? Colors.green.shade900
                                : Colors.green.shade100,
                            colorText: isDarkMode
                                ? Colors.green.shade100
                                : Colors.green.shade900,
                            margin: const EdgeInsets.all(20),
                            borderRadius: 12,
                          );

                          await Future.delayed(
                              const Duration(milliseconds: 2000));
                          Get.back();
                        } else {
                          Get.snackbar(
                            "Error",
                            "Por favor, completa todos los campos",
                            snackPosition: SnackPosition.TOP,
                            backgroundColor: isDarkMode
                                ? Colors.red.shade900
                                : Colors.red.shade100,
                            colorText: isDarkMode
                                ? Colors.red.shade100
                                : Colors.red.shade900,
                            margin: const EdgeInsets.all(20),
                            borderRadius: 12,
                          );
                        }
                      },
                      isDarkMode: isDarkMode,
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

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
    final color = isSelected
        ? Theme.of(Get.context!).colorScheme.primary
        : (isDarkMode ? Colors.grey[600] : Colors.grey[400]);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDarkMode
                  ? Theme.of(Get.context!).colorScheme.primary.withOpacity(0.1)
                  : Theme.of(Get.context!).colorScheme.primary.withOpacity(0.1))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.montserrat(
                color: color,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationChip({
    required int horas,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(Get.context!).colorScheme.primary
              : (isDarkMode ? Colors.grey[800] : Colors.grey[100]),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Theme.of(Get.context!).colorScheme.primary
                : (isDarkMode ? Colors.grey[700]! : Colors.grey[300]!),
          ),
        ),
        child: Text(
          "$horas h",
          style: GoogleFonts.poppins(
            color: isSelected
                ? Colors.white
                : (isDarkMode ? Colors.white : Colors.black87),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDarkMode,
    bool isSecondary = false,
  }) {
    final primaryColor = Theme.of(Get.context!).colorScheme.primary;
    final backgroundColor = isSecondary
        ? (isDarkMode ? Colors.grey[800] : Colors.grey[100])
        : primaryColor;
    final textColor = isSecondary
        ? (isDarkMode ? Colors.white : Colors.black87)
        : Colors.white;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: isSecondary
              ? Border.all(
                  color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!)
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required Widget child,
    required bool isDarkMode,
    IconData? icon,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isDarkMode ? Colors.black : Colors.grey).withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                title,
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    required bool isDarkMode,
    bool isAmount = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: isAmount
                ? Theme.of(Get.context!).colorScheme.primary
                : (isDarkMode ? Colors.white : Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeButton(
    BuildContext context,
    String label,
    Rx<DateTime?> time,
    IconData icon,
    VoidCallback onPressed, {
    required bool isDarkMode,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
            color: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Obx(() => Text(
                        time.value == null
                            ? label
                            : TimeOfDay.fromDateTime(time.value!).format(context),
                        style: GoogleFonts.montserrat(
                          color: time.value == null
                              ? (isDarkMode ? Colors.grey[400] : Colors.grey[600])
                              : (isDarkMode ? Colors.white : Colors.black87),
                          fontSize: 15,
                          fontWeight: time.value == null ? FontWeight.w400 : FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHorarioSelector(BuildContext context, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTimeButton(
                context,
                "Hora de inicio",
                controller.horarioInicio,
                Icons.access_time,
                () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: ColorScheme.light(
                            primary: Theme.of(context).colorScheme.primary,
                            onPrimary: Colors.white,
                            surface: isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
                            onSurface: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (time == null) return;
                  
                  final now = DateTime.now();
                  final newDateTime = DateTime(
                    now.year,
                    now.month,
                    now.day,
                    time.hour,
                    time.minute,
                  );
                  controller.horarioInicio.value = newDateTime;
                  
                  // Si hay una duración seleccionada, actualizar la hora de salida
                  if (controller.duracionSeleccionada.value > 0) {
                    controller.horarioSalida.value = newDateTime.add(
                      Duration(hours: controller.duracionSeleccionada.value)
                    );
                  }
                },
                isDarkMode: isDarkMode,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTimeButton(
                context,
                "Hora de fin",
                controller.horarioSalida,
                Icons.timer_off,
                () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: ColorScheme.light(
                            primary: Theme.of(context).colorScheme.primary,
                            onPrimary: Colors.white,
                            surface: isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
                            onSurface: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (time == null) return;
                  
                  final now = DateTime.now();
                  final newDateTime = DateTime(
                    now.year,
                    now.month,
                    now.day,
                    time.hour,
                    time.minute,
                  );
                  
                  // Verificar que la hora de fin sea posterior a la hora de inicio
                  if (controller.horarioInicio.value != null && 
                      newDateTime.isBefore(controller.horarioInicio.value!)) {
                    Get.snackbar(
                      "Error",
                      "La hora de fin debe ser posterior a la hora de inicio",
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: isDarkMode ? Colors.red.shade900 : Colors.red.shade100,
                      colorText: isDarkMode ? Colors.red.shade100 : Colors.red.shade900,
                      margin: const EdgeInsets.all(20),
                      borderRadius: 12,
                    );
                    return;
                  }
                  
                  controller.horarioSalida.value = newDateTime;
                },
                isDarkMode: isDarkMode,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          "Duración rápida",
          style: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: [1, 2, 4, 6, 8].map((horas) {
            final seleccionada = controller.duracionSeleccionada.value == horas;
            return _buildDurationChip(
              horas: horas,
              isSelected: seleccionada,
              onTap: () {
                controller.duracionSeleccionada.value = horas;
                final inicio = controller.horarioInicio.value ?? DateTime.now();
                controller.horarioInicio.value = inicio;
                controller.horarioSalida.value = inicio.add(Duration(hours: horas));
              },
              isDarkMode: isDarkMode,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildVehiculoSelector(BuildContext context, bool isDarkMode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isDarkMode ? Colors.black : Colors.grey).withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.directions_car,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                "Selecciona tu vehículo",
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            if (controller.autosCliente.isEmpty) {
              return const Center(
                child: Text("No hay vehículos disponibles"),
              );
            }

            return DropdownButtonFormField<Auto>(
              value: controller.autoSeleccionado.value,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              hint: const Text("Selecciona un vehículo"),
              items: controller.autosCliente.map((auto) {
                return DropdownMenuItem(
                  value: auto,
                  child: Text("${auto.marca} ${auto.modelo} - ${auto.chapa}"),
                );
              }).toList(),
              onChanged: (Auto? value) {
                controller.autoSeleccionado.value = value;
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPisoSelector(BuildContext context, bool isDarkMode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isDarkMode ? Colors.black : Colors.grey).withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.layers,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                "Selecciona el piso",
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            if (controller.pisos.isEmpty) {
              return const Center(
                child: Text("No hay pisos disponibles"),
              );
            }

            return DropdownButtonFormField<Piso>(
              value: controller.pisoSeleccionado.value,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              hint: const Text("Selecciona un piso"),
              items: controller.pisos.map((piso) {
                return DropdownMenuItem(
                  value: piso,
                  child: Text(piso.descripcion),
                );
              }).toList(),
              onChanged: (Piso? value) {
                if (value != null) {
                  controller.seleccionarPiso(value);
                }
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLugaresGrid(BuildContext context, bool isDarkMode) {
    return Container(
      width: double.infinity,
            padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isDarkMode ? Colors.black : Colors.grey).withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
              children: [
          Row(
            children: [
                  Icon(
                Icons.local_parking,
                    color: Theme.of(context).colorScheme.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                Text(
                "Selecciona el lugar",
                  style: GoogleFonts.montserrat(
                  fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 8),
          Obx(() {
            if (controller.pisoSeleccionado.value == null) {
              return Center(
                child: Text(
                  "Selecciona un piso primero",
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              );
            }

            final lugares = controller.lugaresDisponibles
                .where((l) => l.codigoPiso == controller.pisoSeleccionado.value?.codigo)
                .toList();

            if (lugares.isEmpty) {
              return Center(
                child: Text(
                  "No hay lugares disponibles en este piso",
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              );
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegendItem(
                        color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
                        label: "Disponible",
                        isDarkMode: isDarkMode,
                      ),
                      const SizedBox(width: 8),
                      _buildLegendItem(
                        color: isDarkMode ? Colors.red.shade900 : Colors.red.shade100,
                        label: "Reservado",
                        isDarkMode: isDarkMode,
                      ),
                      const SizedBox(width: 8),
                      _buildLegendItem(
                        color: isDarkMode ? Colors.green.shade900 : Colors.green.shade100,
                        label: "Seleccionado",
                        isDarkMode: isDarkMode,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 160,
                  child: GridView.count(
                    crossAxisCount: 5,
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 6,
                    childAspectRatio: 1.0,
                    children: lugares.map((lugar) {
                      final seleccionado = lugar == controller.lugarSeleccionado.value;
                      final color = lugar.estado == "RESERVADO"
                          ? (isDarkMode ? Colors.red.shade900 : Colors.red.shade100)
                          : seleccionado
                              ? (isDarkMode ? Colors.green.shade900 : Colors.green.shade100)
                              : (isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100);

                      return GestureDetector(
                        onTap: lugar.estado == "DISPONIBLE"
                            ? () => controller.seleccionarLugar(lugar)
                            : null,
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: color,
                            border: Border.all(
                              color: seleccionado
                                  ? (isDarkMode ? Colors.green.shade400 : Colors.green)
                                  : (isDarkMode ? Colors.grey[800]! : Colors.grey[300]!),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: seleccionado
                                ? [
                                    BoxShadow(
                                      color: (isDarkMode ? Colors.green.shade400 : Colors.green)
                                          .withOpacity(0.3),
                                      blurRadius: 4,
                                      spreadRadius: 1,
                                    )
                                  ]
                                : null,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                lugar.codigoLugar,
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  color: lugar.estado == "RESERVADO"
                                      ? (isDarkMode ? Colors.red.shade300 : Colors.red)
                                      : seleccionado
                                          ? (isDarkMode ? Colors.green.shade300 : Colors.green)
                                          : (isDarkMode ? Colors.white : Colors.black87),
                                ),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                lugar.descripcionLugar,
                                style: GoogleFonts.montserrat(
                                  fontSize: 8,
                                  color: lugar.estado == "RESERVADO"
                                      ? (isDarkMode ? Colors.red.shade300 : Colors.red)
                                      : seleccionado
                                          ? (isDarkMode ? Colors.green.shade300 : Colors.green)
                                          : (isDarkMode ? Colors.white70 : Colors.black54),
            ),
          ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required bool isDarkMode,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(
              color: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
              width: 1,
            ),
          ),
        ),
        const SizedBox(width: 2),
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 10,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildWeekCalendar(BuildContext context, bool isDarkMode) {
    final now = DateTime.now();
    final days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final currentWeekStart = Rxn<DateTime>(weekStart);
    final selectedDate = Rxn<DateTime>();
    
    // Función para obtener el nombre del mes
    String getMonthName(DateTime date) {
      final months = [
        'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
        'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
      ];
      return months[date.month - 1];
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isDarkMode ? Colors.black : Colors.grey).withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(() {
                final displayDate = selectedDate.value ?? currentWeekStart.value ?? weekStart;
                return Text(
                  getMonthName(displayDate),
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                );
              }),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.chevron_left,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                    onPressed: () {
                      final currentStart = currentWeekStart.value ?? weekStart;
                      currentWeekStart.value = currentStart.subtract(const Duration(days: 7));
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.chevron_right,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                    onPressed: () {
                      final currentStart = currentWeekStart.value ?? weekStart;
                      currentWeekStart.value = currentStart.add(const Duration(days: 7));
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            final weekStart = currentWeekStart.value ?? now.subtract(Duration(days: now.weekday - 1));
            
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (index) {
                final date = weekStart.add(Duration(days: index));
                final isToday = date.day == now.day && 
                              date.month == now.month && 
                              date.year == now.year;
                final isSelected = controller.horarioInicio.value?.day == date.day &&
                                 controller.horarioInicio.value?.month == date.month &&
                                 controller.horarioInicio.value?.year == date.year;
                final isPast = date.isBefore(DateTime(now.year, now.month, now.day));
                final reservasDelDia = controller.obtenerReservasDelDia(date);

                return GestureDetector(
                  onTap: isPast ? null : () {
                    final currentTime = controller.horarioInicio.value ?? DateTime.now();
                    final newDate = DateTime(
                      date.year,
                      date.month,
                      date.day,
                      currentTime.hour,
                      currentTime.minute,
                    );
                    controller.horarioInicio.value = newDate;
                    selectedDate.value = newDate;
                    
                    // Si hay una duración seleccionada, actualizar también la hora de salida
                    if (controller.duracionSeleccionada.value > 0) {
                      controller.horarioSalida.value = newDate.add(
                        Duration(hours: controller.duracionSeleccionada.value)
                      );
                    }
                  },
                  child: Opacity(
                    opacity: isPast ? 0.5 : 1.0,
                    child: Column(
                      children: [
                        Text(
                          days[index],
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Stack(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : isToday
                                        ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                                        : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : isToday
                                          ? Theme.of(context).colorScheme.primary
                                          : (isDarkMode ? Colors.grey[800]! : Colors.grey[300]!),
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  date.day.toString(),
                                  style: GoogleFonts.montserrat(
                                    fontSize: 14,
                                    fontWeight: isSelected || isToday ? FontWeight.w600 : FontWeight.w400,
                                    color: isSelected
                                        ? Colors.white
                                        : isToday
                                            ? Theme.of(context).colorScheme.primary
                                            : (isDarkMode ? Colors.white : Colors.black87),
                                  ),
                                ),
                              ),
                            ),
                            if (reservasDelDia.isNotEmpty)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
            );
          }),
          if (controller.horarioInicio.value != null) ...[
            const SizedBox(height: 16),
            Obx(() {
              final reservasDelDia = controller.obtenerReservasDelDia(controller.horarioInicio.value!);
              if (reservasDelDia.isEmpty) return const SizedBox();

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Reservas del día",
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...reservasDelDia.map((reserva) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "${TimeOfDay.fromDateTime(reserva.horarioInicio).format(context)} - ${TimeOfDay.fromDateTime(reserva.horarioSalida).format(context)}",
                              style: GoogleFonts.montserrat(
                                fontSize: 12,
                                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                          ),
                          Text(
                            "₲${UtilesApp.formatearGuaranies(reserva.monto)}",
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
