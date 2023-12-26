import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';

//Constants
const appName = 'HGSS';
const appVersion = '1.7.3';

//EndPoints
const String auditMailServer = "http://salzerelectronics.in:9086/security";
const String tbPassword = "ce1hg\$s";
const String tbUsername = "hgss@schnellenergy.com";
const String tbURL = "https://salzerelectronics.in";

const String websocketApi =
    "ws://salzerelectronics.in/api/ws/plugins/telemetry";
//Routes
const splashRoute = '/';
const otpRoute = '/login';
const loginRoute = '/scanOrLogin';
const homeRoute = '/home';
const otpVerificationRoute = '/otp';
const addUserRoute = '/addUser';
const notificationsRoute = '/notifications';
const primaryNotificationsRoute = '/primaryNotifications';
const settingsRoute = '/settings';
const deviceHistoryRoute = '/deviceHistory';
const editInformationRoute = 'editInformation';
const addSensorRoute = '/addSensor';
const editProfileRoute = '/editProfile';

//Images
const salzerLogo = 'assets/images/salzer.png';
const salzerLabel = 'assets/images/slogos.jpg';
const splashImage = 'assets/images/splash.png';
const homeGuardLogo = 'assets/images/homeGuard.png';
const waveImage = 'assets/images/wave.png';

//Icons
const doorOpen = 'assets/icons/doorOpen.png';
const doorClose = 'assets/icons/doorCloseIcon.png';
const remote = 'assets/icons/remote.png';
const voice = 'assets/icons/voice.png';
const away = 'assets/icons/away.png';
const unlock = 'assets/icons/unlock.png';
const unlocked = 'assets/icons/unlockIcon.png';
const unlocked1 = 'assets/icons/unlock1.png';
const lock = 'assets/icons/lock.png';
const emptyFolder = 'assets/icons/empty-folder.png';
//secondary users
const maxSecondaryUsers = 4;

//ErrorMessages
const scanValidDevice = 'Invalid QR Code';
const scanValidSensor =
    "Scanned QR Code is invalid. Please scan the QR Code of a valid System";
const invalidOtpMessage = "Invalid OTP. Please check and try again.";
const otpRequired = 'Field Error message: "OTP Required"';
const recoveryModeFailed = "Data recovery failed. Please try again";
const numberAlreadyUsed =
    "Mobile Number already available. Please enter a new mobile number";
const deviceResetFailed = "Data recovery failed. Please try again";

//factory reset steps
const step1 =
    "STEP 1. Gateway reset first by press and hold the gateway 'Disarm' button then single press the 'reset' button.";
const step2 =
    "STEP 2. Hold the 'Disarm' button till getting reset sound from gateway.";
const step3 =
    "STEP 3. Once network LED fast blink in the gateway then click 'Start Device Recover Mode' in mobile app.";
const step4 =
    "STEP 4. Please hold the 'reset' button in the Wireless movement sensor (WMS) when the beep sound observed in gateway (Till green LED blinks in WMS).";
const step5 =
    "STEP 5. Once Device recovery completed , Toast message will be received.";

//popup
const armDevices = "Do you want to arm all security sensors?";
const disarmDevices = "Do you want to disarm all security sensors?";
const deleteUserPopup =
    "Are you sure you want to remove this mobile number from your Watch Group?";
const logoutMessage = "Are you sure you wish to log out from Home Guard?";
const deleteDevice = 'Sure!! you want to Delete this sensor from Gateway?';
const factoryReset =
    'Sure!! you want to Factory Reset the Gateway. Your Details will be Loss?';
const changeSim = "Are you sure you want to change Mobile Number?";
// Warning messages

const sendingOtp =
    "Logging in with your mobile number. Please wait for an OTP...";
const registerProcess =
    "Registering your mobile number. Please wait for an OTP...";
const validatingOtp = "Verifying OTP. Please wait...";
const triggerSos = "Publishing SOS... Stay Safe and Calm.";
const fetchingSecondaryUsers = "Please wait fetching secondary users";

const deletedSecondaryUser =
    "The selected mobile number has been successfully removed from your Watch Group.";
const secondaryUsersUpdated = "Watch Group updated Successfully";
const updateSecodaryUser = "Updating your Watch Group. Please wait...";
const changeProfileMessage = "Changing profile please wait";
const updateDeviceMessage = "Updating Device info";
const updateGatewayDetails = "Personalizing your Security System...";
const fetchingDeviceHistory = "Fetching device details. Please wait";
removeSensorMessage(name) => "Removing sensor $name... Please wait.";
const addDeviceMessage =
    "Adding sensor to the Gateway in progress.Please wait...";
const recoveryMode =
    "Initiating data recovery from the server in progress.Please wait...";
const deviceReset =
    "Device Reseting to factory settings is in Progress. Please wait...";
const logingOut = "Logging out, Please wait...";
const changeSimNumber = "Updating your Mobile number. Please wait...";
const provideValidNumber = "Please provide a valid 10 digit mobile number";
const invalidSensorDetails =
    "Please scan a different sensor. This is not a valid sensor.";
const addingSensor = "Adding a sensor to your Security System. Please wait...";
sensorAlreadyAvailable(name, gatewayName) =>
    'Sensor "$name" is already attached with the Security System "$gatewayName". Scan a different one';
//Loaders
const spinkit = SpinKitCircle(
  color: Color.fromARGB(255, 4, 122, 54),
  size: 40.0,
);

ThemeData lightTheme(context) => ThemeData(
    useMaterial3: false,
    scaffoldBackgroundColor: Colors.white,
    textTheme:
        GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme.copyWith(
              headlineSmall: TextStyle(color: Colors.grey[800]),
              titleLarge: TextStyle(color: Colors.grey[800]),
              bodyLarge: const TextStyle(color: Colors.black),
              bodySmall: const TextStyle(color: Colors.black),
              titleMedium: const TextStyle(color: Colors.black),
              titleSmall: TextStyle(color: Colors.grey[200]),
              bodyMedium: const TextStyle(color: Colors.black),
            )),
    canvasColor: Colors.grey[400],
    primaryColor: const Color.fromARGB(255, 5, 77, 67),
    focusColor: Colors.amber[800],
    cardColor: Colors.red.shade800,
    highlightColor: Colors.greenAccent,
    secondaryHeaderColor: Colors.cyan,
    hoverColor: Colors.blueGrey,
    indicatorColor: Colors.pinkAccent[400],
    shadowColor: Colors.lightGreen[400],
    bottomAppBarTheme: BottomAppBarTheme(color: Colors.blueAccent[400]));

ThemeData darkTheme(context) => ThemeData(
      useMaterial3: false,
      scaffoldBackgroundColor: Colors.white,
      textTheme:
          GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme.copyWith(
                headlineSmall: const TextStyle(color: Colors.grey),
                titleLarge: const TextStyle(color: Colors.grey),
                bodyLarge: const TextStyle(color: Colors.grey),
                bodySmall: const TextStyle(color: Colors.white),
                titleMedium: TextStyle(color: Colors.grey[400]),
                titleSmall: TextStyle(color: Colors.grey[200]),
                bodyMedium: const TextStyle(color: Colors.white),
              )),
      canvasColor: Colors.white,
      primaryColor: Colors.black,
      focusColor: Colors.amber[800],
      cardColor: Colors.red.shade800,
      highlightColor: Colors.blueGrey[400],
      secondaryHeaderColor: Colors.teal[800],
      hoverColor: Colors.blueGrey,
      indicatorColor: Colors.pinkAccent[400],
    );
