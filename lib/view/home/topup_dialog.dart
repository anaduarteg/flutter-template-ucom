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
  return Padding(
    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 40),
    child: Container(
      height: Get.height * 0.5, // 50% de la altura de la pantalla
      width: Get.width,
      decoration: BoxDecoration(
        color: AppTheme.isLightTheme == false
            ? const Color(0xff211F32)
            : Theme.of(context).appBarTheme.backgroundColor,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(
                    Icons.close,
                    color: HexColor(AppTheme.primaryColorString!),
                    size: 20,
                  ),
                ),
                Text(
                  "Confirmar Pago",
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                InkWell(
                  focusColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  onTap: () {
                    Get.back();
                  },
                  child: const Icon(
                    Icons.close,
                    color: Colors.transparent,
                    size: 25,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                color: HexColor(AppTheme.primaryColorString!).withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: SvgPicture.asset(
                  DefaultImages.topup,
                  height: 30,
                  width: 30,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Detalles del Pago",
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Monto a Pagar",
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xffA2A0A8)),
                ),
                Text(
                  "₲${reserva.monto}",
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 17),
            Divider(
              color: Theme.of(context)
                  .textTheme
                  .titleLarge!
                  .color!
                  .withOpacity(0.08),
            ),
            const SizedBox(height: 16),
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
            const SizedBox(height: 25),
            SizedBox(
              width: Get.width * 0.7, // 70% del ancho de la pantalla
              child: CustomButton(
                title: "Confirmar",
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TopUpSucessScreen(),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    ),
  );
}
