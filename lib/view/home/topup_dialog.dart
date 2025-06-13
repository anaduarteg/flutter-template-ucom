// ignore_for_file: deprecated_member_use

import 'package:finpay/config/images.dart';
import 'package:finpay/config/textstyle.dart';
import 'package:finpay/view/home/topup_sucess_screen.dart';
import 'package:finpay/widgets/custom_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:finpay/model/sitema_reservas.dart';

Widget topupDialog(BuildContext context, {required Reserva reserva}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppTheme.isLightTheme == false
          ? const Color(0xff211F32)
          : Theme.of(context).appBarTheme.backgroundColor,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Confirmar Pago",
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.close,
                color: HexColor(AppTheme.primaryColorString!),
                size: 20,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.isLightTheme == false
                ? const Color(0xff323045)
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: HexColor(AppTheme.primaryColorString!).withOpacity(0.1),
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Monto a Pagar",
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          fontSize: 14,
                          color: const Color(0xffA2A0A8),
                        ),
                  ),
                  Text(
                    "₲${reserva.monto}",
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Divider(
                color: Theme.of(context).textTheme.titleLarge!.color!.withOpacity(0.1),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total",
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  Text(
                    "₲${reserva.monto}",
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: HexColor(AppTheme.primaryColorString!),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Confirmar Pago",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
