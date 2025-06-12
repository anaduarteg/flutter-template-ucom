import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  // Controllers
  Rx<TextEditingController> mobileController = TextEditingController().obs;
  Rx<TextEditingController> pswdController = TextEditingController().obs;
  
  // State
  RxBool isVisible = false.obs;
  RxBool isLoading = false.obs;
  RxBool isLoggedIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Aquí podrías agregar lógica de inicialización
    // Por ejemplo, verificar si hay una sesión guardada
  }

  @override
  void onClose() {
    // Limpiar los controllers cuando se cierre
    mobileController.value.dispose();
    pswdController.value.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isVisible.value = !isVisible.value;
  }

  Future<bool> login() async {
    try {
      isLoading.value = true;
      
      // Aquí iría la lógica real de autenticación
      // Por ejemplo, una llamada a una API
      
      // Simulamos un delay para mostrar el loading
      await Future.delayed(const Duration(seconds: 2));
      
      isLoggedIn.value = true;
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Ocurrió un error al iniciar sesión',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void logout() {
    isLoggedIn.value = false;
    mobileController.value.clear();
    pswdController.value.clear();
  }

  bool validateFields() {
    if (mobileController.value.text.isEmpty || pswdController.value.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Por favor complete todos los campos',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    if (mobileController.value.text.length < 10) {
      Get.snackbar(
        'Error',
        'El número de teléfono debe tener 10 dígitos',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    return true;
  }
}
