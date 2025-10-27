import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    // MediaQuery 
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth >= 360 && screenWidth < 600;
    final isLargeScreen = screenWidth >= 600;

    // Responsive sizes berdasarkan ukuran layar
    final iconSize = isSmallScreen ? 80.0 : (isMediumScreen ? 100.0 : 140.0);
    final headlineSize = isSmallScreen ? 24.0 : (isMediumScreen ? 28.0 : 32.0);
    final horizontalPadding = screenWidth * 0.06; // 6% dari lebar layar
    final maxWidth = isLargeScreen ? 500.0 : screenWidth;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: screenHeight * 0.02, // 2% dari tinggi layar
            ),
            child: ConstrainedBox(
              // 🎯 Batasi lebar maksimal untuk tablet/desktop
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo atau Icon - Responsive size
                  Icon(
                    Icons.restaurant_menu,
                    size: iconSize,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  // Judul - Responsive font size
                  Text(
                    'Warung Makan',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: headlineSize,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),

                  Text(
                    'Almera',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: headlineSize,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),

                  Text(
                    'Silakan login untuk melanjutkan',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 13.0 : 15.0,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.05),

                  // Username TextField - Responsive
                  TextField(
                    controller: controller.usernameController,
                    style: TextStyle(fontSize: isSmallScreen ? 14.0 : 16.0),
                    decoration: InputDecoration(
                      labelText: 'Username',
                      hintText: 'Masukkan username',
                      prefixIcon: Icon(
                        Icons.person,
                        size: isSmallScreen ? 20.0 : 24.0,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.04,
                        vertical: screenHeight * 0.02,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  // Password TextField - Responsive
                  Obx(() => TextField(
                        controller: controller.passwordController,
                        obscureText: controller.obscurePassword.value,
                        style: TextStyle(fontSize: isSmallScreen ? 14.0 : 16.0),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Masukkan password',
                          prefixIcon: Icon(
                            Icons.lock,
                            size: isSmallScreen ? 20.0 : 24.0,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.obscurePassword.value
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              size: isSmallScreen ? 20.0 : 24.0,
                            ),
                            onPressed: controller.togglePasswordVisibility,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.04,
                            vertical: screenHeight * 0.02,
                          ),
                        ),
                      )),
                  SizedBox(height: screenHeight * 0.03),

                  // Login Button - Responsive
                  Obx(() => ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : controller.login,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: screenHeight * 0.02,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: controller.isLoading.value
                            ? SizedBox(
                                height: isSmallScreen ? 18.0 : 20.0,
                                width: isSmallScreen ? 18.0 : 20.0,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 14.0 : 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      )),
                  SizedBox(height: screenHeight * 0.02),

                  // Info kredensial - Responsive
                  Container(
                    padding: EdgeInsets.all(screenWidth * 0.03),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Demo Credentials:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: isSmallScreen ? 12.0 : 14.0,
                            color: Colors.blue[900],
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.005),
                        Text(
                          'Username: admin',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 11.0 : 13.0,
                            color: Colors.blue[800],
                          ),
                        ),
                        Text(
                          'Password: admin123',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 11.0 : 13.0,
                            color: Colors.blue[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
