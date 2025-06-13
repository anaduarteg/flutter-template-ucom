import 'package:intl/intl.dart';

class UtilesApp {
  /// Retorna la fecha en formato dd-MM-yyyy
  static String formatearFechaDdMMAaaa(DateTime fecha) {
    return "${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}";
  }

  static String formatearFechaMMMMYYYY(DateTime fecha) {
    final meses = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return "${meses[fecha.month - 1]} ${fecha.year}";
  }

  static String formatearGuaranies(num monto) {
    final formatter = NumberFormat.currency(
      locale: 'es_PY',
      symbol: '₲',
      decimalDigits: 0,
    );
    return formatter.format(monto);
  }
}
